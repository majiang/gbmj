module gbmj.hand;
import gbmj.tile, gbmj.meld;

import gbmj.internal : winds, dragons, characters, bamboos, dots, flowers, jokers, unknowns;

import std.traits : EnumMembers;

enum size_t
    setsInHand = 4,
    tilesInSet = 3,
    tilesInPair = 2;

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

Hand concealAll(Tile[] tiles)
{
    return Hand(tiles, []);
}

/// Count the tiles in a hand. Count kongs as pungs.
size_t allTileCounts(Hand hand)
{
    import std.algorithm : filter;
    import std.range : walkLength;
    return hand.concealed.length
        + hand.melded.filter!isSet.walkLength * tilesInSet;
}

/// Convert an array of concealed tiles to the array of tile counts.
size_t[] concealedTileCounts(Tile[] concealedTiles)
{
    size_t[] ret;
    foreach (suit; EnumMembers!Suit)
        ret.length += tilePositionOffset[suit];
    foreach (tile; concealedTiles)
        ret[tilePositionOffset[tile.suit] + tile.rank] += 1;
    return ret;
}

///
size_t[][] separateSuits(size_t[] tileCounts)
{
    size_t[][] ret;
    foreach (suit; EnumMembers!Suit)
        ret ~= tileCounts[
            tilePositionOffset[suit]..tilePositionOffset[suit + 1]];
    return ret;
}

/// Check if a hand has no melded set, including concealed kongs.
bool hasNoMeldedSet(Hand hand)
{
    import std.algorithm : all;
    return hand.melded.all!(meld => meld.meldType == MeldType.flower);
}
