module gbmj.tile;

import std.algorithm;

/// Typecode for the suit of a tile.
enum Suit
{
	wind, dragon, character, bamboo, dot, flower, joker, unknown
}

/// Type for the rank of a tile.
alias Rank = uint;


// Whether the rule use flower tiles or not.
version (PWS) version = UseFlower;
version (WMO) version = UseFlower;
version (JMSA) version = NoFlower;

/// The number of different tiles of a suit.
version (UseFlower) enum Rank[] maxOfSuit = [
	4, 3, 9, 9, 9, 8, 0, 1];
version (NoFlower) enum Rank[] maxOfSuit = [
	4, 3, 9, 9, 9, 0, 0, 1];

/// The number of duplications of a tile.
enum duplicationOfSuit = [
	4, 4, 4, 4, 4, 1, 0, 0];

///
struct Tile
{
	Suit suit;
	Rank rank;
	invariant
	{
		assert (rank < maxOfSuit[suit]);
		assert (suit != Suit.joker); // joker is not supported.
	}
	/// opCmp for sorting
	int opCmp(Tile rhs)
	{
		if (this.suit < rhs.suit)
			return -1;
		if (this.suit > rhs.suit)
			return 1;
		if (this.rank < rhs.rank)
			return -1;
		if (this.rank > rhs.rank)
			return 1;
		return 0;
	}
	import std.format : FormatSpec;
	/** String representation.

	Params:
		sink = continuation
		fmt = spec 'c' for unicode character representation; other for ascii two-character representation.
	*/
	void toString(
		scope void delegate(const(char)[]) sink,
		FormatSpec!char fmt) const
	{
		import std.conv : to;
		if (fmt.spec == 'c')
			sink([this.toUnicodeChar].to!(char[]));
		else
			sink(this.toAsciiString);
	}
	string toString()
	{
		string ret;
		toString((const(char)[] res){ret = res.idup;}, FormatSpec!char("%s"));
		return ret;
	}
}

///
bool isNumeric(Tile tile)
{
	return tile.suit == Suit.character
		|| tile.suit == Suit.bamboo
		|| tile.suit == Suit.dot;
}

///
bool isHonor(Tile tile)
{
	return tile.suit == Suit.wind
		|| tile.suit == Suit.dragon;
}

///
bool isSimple(Tile tile)
{
	if (!tile.isNumeric)
		return false;
	return 0 < tile.rank && tile.rank < maxOfSuit[tile.suit];
}

///
bool isTerminal(Tile tile)
{
	return tile.isNumeric && !tile.isSimple;
}

///
bool isFlower(Tile tile)
{
	return tile.suit == Suit.flower;
}

///
bool isJoker(Tile tile)
{
	return tile.suit == Suit.joker;
}

///
bool isKnown(Tile tile)
{
	return tile.suit != Suit.unknown;
}

private bool isGreenDragon(Tile tile)
{
	return tile.suit == Suit.dragon
		&& tile.rank == 1;
}

///
bool isGreen(Tile tile)
{
	if (tile.suit == Suit.bamboo)
		return [2, 3, 4, 6, 8].canFind(tile.rank + 1);
	return tile.isGreenDragon;
}

private bool isWhiteDragon(Tile tile)
{
	return tile.suit == Suit.dragon
		&& tile.rank == 2;
}

///
bool isReversible(Tile tile)
{
	if (tile.suit == Suit.bamboo)
		return [2, 4, 5, 6, 8, 9].canFind(tile.rank + 1);
	if (tile.suit == Suit.dot)      // 1234589 of dots
		return [1, 2, 3, 4, 5, 8, 9].canFind(tile.rank + 1);
	return tile.isWhiteDragon;
}

enum dchar[] unicodeOffsetOfSuit = [
	0x1F000, // East wind
	0x1F004, // Red dragon
	0x1F007, // 1 character
	0x1F010, // 1 bamboo
	0x1F019, // 1 dot
	0x1F022, // plum (mei) flower (mei)
	0x1F02A, // joker (baida)
	0x1F02B];// back

dchar toUnicodeChar(Tile tile)
{
	return unicodeOffsetOfSuit[tile.suit] + tile.rank;
}

string toAsciiString(Tile tile)
{
	immutable rank = tile.rank;
	import std.conv : to;
	final switch (tile.suit)
	{
		case Suit.wind:
			return "ESWN"[rank] ~ "w";
		case Suit.dragon:
			return "RGW"[rank] ~ "d";
		case Suit.character:
			return (rank+1).to!string ~ "c";
		case Suit.bamboo:
			return (rank+1).to!string ~ "b";
		case Suit.dot:
			return (rank+1).to!string ~ "d";
		case Suit.flower:
			return "Fl";
		case Suit.joker:
			return "JK";
		case Suit.unknown:
			return "--";
	}
}
