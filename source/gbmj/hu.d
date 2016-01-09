module gbmj.hu;
import gbmj.hand;

import std.algorithm;

unittest
{
    auto standardHands = [
        "EwEw",
        "4b5b5b5b6b",
        "3d3d3d4d4d5d5d5d6d6d 4d",
        "3d3d3d4d4d5d5d5d6d6d 5d",
        "3d3d3d4d4d5d5d5d6d6d 6d",
        "3d3d3d4d4d5d5d5d6d6d 7d",
        "2c2c3c3c4c4c 5c5c 6c6c7c7c8c8c",
        "1c2c2c3c3c4c 5c5c 6c7c7c8c8c9c",
        "2c3c4c 6c7c8c EwEw 1d1d1d 1d2d3d"
    ];
    import gbmj.tile : readTiles;
    foreach (hand; standardHands)
        assert (hand.readTiles.concealAll.isStandardHu);
}

///
bool isHu(Hand hand)
{
    return hand.isStandardHu
        || hand.isKnittedStraightHu
        || (hand.hasNoMeldedSet
         && (hand.isSevenPairsHu
          || hand.isHonorsKnittedHu
          || hand.isThirteenOrphansHu));
}

/// Hu with a pair and sets.
bool isStandardHu(Hand hand)
{
    import gbmj.tile;
    auto suits = hand.concealed.concealedTileCounts.separateSuits;
    size_t pair;
    foreach (suit; honorSuits)
        pair += suits[suit].honorSets;
    foreach (suit; numericSuits)
        pair += suits[suit].numericSets;
    foreach (suit; specialSuits)
        pair += suits[suit].specialSets;
    return pair == 1;
}

enum IsSets : size_t
{
    noPair, foundPair, invalid
}

/// Test if a honor suit is a optional pair and sets.
IsSets honorSets(size_t[] suit)
{
    size_t pairs;
    foreach (tile; suit)
        if (tile == tilesInPair)
            pairs += 1;
        else if (tile % tilesInSet)
            return IsSets.invalid;
    return cast(IsSets)(pairs.min(IsSets.invalid));
}
/// Test if a numeric suit is a optional pair and sets.
IsSets numericSets(size_t[] suit)
{
    suit = suit.dup;
    // case without pair.
    if (suit.sum % tilesInSet == 0)
    {
        foreach (rank, ref count; suit)
        {
            if ((count %= tilesInSet) == 0) // remove pung(s).
                continue; // no tile of the rank remains.

            // no chow starts from rank. (e.g. [000000011])
            if (suit.length < rank + tilesInSet)
                return IsSets.invalid;

            // cannot remove chows. (e.g. [100000000])
            if (suit[rank+1..rank+tilesInSet].any!(c => c < count))
                return IsSets.invalid;

            // remove chows.
            suit[rank..rank+tilesInSet] -= count;
        }
        // all tiles is removed as pungs or chows.
        return IsSets.noPair;
    }

    // case with pair.
    foreach (i; 0..suit.length)
    {
        if (suit[i] < tilesInPair)
            continue;
        suit[i] -= tilesInPair; // remove pair.
        if (suit.numericSets == IsSets.noPair)
            return IsSets.foundPair; // success
        suit[i] += tilesInPair; // undo removal.
    }
    // no match.
    return IsSets.invalid;
}

IsSets specialSets(size_t[] suit)
{
    return suit.any ? IsSets.invalid : IsSets.noPair;
}

/// Hu with a pair, a set, and a knitted straight.
bool isKnittedStraightHu(Hand hand)
{assert (false);}

///
bool isThirteenOrphansHu(Hand hand)
in
{
    assert (hand.hasNoMeldedSet);
}
body
{
    assert (false);
}

/// Greater/Lesser honors and knitted tiles.
bool isHonorsKnittedHu(Hand hand)
in
{
    assert (hand.hasNoMeldedSet);
}
body
{
    assert (false);
}

///
bool isSevenPairsHu(Hand hand)
in
{
    assert (hand.hasNoMeldedSet);
}
body
{
    return hand.concealed.concealedTileCounts.all!(a => (a & 1) == 0);
    assert (false);
}
