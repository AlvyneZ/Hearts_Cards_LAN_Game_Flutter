import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'header.dart';

String cardToPlay = '';
String playerName = 'Name';
double cardsAspect = 0.65;

double screenWidth(BuildContext context, {double fraction = 1}){
  return MediaQuery.of(context).size.width * fraction;
}
double screenHeight(BuildContext context, {double fraction = 1}){
  return MediaQuery.of(context).size.height * fraction;
}
double screenAspect(BuildContext context){
  //Ratio of width / height
  return MediaQuery.of(context).size.aspectRatio;
}

void main(){
  init();
  runApp(CardsApp());
}

class CardsApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards Games',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green[300],
      ),
      initialRoute: '/HeartsInit',
      routes:{
        '/HeartsInit' : (context) =>
            StreamBuilder(stream: updater.stream, builder: (context, snapshot) => HeartsInit()),
        '/HeartsLobby' : (context) =>
            StreamBuilder(stream: updater.stream, builder: (context, snapshot) => HeartsLobby()),
        '/HeartsGame' : (context) =>
            StreamBuilder(stream: updater.stream, builder: (context, snapshot) => Hearts(title: 'Hearts')),
        '/HeartsGameOver' : (context) => HeartsResults(),
      },
    );
  }
}

class HeartsInit extends StatefulWidget {
  @override
  _HeartsInitState createState() => _HeartsInitState();
}

