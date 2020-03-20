# flutter_app

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.




This code is for a hearts game

Hearts is a card game that is played with the main intention of
    having least points.
Each hearts card is worth one point.
The Queen of Spades is worth 13 points.

Each lap begins with all 52 cards of the deck being shuffled and
    distributed equally among the 4 players, each getting 13 cards.
For the first lap, each player picks 3 cards to give the player to
    their left and gets 3 replacement cards from the player to
    their right.
For the second lap, cards are passed to the right.
For the third lap, cards are passed across the table.
The fourth lap has no cards swapping.
This swapping pattern then repeats.

The first card of each lap is always a 2 of cloves.
The player with this card starts and all other players are to play
    the same shape unless they lack it (in which case one may play
    any other shape).
The game always goes clockwise with the table having a maximum of
    4 cards at a time (each player only plays once a round).
At the end of each round (when there are 4 cards on the table),
    the player who placed the largest card of the same shape as the
    first card of that round takes the cards.
The taken cards are not mixed with those at hand.
Points for each player are counted from the cards taken and not
    those at hand.
The player who takes the cards begins the next round.

The first card of any round can only be a hearts if hearts have been
    broken (someone plays a hearts sometime in that lap) or when the
    starting player has no other shape.

The game comes to an end when a player gets to 100 points.