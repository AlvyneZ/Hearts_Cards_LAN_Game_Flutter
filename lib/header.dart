import 'dart:async';
import 'dart:convert';
//import 'package:flutter/services.dart';
import 'package:wifi_access/wifi_access.dart';
import 'dart:io';

class PlayerHearts {
  //Object for holding details of one player in the game of hearts

  String name;
  InternetAddress ipAddress;
  int pointsCount;
  int lapPoints;
  List<String> cardsInHand;
  List<String> cardsTaken;

  void assignCards (List<String> hand, List<String> taken){
    //For when a player is connecting or reconnecting
    this.cardsInHand = hand;
    this.cardsTaken = taken;
  }

  PlayerHearts({this.name, this.pointsCount, this.lapPoints}){
    //Needed for List.add to work {check DartPad}
    this.cardsInHand = [];
    this.cardsTaken = [];
  }

}

void shuffler(List<PlayerHearts> player) {
  //Shuffles and distributes a full deck to 4 players (13 each)
  List<String> deck = ['2C','2D','2H','2S','3C','3D','3H','3S',
    '4C','4D','4H','4S','5C','5D','5H','5S','6C','6D','6H','6S',
    '7C','7D','7H','7S','8C','8D','8H','8S','9C','9D','9H','9S',
    'XC','XD','XH','XS','AC','AD','AH','AS','JC','JD','JH','JS',
    'KC','KD','KH','KS','QC','QD','QH','QS'
  ];

  deck..shuffle();

  for (int i = 0; i < player.length; i++) {
    player[i].cardsInHand = [];
    player[i].cardsTaken = [];
  }

  for (int i = 0; i < deck.length; i++) {
    player[i % player.length].cardsInHand.add(deck[i]);
  }
}


bool compareHeartsNum(String highest, String num) {
  //returns a true if num is greater than highest in the cards hierarchy

  int valHighest, valNum;
  switch (highest){
    case 'A': valHighest = 14; break;
    case 'K': valHighest = 13; break;
    case 'Q': valHighest = 12; break;
    case 'J': valHighest = 11; break;
    case 'X': valHighest = 10; break;
    case '9': valHighest = 9; break;
    case '8': valHighest = 8; break;
    case '7': valHighest = 7; break;
    case '6': valHighest = 6; break;
    case '5': valHighest = 5; break;
    case '4': valHighest = 4; break;
    case '3': valHighest = 3; break;
    case '2': valHighest = 2; break;
  }
  switch (num){
    case 'A': valNum = 14; break;
    case 'K': valNum = 13; break;
    case 'Q': valNum = 12; break;
    case 'J': valNum = 11; break;
    case 'X': valNum = 10; break;
    case '9': valNum = 9; break;
    case '8': valNum = 8; break;
    case '7': valNum = 7; break;
    case '6': valNum = 6; break;
    case '5': valNum = 5; break;
    case '4': valNum = 4; break;
    case '3': valNum = 3; break;
    case '2': valNum = 2; break;
  }
  if (valNum > valHighest){
    return true;
  }
  else{
    return false;
  }
}

int tallyHeartsPoints (List<String> cards){
  //Given the cards on the table after a round is played,
  //  this function gets the points the cards have
  int tally = 0;
  for (int i = 0; i < cards.length; i++){
    if (cards[i][1] == 'H'){
      tally ++;
      heartsIsBroken = true;
    }
    if (cards[i] == 'QS'){
      tally += 13;
      heartsIsBroken = true;
    }
    if (cards[i] == 'JD'){
      tally -= 10;
    }
  }
  return tally;
}

List<String> rearrange(List<String> cards){
  //Rearranges the way the order of cards is in the hand of the player
  List<String> newCards = [];
  List<int> newCardsVal = [];
  int cardValue = 0;
  for (int c = 0; c < cards.length; c++) {
    switch (cards[c][0]){
      case 'A': cardValue = 14; break;
      case 'K': cardValue = 13; break;
      case 'Q': cardValue = 12; break;
      case 'J': cardValue = 11; break;
      case 'X': cardValue = 10; break;
      case '9': cardValue = 9; break;
      case '8': cardValue = 8; break;
      case '7': cardValue = 7; break;
      case '6': cardValue = 6; break;
      case '5': cardValue = 5; break;
      case '4': cardValue = 4; break;
      case '3': cardValue = 3; break;
      case '2': cardValue = 2; break;
    }
    switch (cards[c][1]){
      case 'C': cardValue += 42; break;
      case 'D': cardValue += 28; break;
      case 'S': cardValue += 14; break;
    }
    bool added = false;
    for (int i = 0; i < newCards.length; i++) {
      if (cardValue > newCardsVal[i]){
        newCards.insert(i, cards[c]);
        newCardsVal.insert(i, cardValue);
        added = true;
        break;
      }
    }
    if (!added){
      newCards.add(cards[c]);
      newCardsVal.add(cardValue);
    }
  }
  //{DEBUGGING} print("Cards have been rearranged");
  update;
  return newCards;
}