class _HeartsInitState extends State<HeartsInit> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    selfIP();
    return Scaffold(
      appBar:  AppBar(
        title: Text('Hearts Initialization'),
      ),
      backgroundColor: Colors.grey[50],
      body: Container(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Player Name",
                      hintText: "Enter the player name you wish to use",
                      contentPadding: EdgeInsets.all(15.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green[300], width: 1.0),
                      ),
                      filled: true,
                      fillColor: Colors.green[50],
                    ),
                    validator: (String value){
                      if(value.isEmpty){
                        return "Enter your player name";
                      }
                      for (int i = 0; i < value.length; i ++){
                        if (value[i] == ';')
                          return "Sorry: You may not use a semicolon ';' in your name";
                      }
                      return null;
                    },
                    onSaved: (String value){
                      playerName = value;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text(
                      "Your IP adress is: $myIPString",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[500]
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Server IP address",
                      hintText: "Enter the IP Address of the server",
                      contentPadding: EdgeInsets.all(15.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green[300], width: 1.0),
                      ),
                      filled: true,
                      fillColor: Colors.green[50],
                    ),
                    keyboardType: TextInputType.number,
                    validator: (String value){
                      if(value.isEmpty){
                        return "The server's IP Address cannot be left empty";
                      }
                      else{
                        int numberCount = 0, count = 0;
                        for (int i = 0; i < value.length; i++) {
                          if ((numberCount < 3) && (count > 0) && (value[i] == '.')) {
                            count = 0; numberCount ++;
                          }
                          else if ((count < 3) && (value[i]=='0' || value[i]=='1' || value[i]=='2'
                              || value[i]=='3' ||value[i]=='4' || value[i]=='5'
                              || value[i]=='6' || value[i]=='7' ||value[i]=='8'
                              || value[i]=='9')) {
                            count ++;
                          }
                          else {
                            return "Enter the server's IP Address in the form d.d.d.d";
                          }
                        }
                      }
                      return null;
                    },
                    onSaved: (String value){
                      server = value;
                    },
                  ),
                  ButtonBar(
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.greenAccent,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            start(playerName);
                            Navigator.pushNamed(context, '/HeartsLobby');
                          }
                        },
                        child: Text(
                          'Connect to server',
                          style: TextStyle(
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class HeartsLobby extends StatefulWidget {
  @override
  _HeartsLobbyState createState() => _HeartsLobbyState();
}

class _HeartsLobbyState extends State<HeartsLobby> {
  @override
  Widget build(BuildContext context) {
    if (isServer || connected) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Hearts Game Lobby"),
        ),
        backgroundColor: Colors.grey[300],
        body: Container(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0,horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    (isServer)?"You are the server":
                    "You are connected to the server on ${playersNames[0]}'s phone",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      fontSize: 20,
                      color: Colors.green[700],
                    ),
                  ),
                  Divider(
                      thickness: 3.0,
                      color: Colors.green[700]
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Server IP: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            fontSize: 15,
                            color: Colors.green[600],
                          ),
                        ),
                        Text("$server",
                          style: TextStyle(
                            letterSpacing: 2.0,
                            fontSize: 20,
                            color: Colors.teal[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                      thickness: 2.0,
                      color: Colors.green[700]
                  ),
                  Text("Connected Players: ",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontSize: 18,
                      color: Colors.green[500],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: playersNames.map((pl) {
                        return Text(pl,
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1.0,
                                fontSize: 15,
                                color: Colors.green[400],
                            )
                        );
                      }).toList()
                    ),
                  ),
                  (isServer)?
                  RaisedButton(
                    color: Colors.greenAccent,
                    onPressed: ((gameBegan || (connectedPlayers<4))?null:(){
                      //{DEBUGGING} remove connected players condition if less phones available
                      if (connectedPlayers == 4){
                        beginNewGame();
                        Navigator.pushNamed(context, '/HeartsGame');
                      }else{return null;}
                    }),
                    child: Text('Begin Game'),
                  )
                  :
                  Container(),
                  RaisedButton(
                    color: Colors.greenAccent,
                    onPressed: (gameBegan?(){Navigator.pushNamed(context, '/HeartsGame');}:null),
                    child: Text('Connect to Game'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    else if (connectFail){
        return Scaffold(
            appBar: AppBar(
              title: Text("Connection failed"),
            ),
            body: Text("Failed To Connect. Server is full"),
        );
    }
    else{
        return Scaffold(
          appBar: AppBar(
            title: Text("Connection in progress"),
          ),
          body: Text("Awaiting connection confirmation from server"),
        );
    }
  }
}



class Hearts extends StatefulWidget {

  Hearts({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HeartsState createState() => _HeartsState();

}

class _HeartsState extends State<Hearts> {

  void playButton(){
    if (swapped) {
      if (((turn == me) && (cardToPlay != '')) || ((turn == -1) && (cardToPlay == '2C')))
        return play(cardToPlay, me);
      else
        return null;
    }
    else{
      if (myOldSwapCards.length == 3){
        return sendSwapCards();
      }
      else
        return null;
    }
  }

  void rearrangeButton(){
    setState(() {
      players[me].cardsInHand = rearrange(players[me].cardsInHand);
    });
  }

  void play (String card, int player){
    setState(() {
      print("Checking for play validity. Turn: $turn");
      if (playHeartsIsValid(
          heartsIsBroken, table, card, me, players[player].cardsInHand)) {
        sendPlayCard(cardToPlay);
        cardToPlay = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String swapOrPlay = "SWAP";
    if (swapped) swapOrPlay = "PLAY";
    if (gameEnd){
      Navigator.pushNamed(context, '/HeartsGameOver');
    }
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight(context, fraction: 0.05)),
          child: AppBar(
            title: Text(widget.title),
          ),
      ),
      //DIMENSION: At this point a total 0.05 of the screen height is used up
      body: Container(
        color: Colors.green[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TableCards(cards: table),
              //To show the table with the cards that have been played
              //DIMENSION: At this point a total 0.4 of the screen height is used up
              Container(
                //To show the cards in hand of the player
                height: 200.0,
                child: StreamBuilder(
                  stream: updater.stream,
                  builder: (context, snapshot) {
                    return PlayerCards(playerCards: players[me].cardsInHand);
                  }
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    color: Colors.amber[500],
                    onPressed: ((!gameEnd)?null:(){
                      Navigator.pushNamed(context, '/HeartsResults');
                    }),
                    child: Text('VIEW RESULTS'),
                  ),
                  RaisedButton(
                    onPressed: (playButton),
                    color: Colors.amber[500],
                    child: Text('$swapOrPlay'),
                  ),
                  RaisedButton(
                    onPressed: (rearrangeButton),
                    color: Colors.amber[500],
                    child: Text('REARRANGE'),
                  ),
                ]
              ),
              Container(
                //To show the cards taken by the player
                height: 25,
                child: Center(
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: players[me].cardsTaken.map((card) {
                          return Expanded(
                              flex: 1,
                              child: Image.asset('assets/red_back.png')
                          );
                        }).toList(),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[500],
          child: Container(
            height: 50.0,
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      PlayerScore(player: players[0]),
                      PlayerScore(player: players[1]),
                    ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      PlayerScore(player: players[2]),
                      PlayerScore(player: players[3]),
                    ]
                )
              ]
            ),
          )
      ),
    );
  }
}

class DragCard extends StatefulWidget {
  final String card;
  final Offset initPos;
  final double hCard;
  final double wCard;

  DragCard({Key key, this.card, this.initPos, this.hCard, this.wCard}) : super(key: key);

  @override
  DragCardState createState() => DragCardState();
}

class DragCardState extends State<DragCard> {

  Offset position = Offset(0.0, 0.0);
  double opacity = 1.0;

  @override
  void initState() {
    super.initState();
    position = widget.initPos;
  }

  @override
  Widget build(BuildContext context) {
    if (cardToPlay == widget.card){
      opacity = 0.5;
    }
    else{
      opacity = 1.0;
    }
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        data: widget.card,
        child: Opacity(
            opacity: opacity,
            child: CardImage(card: widget.card, heightImg: widget.hCard, widthImg: widget.wCard)
        ),
        childWhenDragging: Container(color: Colors.grey[300],height: widget.hCard, width: widget.wCard),
        feedback: CardImage(card: widget.card, heightImg: (widget.hCard + 20.0), widthImg: (widget.wCard + 20.0)),
        onDragCompleted: (){
          setState(() {
            opacity = 0.5;
          });
        },
      ),
    );
  }
}

