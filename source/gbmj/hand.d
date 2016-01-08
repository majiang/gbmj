module gbmj.hand;
import gbmj.tile, gbmj.meld;

import gbmj.internal : winds, dragons, characters, bamboos, dots, flowers, jokers, unknowns;

enum size_t setsInHand = 4;

/// The hand.
struct Hand
{
	Tile[] concealed;
	Meld[] melded;
	string toString()
	{
		import std.string : format;
		return "%(%s%)%(%s%)".format(concealed, melded);
	}
	this (Tile[] concealed, Meld[] melded)
	{
		this.concealed = concealed;
		this.melded = melded;
	}
	this (int[] wind, int[] dragon, int[] character, int[] bamboo, int[] dot, int[] flower)
	{
		this (
			wind.winds ~
			dragon.dragons ~
			character.characters ~
			bamboo.bamboos ~
			dot.dots ~
			flower.flowers, []);
	}
}