bool playHeartsIsValid (bool heartsIsBroken, List<String> table, String playCard,int player, List<String> hand){
  //Checks if a play is valid as per the rules of the game
  //Returns a true if valid and a false if not allowed
  List<String> shapes = ['H','D','C','S'];
  List<bool> hasS = [false, false, false, false];
  for (int i = 0; i < hand.length; i++){
    for (int s = 0; s < shapes.length; s++){
      if (hand[i][1] == shapes[s]) hasS[s] = true;
    }
  }

  //{DEBUGGING} The @C below may be changed to C for easy debugging
  if (turn == -1) {
    if (playCard == '2C')
      return true;
    else
      return false;
  }
  else if (turn != player)
    return false;
  if (table.length >= players.length){
    return false;
  }
  else if (table.length == 0){
    if ((playCard == "QS") || (playCard[1] == 'H')){
      if ((heartsIsBroken) || (!hasS[1] && !hasS[2] && hasS[3]))
        //For player to be allowed to start with hearts
        //hearts must first be broken or they have only hearts in hand
        return true;
      else
        return false;
    }
    else
      return true;
  }
  else{
    if (((playCard == "QS") || (playCard[1] == 'H')) && (players[player].cardsInHand.length == 13)){
      return false;
    }
    int playShapeIndex = shapes.indexOf(table[0][1]);
    if (playCard[1] == table[0][1])
      return true;
    else if (!hasS[playShapeIndex])
      return true;
    else
      return false;
  }
}


//code {variables and functions} for communication between phones
bool isServer = false;
bool gameBegan = false, swapped = false, gameEnd = false;
List<bool> oppSwap = [false, false, false, false];
String server, myIPString = "waiting...";
bool heartsIsBroken = false;
bool connected = false, connectFail = false;
int me;
int turn = -1;
int lapCount = 0;
List<String> myOldSwapCards = [], myNewSwapCards = [];
List<String> table = [];
List<String> playersNames = [];
List<PlayerHearts> players = List(4); //fixed-length

//Stream for allowing updating of the screen at will
StreamController<int> updater = StreamController<int>.broadcast(); /*Should be type var and .broadcast*/
get update {
  return updater.add(0);
}/*Should be get update => updater.add(0);*/

RawDatagramSocket udp;
InternetAddress serverIP, myIP;
int port = 1999;
int connectedPlayers;

Future init() async {
  udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
  udp.writeEventsEnabled = false;
  udp.listen(onData);
}

