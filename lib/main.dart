import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'header.dart';

String cardToPlay = '';
String playerName = 'Name';

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
            StreamBuilder(stream: updater.stream, builder: (_, s) => HeartsInit()),
        '/HeartsLobby' : (context) =>
            StreamBuilder(stream: updater.stream, builder: (_, s) => HeartsLobby()),
        '/HeartsGame' : (context) =>
            StreamBuilder(stream: updater.stream, builder: (_, s) => Hearts(title: 'Hearts')),
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
      body: Container(
        padding: EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Player name",
                  contentPadding: EdgeInsets.all(15.0),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (String value){
                  if(value.isEmpty){
                    return "Enter your player name";
                  }
                  return null;
                },
                onSaved: (String value){
                  playerName = value;
                },
              ),
              Text(
                "Your IP adress is: $myIPString",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700]
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Server IP address",
                  contentPadding: EdgeInsets.all(15.0),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.number,
                validator: (String value){
                  if(value.isEmpty){
                    return "Enter the server's IP Address in the form d.d.d.d";
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
              RaisedButton(
                color: Colors.blueAccent,
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
                    color: Colors.white,
                  ),
                ),
              )
            ],
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
    if (isServer) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Hearts Game Lobby"),
        ),
        body: Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Text("You are the server"),
              Text("Server IP: $server"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: playersNames.map((pl) {
                  return Text(pl);
                }).toList()
              ),
              RaisedButton(
                color: Colors.amber[500],
                onPressed: (gameBegan?null:(){
                  //{DEBUGGING} remove connected players condition if less phones available
                  if (connectedPlayers == 4){
                    beginNewGame();
                    Navigator.pushNamed(context, '/HeartsGame');
                  }else{return null;}
                }),
                child: Text('Begin Game'),
              ),
              RaisedButton(
                color: Colors.amber[500],
                onPressed: (gameBegan?(){Navigator.pushNamed(context, '/HeartsGame');}:null),
                child: Text('Connect to Game'),
              ),
            ],
          ),
        ),
      );
    }
    else{
      if (connected) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Hearts Game Lobby"),
          ),
          body: Container(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                Text("You are connected to the server"),
                Text("Server IP: $server"),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: playersNames.map((pl) {
                      return Text(pl);
                    }).toList()
                ),
                RaisedButton(
                  color: Colors.amber[500],
                  onPressed: (gameBegan?(){Navigator.pushNamed(context, '/HeartsGame');}:null),
                  child: Text('Connect to Game'),
                ),
              ],
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
      if (((turn == me) || (turn == -1)) && (cardToPlay != ''))
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.green[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TableCards(cards: table),
              //To show the table with the cards that have been played
              Container(
                //To show the cards in hand of the player
                height: 200.0,
                child: StreamBuilder(stream: updater.stream, builder: (_, s) => PlayerCards(playerCards: players[me].cardsInHand)),
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
                child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: players[me].cardsTaken.map((card) {
                        return Expanded(
                            flex: 1,
                            child: Image.asset('assets/red_back.png')
                        );
                      }).toList(),
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
  int cardsNo;
  double count = -1;
  DragCard toRet;

  @override
  void initState(){
    super.initState();
    cardsNo = widget.playerCards.length;
  }

  @override
  Widget build(BuildContext context) {
    cardsNo = players[me].cardsInHand.length;
    if (cardsNo != 0) {
      return Stack(
        children: <Widget> [
          Stack(
            children: widget.playerCards.map((card) {
              count += 1.0;
              if (count < (cardsNo / 2)) {
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
                  initPos: Offset(((count - (cardsNo/2)) * 50.0), 76.0),
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
                            width: (55.0 * (cardsNo / 2)),
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
                          width: (55.0 * (cardsNo / 2)),
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
                            width: (55.0 * (cardsNo / 2)),
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
                          width: (55.0 * (cardsNo / 2)),
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
    String yourTurn = "Next Player";
    if (turn == me) yourTurn = "Your Turn";
    if (cards.length == 0) {
      return Container(
        height: 120,
        width: 235,
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(10.0),
        color:Colors.brown[600],
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0.0,
              top: 0.0,
              child: Container(
                  height: 100.0,
                  width: 65.0,
                  padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                  color: Colors.grey[700],
                  child: Center(
                      child: Text('First Player')
                  )
              )
            )
          ]
        )
      );
    }
    else{
      int count = -1;
      return Container(
        height: 120,
        width: 235,
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(10.0),
        color:Colors.brown[600],
        child: Stack(
            children:<Widget>[
              Stack(
                children: cards.map((card) {
                  count ++;
                  return Positioned(
                    left: (count * 50.0),
                    top: 0.0,
                    child: CardImage(
                      card: card,
                      heightImg: 100.0,
                      widthImg: 65.0,
                    )
                  );
                }).toList()
              ),
              Positioned(
                left: (cards.length * 50.0),
                top: 0.0,
                child: Container(
                  height: 100.0,
                  width: 65.0,
                  padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                  color: Colors.grey[700],
                  child: Center(
                    child: Text('$yourTurn')
                  )
                )
              )
            ]
        )
      );
    }
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
            fontSize: 12,
            color: Colors.amberAccent,
          ),
        ),
        Text(
          '${player.pointsCount}',
          style: TextStyle(
            letterSpacing: 2.0,
            fontSize: 15,
            color: Colors.amber[700],
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
