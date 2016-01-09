/** Uncategorized utility functions for internal usage. */
module gbmj.internal;
import gbmj.tile, gbmj.meld;
import std.algorithm, std.range, std.array;

package:

string _generateOneTile(string suit)
{
    import std.string : format;
    return "auto %1$s(T)(in T rank){return Tile(Suit.%1$s, cast(ushort)rank);}".format(suit);
}
mixin (_generateOneTile("wind"));
mixin (_generateOneTile("dragon"));
mixin (_generateOneTile("character"));
mixin (_generateOneTile("bamboo"));
mixin (_generateOneTile("dot"));
mixin (_generateOneTile("flower"));
auto joker(){return Tile(Suit.joker, 0);}
auto unknown(){return Tile(Suit.unknown, 0);}

string _generateTiles(string suit)
{
    import std.string : format;
    return "auto %1$ss(T)(in T[] ranks...){Tile[] ret;foreach (rank; ranks)ret ~= Tile(Suit.%1$s, cast(ushort)rank);return ret;}".format(suit);
}
mixin (_generateTiles("wind"));
mixin (_generateTiles("dragon"));
mixin (_generateTiles("character"));
mixin (_generateTiles("bamboo"));
mixin (_generateTiles("dot"));
mixin (_generateTiles("flower"));
auto jokers(in size_t n){return joker.repeat(n).array;}
auto unknowns(in size_t n){return unknown.repeat(n).array;}

string _generateMeld(string meldType)
{
    import std.string : format;
    return "auto %1$s(Tile tile){return Meld(MeldType.%1$s, tile);}".format(meldType);
}
mixin (_generateMeld("pungRight"));
mixin (_generateMeld("pungOpposite"));
mixin (_generateMeld("pungLeft"));
mixin (_generateMeld("kongRight"));
mixin (_generateMeld("kongOpposite"));
mixin (_generateMeld("kongLeft"));
mixin (_generateMeld("kongSelf"));
mixin (_generateMeld("pungRightKong"));
mixin (_generateMeld("pungOppositeKong"));
mixin (_generateMeld("pungLeftKong"));
mixin (_generateMeld("chowLow"));
mixin (_generateMeld("chowMiddle"));
mixin (_generateMeld("chowHigh"));
mixin (_generateMeld("flower"));

Tile low(Tile tile)
in
{
    assert (tile.isNumeric);
}
body
{
    return Tile(tile.suit, cast(ushort)(tile.rank - 1));
}
Tile high(Tile tile)
in
{
    assert (tile.isNumeric);
}
body
{
    return Tile(tile.suit, cast(ushort)(tile.rank + 1));
}