onData(_){
  //function that runs when a packet is received
  var receivedPacket = udp.receive();
  List<int> dataTx = []; //dataTx should be of variable-length
  dataTx.addAll(receivedPacket.data); //since received packet data is fixed-length
  InternetAddress ipSource = receivedPacket.address;

  if (isServer){
    if (dataTx[0] == 0){
      //Connecting device to join game [received by server]
      bool alreadyConnected = false;
      int playerNo;
      for (int temp = 0; temp < connectedPlayers; temp++) {
        if (players[temp].ipAddress == ipSource) {
          alreadyConnected = true;
          playerNo = temp;
          break;
        }
      }
      if (alreadyConnected){
        udp.send([3, 0], ipSource, port);
        sendPlayersNames();
        if (gameBegan){
          sendSituation(playerNo, ipSource);
        }
      }
      else if (connectedPlayers < 4){
        dataTx.removeAt(0);
        players[connectedPlayers] = PlayerHearts(
          name: ascii.decode(dataTx), pointsCount: 0, lapPoints: 0
        );
        players[connectedPlayers].ipAddress = ipSource;
        playersNames.add(ascii.decode(dataTx));
        udp.send([3, 0], ipSource, port);
        connectedPlayers ++;
        sendPlayersNames(); //New players list sent to all players
      }
      else
        //Game has already reached max capacity
        udp.send([3, 1], ipSource, port);
    }
    else if (dataTx[0] == 1) {
      //Reconnecting device to rejoin game [received by server]
      int connectionNo = -1;
      for (int temp = 0; temp < connectedPlayers; temp++) {
        if (players[temp].ipAddress == ipSource) {
          connectionNo = temp;
          break;
        }
      }
      if (connectionNo != -1)
        sendPlayerDetail(connectionNo, ipSource);
      else
        udp.send([3, 1], ipSource, port);
    }
    else if (dataTx[0] == 2){
      //Swap being sent [received by server]
      //{DEBUGGING} print("Swap being received server side");
      int recipient;
      int sender = dataTx.removeAt(1);
      if ((lapCount % 4) == 0){ //Swap left
        recipient = (sender + 1) % 4;
      }
      else if ((lapCount % 4) == 1){ //Swap right
        recipient = (sender - 1) % 4;
      }
      else if ((lapCount % 4) == 2){ //Swap across
        recipient = (sender + 2) % 4;
      }

      if (recipient != 0) {
      //{DEBUGGING} if (players[recipient].ipAddress != myIP){
        udp.send(dataTx, players[recipient].ipAddress, port);
        //{DEBUGGING} print("Swap being sent from server to: ${players[recipient].ipAddress.address}");
      }
      dataTx.removeAt(0);
      String card = "", temp = ascii.decode(dataTx);
      for (int i = 0; i < temp.length; i ++){
        if (i%2 == 0) card = temp[i];
        else {
          card += temp[i];
          players[sender].cardsInHand.remove(card);
          oppSwap[sender] = true;
          if (recipient == 0) {
            //Swap sent for server phone
            if (swapped)
              players[me].cardsInHand.add(card);
            else
              myNewSwapCards.add(card);
          }
          else
            players[recipient].cardsInHand.add(card);
        }
      }
    }
    else if (dataTx[0] == 3){
      //Play being sent [received by server]
      int player = dataTx.removeAt(1);
      dataTx.removeAt(0);
      String playCard = ascii.decode(dataTx);
      if (playHeartsIsValid(heartsIsBroken, table, playCard,player, players[player].cardsInHand)){
        table.add(playCard);
        players[player].cardsInHand.remove(playCard);
        turn = ((player + 1) % players.length);
        String temp = '';
        for (int i = 0; i < table.length; i++) {
          temp += table[i][0] + table[i][1];
        }
        //Sending the new table to every player so as to update table
        dataTx = [6, turn];
        dataTx.addAll(ascii.encode(temp));
        for (int i = 1; i < connectedPlayers; i++){
          udp.send(dataTx, players[i].ipAddress, port);
          //{DEBUGGING} print ("Table Data sent to: ${players[i].ipAddress.address}");
        }
        if (table.length == players.length){
          //ie after the play, the table is full => new round
          fullTable();
        }
      }
    }
  }
  else {
    if (dataTx[0] == 0){
      //Player scores being received [sent from server]
      dataTx.removeAt(0);
      if (dataTx[0] == 0) {
        dataTx.removeAt(0);
        for (int i = 0; i < players.length; i++) {
          players[i].pointsCount = dataTx[2*i];
          if (dataTx[(2*i)+8] == 1) players[i].pointsCount -=256;
          players[i].lapPoints = dataTx[(2*i)+1];
          if (dataTx[(2*i)+9] == 1) players[i].lapPoints -=256;
        }
      }
      else if (dataTx[0] == 1){
        dataTx.removeAt(0);
        String temp = ascii.decode(dataTx);
        players[me].cardsTaken = [];
        for (int i = 0; (i * 2) < temp.length; i++) {
          players[me].cardsTaken.add("${temp[2*i]}${temp[(2*i)+1]}");
        }
      }
    }
    else if (dataTx[0] == 1){
      //End of  a round[0] or lap[1] or game over[2]
      if (dataTx[1] == 0){
        turn = dataTx[2];
        if (dataTx[3] == 1) heartsIsBroken = true;
      }
      else if (dataTx[1] == 1){
        lapCount++;
        heartsIsBroken = false;
        myOldSwapCards = []; myNewSwapCards = [];
        if ((lapCount % 4) != 3)
          swapped = false;
        turn = -1;
      }
      else if (dataTx[1] == 2){
        gameEnd = true;
      }
      Future.delayed(const Duration(milliseconds: 2500), () {
        table = [];
        update;
      });
    }
    else if (dataTx[0] == 2){
      //Swap cards being received [sent from server]
      dataTx.removeAt(0);
      String card = "", temp = ascii.decode(dataTx);
      for (int i = 0; i < temp.length; i ++){
        if (i%2 == 0) card = temp[i];
        else {
          card += temp[i];
          if (swapped)
            players[me].cardsInHand.add(card);
          else
            myNewSwapCards.add(card);
        }
      }
      update;
      //{DEBUGGING} print("Swap cards received");
    }
    else if (dataTx[0] == 3) {
      //Connection Confirmation [sent from server]
      if (dataTx[1] == 0) {
        connected = true;
        connectFail = false;
      }
      else if (dataTx[1] == 1) {
        connectFail = true;
        connected = false;
      }
      else if (dataTx[1] == 2) {
        dataTx.removeAt(1); dataTx.removeAt(0);
        String temp = ascii.decode(dataTx);
        int stInd = 0;
        playersNames = [];
        for (int i = 0; i < temp.length; i++){
          if (temp[i] == ";"){
            playersNames.add(temp.substring(stInd, i));
            stInd = i + 1;
          }
        }
      }
    }
    else if (dataTx[0] == 4) {
      //{DEBUGGING} print("Player Detail beginning to be received");
      //Player data being sent [sent from server]
      me = dataTx.removeAt(1);
      //{DEBUGGING} print("Iam player number: ${me}");
      dataTx.removeAt(0);
      initPlayersDetails(dataTx);
      gameBegan = true;
      //{DEBUGGING} print("Player Detail received");
    }
    else if (dataTx[0] == 5){
      //Game situation [sent from server]
      swapped = false;
      if (dataTx[1] == 1) swapped = true;
      heartsIsBroken = false;
      if (dataTx[2] == 1) heartsIsBroken = true;
      lapCount = dataTx[3];
    }
    else if (dataTx[0] == 6) {
      //Table data being sent [received from server]
      turn = dataTx.removeAt(1);
      dataTx.removeAt(0);
      String temp = ascii.decode(dataTx);
      List<String> lstTemp = [];
      for (int i = 0; i < temp.length; i+=2) {
        lstTemp.add(temp[i] + temp[i+1]);
      }
      table = lstTemp;
      //{DEBUGGING} print("Table data received");
    }
  }

  update;
}