class CardImage extends StatelessWidget {
  final String card;
  final double heightImg;
  final double widthImg;

  const CardImage({Key key, this.card, this.heightImg, this.widthImg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthImg,
      height: heightImg,
      child: Image.asset ('assets/' + card + '.png'),
    );
  }
}

class PlayerCards extends StatefulWidget {
  final List<String> playerCards;

  const PlayerCards({Key key, this.playerCards}) : super(key: key);

  @override
  PlayerCardsState createState() => PlayerCardsState();
}

class PlayerCardsState extends State<PlayerCards> {
  double count = -1;
  DragCard toRet;


  @override
  Widget build(BuildContext context) {
    count = -1;
    if (widget.playerCards.length != 0) {
      return Stack(
        children: <Widget> [
          Stack(
            children: widget.playerCards.map((card) {
              count += 1.0;
              if (count < (widget.playerCards.length / 2)) {
                toRet = DragCard(
                  card: card,
                  initPos: Offset((count * 50.0), 0.0),
                  hCard: 76.0,
                  wCard: 50.0,
                );
              }
              else{
                toRet = DragCard(
                  card: card,
                  initPos: Offset(((count - (widget.playerCards.length/2)) * 50.0), 76.0),
                  hCard: 76.0,
                  wCard: 50.0,
                );
              }
              return toRet;
            }).toList()
          ),
          Positioned(
            left: 0.0,
            top: 150.0,
            child: DragTarget(
              onAccept: (String card){
                setState(() {
                  if (swapped)
                    cardToPlay = card;
                  else{
                    if (!myOldSwapCards.contains(card)) {
                      if (myOldSwapCards.length >= 3) {
                        myOldSwapCards.removeAt(0);
                      }
                      myOldSwapCards.add(card);
                    }
                  }
                });
              },
              builder:(
                  BuildContext context,
                  List<dynamic> accepted,
                  List<dynamic> rejected,
                  ) {
                    if (swapped) {
                      if (cardToPlay != '') {
                        return Container(
                            height: 50.0,
                            width: screenWidth(context), //originally (55.0 * (widget.playerCards.length / 2)),
                            color: Colors.green[300],
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CardImage(card: cardToPlay,
                                      heightImg: 50,
                                      widthImg: 32),
                                  Text('Drag the card you wish to play here'),
                                ]
                            )
                        );
                      }
                      else {
                        return Container(
                          height: 50.0,
                          width: screenWidth(context),
                          color: Colors.green[300],
                          child: Center(child: Text(
                              'Drag the card you wish to play here')),
                        );
                      }
                    }
                    else{
                      if (myOldSwapCards != []) {
                        return Container(
                            height: 50.0,
                            width: screenWidth(context),
                            color: Colors.green[300],
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SwapCards(cards: myOldSwapCards,
                                      heightImg: 50,
                                      widthImg: 32),
                                  Text('Drag the cards you wish to swap here'),
                                ]
                            )
                        );
                      }
                      else {
                        return Container(
                          height: 50.0,
                          width: screenWidth(context),
                          color: Colors.green[300],
                          child: Center(child: Text(
                              'Drag the cards you wish to swap here')),
                        );
                      }
                    }
                  }
            )
          )
        ]
      );
    }
    else{
      return Container();
    }
  }
}

class SwapCards extends StatelessWidget {
  final List<String> cards;
  final double heightImg;
  final double widthImg;

