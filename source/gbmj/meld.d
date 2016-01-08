module gbmj.meld;
import gbmj.tile;

import gbmj.internal : low, high;

///
enum MeldType
{
	pungRight = 4, pungOpposite, pungLeft,
	kongRight = 8, kongOpposite, kongLeft, kongSelf,
	pungRightKong = 12, pungOppositeKong, pungLeftKong,
	chowLow = 16, chowMiddle, chowHigh,
	flower = 32
}

///
struct Meld
{
	MeldType meldType;
	Tile tile; // the center of the tile.
	string toString()
	{
		import std.string : format;
		switch (meldType)
		{
			case MeldType.pungRight: .. case MeldType.pungLeftKong: return [
				MeldType.pungRight:"[%1$s%1$s[%1$s]]",
				MeldType.pungOpposite:"[%1$s[%1$s]%1$s]",
				MeldType.pungLeft:"[[%1$s]%1$s%1$s]",
				MeldType.kongRight:"[%1$s%1$s%1$s[%1$s]]",
				MeldType.kongOpposite:"[%1$s[%1$s]%1$s%1$s]",
				MeldType.kongLeft:"[[%1$s]%1$s%1$s%1$s]",
				MeldType.kongSelf:"[%1$s%1$s%1$s%1$s]",
				MeldType.pungRightKong:"[%1$s%1$s[%1$s%1$s]]",
				MeldType.pungOppositeKong:"[%1$s[%1$s%1$s]%1$s]",
				MeldType.pungLeftKong:"[[%1$s%1$s]%1$s%1$s]"]
			[meldType].format(tile.toString);
			case MeldType.chowLow: return "[[%s]%s%s]".format(tile.low, tile, tile.high);
			case MeldType.chowMiddle: return "[[%s]%s%s]".format(tile, tile.low, tile.high);
			case MeldType.chowHigh: return "[[%s]%s%s]".format(tile.high, tile.low, tile);
			default:
				assert (false);
		}
	}
}