start(String playerName) async {
  //{DEBUGGING} print ("This is the ip: $myIPString");
  myIP = InternetAddress(myIPString);
  serverIP = InternetAddress(server);
  if (myIPString == server) {
    me = 0;
    myIP = serverIP;
    isServer = true;
    connected = true;
    if (!gameBegan) {
      connectedPlayers = 1; //Since server phone is also a player
      players[0] = PlayerHearts(name: playerName, lapPoints: 0, pointsCount: 0);
      players[0].ipAddress = serverIP;
      playersNames = [];
      playersNames.add(playerName);
    }
  } else {
    connected = false;
    isServer = false;
    List<int> data = [0];
    data.addAll(ascii.encode(playerName));
    udp.send(data, serverIP, port);
  }
  update;
}

selfIP () async {
  String ip = (await WifiAccess.dhcp).ip;
  myIPString = ip;
  update;
}


void beginNewGame(){
  turn = -1;
  lapCount = 0;
  table = [];
  //{DEBUGGING} [if only 2 phones:] playersNames.addAll(["Mwaniki","Zacharia"]);
  for (int i = 0; i < players.length; i++){
    //{DEBUGGING} if (i >= 2) {
    //{DEBUGGING}   players[i] = PlayerHearts(name: playersNames[i], lapPoints: 0, pointsCount: 0);
    //{DEBUGGING}   players[i].ipAddress = InternetAddress("192.168.0.16");
    //{DEBUGGING} }
    players[i].cardsInHand = [];
    players[i].cardsTaken = [];
  }
  //{DEBUGGING} sendPlayersNames();
  heartsIsBroken = false;
  swapped = false;
  shuffler(players);

  //{DEBUGGING} print("Game has began");
  for (int i = 1; i < players.length; i++){
    sendPlayerDetail(i, players[i].ipAddress);
  }
  gameBegan = true;
  //{DEBUGGING} print("Game has began");
}