  const SwapCards({Key key, this.cards, this.heightImg, this.widthImg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cards.length == 1) {
      return CardImage(widthImg: widthImg, heightImg: heightImg, card: cards[0]);
    }
    else{
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: cards.map((card){
          return CardImage(widthImg: widthImg, heightImg: heightImg, card: card);
        }).toList(),
      );
    }
  }
}

class TableCards extends StatelessWidget {
  final List<String> cards;

  const TableCards({Key key, this.cards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String yourTurn = "";
    if (turn == me) yourTurn = "Your Turn";
    int count = -1;
    double tableHeight, tableWidth;
    return Container(
      height: ((){
        if(screenHeight(context, fraction: (0.3333*cardsAspect*2.3846)) >= screenWidth(context, fraction: 0.8333))
          tableHeight = screenHeight(context, fraction: 0.3333);
        else
          tableHeight = screenWidth(context, fraction: (0.8333 * 0.41935/cardsAspect));
      }()),//initially 120
      width: tableWidth = tableHeight * 2.3846 * cardsAspect,//initially 235
      margin: EdgeInsets.symmetric(
          vertical: tableHeight/12, //initially all 10
          horizontal: tableWidth/12
      ),
      padding: EdgeInsets.symmetric(
          vertical: tableHeight/12, //initially all 10
          horizontal: tableWidth/12
      ),
      color:Colors.black,
      child: Stack(
        children: <Widget>[
          (cards.length == 0)?
                Positioned(
                    left: 0.0,
                    top: 0.0,
                    child: Container(
                      height: (tableHeight * 5 / 7.8),//initially 100
                      width: (tableWidth * 5 / 18.6),//initially 65
                      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(tableHeight * 0.5 / 7.8)),
                      ),
                      child: Center(
                          child: Text('First Play $yourTurn')
                      )
                    )
                )
            :
              Stack(
                  children: cards.map((card) {
                    count ++;
                    return Positioned(
                        left: (count * (tableHeight * 3.5 / 18.6)),
                        top: (count * (tableHeight * 0.5 / 7.8)),
                        child: CardImage(
                          card: card,
                          heightImg: (tableHeight * 5 / 7.8),//initially 100
                          widthImg: (tableHeight * 5 / 18.6),//initially 65
                        )
                    );
                  }).toList()
              ),
            (cards.length < 4)?
                Positioned(
                  left: (cards.length * (tableHeight * 3.5 / 18.6)),
                  top: (cards.length * (tableHeight * 0.5 / 7.8)),
                  child: Container(
                      height: (tableHeight * 5 / 7.8),//initially 100
                      width: (tableWidth * 5 / 18.6),//initially 65
                      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(tableHeight * 0.5 / 7.8)),
                      ),
                      child: Center(
                          child: Text('Next Player $yourTurn')
                      )
                  )
                )
            :
                Container()
              ]
      )
    );
  }
}

class PlayerScore extends StatelessWidget {
  final PlayerHearts player;

  const PlayerScore({Key key, this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          player.name + ': ',
          style: TextStyle(
            letterSpacing: 2.0,
            fontSize: 10,
            color: Colors.amberAccent,
          ),
        ),
        Text(
          '${player.pointsCount}',
          style: TextStyle(
            letterSpacing: 2.0,
            fontSize: 12,
            color: Colors.amber[700],
          ),
        ),
        Text(
          ' (${player.lapPoints})',
          style: TextStyle(
            letterSpacing: 2.0,
            fontSize: 12,
            color: Colors.amber[500],
          ),
        ),
      ],
    );
  }
}

class HeartsResults extends StatefulWidget {
  @override
  _HeartsResultsState createState() => _HeartsResultsState();
}

class _HeartsResultsState extends State<HeartsResults> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Over!!"),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          children: <Widget>[
            Text(
              "Results:",
              style: TextStyle(
                letterSpacing: 2.5,
                fontSize: 20,
                color: Colors.yellow[900],
              ),
            ),
            PlayerScore(player: players[0]),
            PlayerScore(player: players[1]),
            PlayerScore(player: players[2]),
            PlayerScore(player: players[3]),
            RaisedButton(
              onPressed: (){
                gameBegan = false;
                gameEnd = false;
                Navigator.pushNamed(context, '/HeartsLobby');
              },
              color: Colors.amber[500],
              child: Text("END GAME"),
            ),
          ],
        ),
      ),
    );
  }
}