void sendPlayerDetail(int player, InternetAddress destination){
  //Server Sending encoded player detail to a player
  String toSend = '';
  List<String> temp = players[player].cardsInHand;
  for (int i = 0; i < temp.length; i++){
    toSend += temp[i];
  }
  toSend += ';';
  temp = players[player].cardsTaken;
  for (int i = 0; i < temp.length; i++){
    toSend += temp[i];
  }
  toSend += ';';
  toSend += '${players[player].pointsCount}';
  toSend += ';';
  toSend += '${players[player].lapPoints}';
  toSend += ';';
  toSend += players[player].name;
  List<int> tx = [4, player];
  tx.addAll(ascii.encode(toSend));
  udp.send (tx, destination, port);
  //{DEBUGGING} print ("Player Detail sent to ${destination.address}");
}

void initPlayersDetails(List<int> code){
  //Client phone receiving player data from server
  for (int i = 0; i < players.length; i++){
      players[i] = PlayerHearts(name:playersNames[i], pointsCount: 0, lapPoints: 0);
  }
  String letters = ascii.decode(code);
  PlayerHearts out = PlayerHearts(name: '',pointsCount: 0, lapPoints: 0);
  out.cardsInHand = []; out.cardsTaken = [];
  String tempStr = '';
  int section = 0;
  bool negative = false;
  for (int i = 0; i < letters.length; i ++){
    if ((section < 4) && (letters[i] == ';')) {
      if ((section==2) && (negative)) out.pointsCount = 0 - out.pointsCount;
      if ((section==3) && (negative)) out.lapPoints = 0 - out.lapPoints;
      section++;
      tempStr = '';
      negative = false;
    }
    else if (section == 0){
      tempStr = letters[i] + letters[++i];
      out.cardsInHand.add(tempStr);
    }
    else if (section == 1){
      tempStr = letters[i] + letters[++i];
      out.cardsTaken.add(tempStr);
    }
    else if (section == 2){
      if (letters[i] == '-') {
        negative = true;
        i++;
      }
      out.pointsCount = (out.pointsCount * 10) + int.parse(letters[i]);
    }
    else if (section == 3){
      if (letters[i] == '-') {
        negative = true;
        i++;
      }
      out.lapPoints = (out.lapPoints * 10) + int.parse(letters[i]);
    }
    else if (section == 4){
      out.name = "${out.name}${letters[i]}";
    }
  }
  players[me] = out;
}

void sendPlayersNames(){
  String text = '';
  for (int i = 0; i < playersNames.length; i++){
    text = ("$text${playersNames[i]};");
  }
  List<int> code = [3,2];
  code.addAll(ascii.encode(text));
  for (int i = 1; i < playersNames.length; i++){
    udp.send(code, players[i].ipAddress, port);
  }
}

void sendPlayersScores(){
  List<int> code = [0, 0];
  for (int i = 0; i < players.length; i++){
    code.add(players[i].pointsCount);
    code.add(players[i].lapPoints);
  }
  for (int i = 0; i < players.length; i++){
    code.add((players[i].pointsCount < 0) ? 1: 0);
    code.add((players[i].lapPoints < 0) ? 1: 0);
  }
  for (int i = 0; i < players.length; i++){
    udp.send(code, players[i].ipAddress, port);
  }
}

void sendCardsTaken(int player){
  List<int> code = [0, 1];
  String temp = '';
  for (int i = 0; i < players[player].cardsTaken.length; i++){
    temp += players[player].cardsTaken[i];
  }
  code.addAll(ascii.encode(temp));
  udp.send(code, players[player].ipAddress, port);
}

void fullTable(){
  String shape = table[0][1];
  String number = table[0][0];
  int taking = turn;
  //default person taking is the one who played first in that round
  for (int i = 1; i < players.length; i++) {
    if (table[i][1] == shape) {
      if (compareHeartsNum(number, table[i][0])) {
        taking = ((turn + i) % players.length);
        number = table[i][0];
      }
    }
  }
  players[taking].cardsTaken.addAll(table);
  players[taking].lapPoints += tallyHeartsPoints(table);
  turn = taking;
  Future.delayed(const Duration(milliseconds: 2500), () {
    table = []; //Delayed so the last play of the round may be seen
    update;
  });

  for (int i = 0; i < players.length; i++){
    int hIB = 0; if(heartsIsBroken) hIB = 1;
    udp.send([1,0,turn,hIB], players[i].ipAddress, port);
  }
  sendPlayersScores();
  if (taking != me)
    sendCardsTaken(taking);

  if (players[taking].cardsInHand.length == 0) {
    //If lap has ended ie no one has any more cards
    bool geniusTS = false;
    for (int i = 0; i < players.length; i++) {
      if (players[i].lapPoints == 26) {
        geniusTS = true;
        break;
      }
    }
    for(int i = 0; i < players.length; i++){
      if (geniusTS){
        if (players[i].lapPoints == 26){
          players[i].lapPoints = 0;
        }
        else{
          players[i].lapPoints += 26;
        }
      }
      players[i].pointsCount += players[i].lapPoints;
      players[i].lapPoints = 0;
    }
    turn = -1;
    heartsIsBroken = false;
    myOldSwapCards = []; myNewSwapCards = [];
    shuffler(players);
    //Checking if someone has gotten to 100pts => Game Over
    for(int i = 0; i < players.length; i++){
      if (players[i].pointsCount >= 100){
        gameEnd = true;
      }
    }

    for (int i = 0; i < players.length; i++){
      if (!gameEnd) {
        lapCount++;
        if ((lapCount % 4) != 3) {
          swapped = false;
          oppSwap = [false, false, false, false];
        }
        udp.send([1, 1], players[i].ipAddress, port);
        sendPlayerDetail(i, players[i].ipAddress);
      }
      else{
        udp.send([1, 2], players[i].ipAddress, port);
      }
    }
    sendPlayersScores();
  }
}

void sendSwapCards(){
  String cards = "";
  for (int i = 0; i < myOldSwapCards.length; i ++){
    cards = "$cards${myOldSwapCards[i]}";
  }
  List<int> code = [2, me];
  code.addAll(ascii.encode(cards));
  for (int i = 0; i < myOldSwapCards.length; i ++){
    players[me].cardsInHand.remove(myOldSwapCards[i]);
  }
  udp.send(code, serverIP, port);
  if (myNewSwapCards != []){
    for (int i = 0; i < myNewSwapCards.length; i ++){
      players[me].cardsInHand.add(myNewSwapCards[i]);
    }
    myNewSwapCards = [];
  }
  swapped = true;
  myOldSwapCards = [];
  //{DEBUGGING} print("Sent Swap Cards");
}

void sendPlayCard(String cardToPlay){
  if (isServer){
    table.add(cardToPlay);
    players[0].cardsInHand.remove(cardToPlay);
    turn = 1;
    String temp = '';
    for (int i = 0; i < table.length; i++) {
      temp += table[i][0] + table[i][1];
    }
    //Sending the new table to every player so as to update table
    List<int> tx = [6,turn];
    tx.addAll(ascii.encode(temp));
    for (int i = 1; i < connectedPlayers; i++){
      udp.send(tx, players[i].ipAddress, port);
      //{DEBUGGING} print("New table sent to: ${players[i].ipAddress.address}");
    }
    if (table.length == players.length){
      //ie after the play, the table is full => new round
      fullTable();
    }
  }
  else{
    List<int> code = [3,me];
    code.addAll(ascii.encode(cardToPlay));
    players[me].cardsInHand.remove(cardToPlay);
    udp.send(code, serverIP, port);
    //{DEBUGGING} print ("Play Card sent");
  }
}

void sendSituation (int player,InternetAddress destination){
  //Function for sending the started game's situation to a reconnecting player
  //player name have already been sent during reconnection
  //Sending the player's details. ie cards & Pts & gameBegan condition
  sendPlayerDetail(player, destination);
  //Sending the table and turn to the reconnecting player
  List<int> tx;
  String temp = '';
  for (int i = 0; i < table.length; i++) {
    temp += table[i][0] + table[i][1];
  }
  tx = [6, turn];
  tx.addAll(ascii.encode(temp));
  udp.send(tx, destination, port);
  //{DEBUGGING} print ("Table Data sent to: ${ipSource}");
  sendPlayersScores();
  //Sending the player's swapped condition, game's heartsBroken condition, and lapCount
  tx = [5];
  if (oppSwap[player]) tx.add(1);
  else tx.add(0);
  if (heartsIsBroken) tx.add(1);
  else tx.add(0);
  tx.add(lapCount);

}