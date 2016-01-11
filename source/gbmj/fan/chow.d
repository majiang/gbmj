module gbmj.fan.chow;
import gbmj.fan, gbmj.tile;

import std.algorithm, std.range, std.array;
import core.bitop : popcnt;

/** All chow-fan

Params:
    chows = the array of center tiles of chows in a hand.
Returns:
    the array of all chow-fans.
*/
Fan[] chowAll(Tile[] chows)
{
    Fan[] fans;
    /* Flags for handling the inclusion of chow-fans, e.g.
    the inclusion between triple chows and quadruple chows.
    */
    size_t used;

    // Find larger fans first, and then smaller fans.
    foreach_reverse (i, c; _choose[chows.length])
    {
        if (i == 1)
            break;
        // p indicates the focused combination of chows.
        foreach (p; c)
        {
            // combination with more than one used chows.
            if (1 < (p & used).popcnt)
                continue;
            Fan[] found;
            switch (i) // TODO: maybe polymorphism is better than switch.
            {
                case 2: found = chows.choose(p).chow2; break;
                case 3: found = chows.choose(p).chow3; break;
                case 4: found = chows.choose(p).chow4; break;
                default: assert (false);
            }
            if (found.empty)
                continue;
            // mark used chows.
            used |= p;
            fans ~= found;
        }
    }
    return fans;
}
auto choose(T)(T[] arr, ulong p)
{
    return arr.length.iota.filter!(i => p >> i & 1).map!(i => arr[i]).array;
}
import gbmj.hand: setsInHand;
private enum _choose = setsInHand.makeChoose;

private auto makeChoose(size_t maxChows)
{
    auto ret = new size_t[][][](maxChows+1, 0, 0);
    foreach (i, ref table; ret)
    {
        // if (i <= 1) continue; // no (0|1)-chow-fans
        table.length = i + 1;
        foreach (j; 0..(1 << i))
            table[j.popcnt] ~= j;
    }
    return ret;
}
///
Fan[] chow4(Tile[] chows)
in
{
    assert (chows.length == 4);
    assert (chows.all!isNumeric);
}
body
{
    if (!chows.equalSuit)
        return [];
    auto d = chows.ranks.array.sort().differences;
    if (!d.allEqual)
        return [];
    return [[Fan.quadrupleChow, Fan.fourPureShiftedChows, Fan.fourPureShiftedChows][d.front]];
}
///
Fan[] chow3(Tile[] chows)
in
{
    assert (chows.length == 3);
    assert (chows.all!isNumeric);
}
body
{
    if (chows.equalSuit)
    {
        auto d = chows.ranks.differences;
        if (!d.allEqual)
            return [];
        return [[Fan.pureTripleChow, Fan.pureShiftedChows, Fan.pureShiftedChows, Fan.pureStraight][d.front]];
    }
    if (!chows.differentSuit)
        return [];
    auto d = chows.ranks.array.sort().differences;
    if (!d.allEqual)
        return [];
    return [[Fan.mixedTripleChow], [Fan.mixedShiftedChows], [], [Fan.mixedStraight]][d.front];
}
///
Fan[] chow2(Tile[] chows)
in
{
    assert (chows.length == 2);
    assert (chows.all!isNumeric);
}
body
{
    if (chows[0] == chows[1])
        return [Fan.pureDoubleChow];
    if (chows[0].rank == chows[1].rank)
        return [Fan.mixedDoubleChow];
    if (!chows.equalSuit)
        return [];
    if (chows[0].rank + 3 == chows[1].rank)
        return [Fan.shortStraight];
    if (chows[0].rank + 3 == chows[1].rank - 3)
        return [Fan.twoTerminalChows];
    return [];
}
auto differences(R)(R r)
{
    return (r.length - 1).iota.map!(i => r[i+1] - r[i]);
}
auto allSameDifferences(R)(R r)
{
    if (r.length <= 2)
        return true;
    return r.differences.allEqual;
}
auto allEqual(R)(R r)
{
    if (r.length <= 1)
        return true;
    return r.all!(a => a == r.front);
}
auto equalSuit(R)(R r)
{
    return r.map!(a => a.suit).allEqual;
}
auto differentSuit(R)(R r)
{
    return r.map!(a => a.suit).array.sort().group.map!(a => a[1]).all!(a => a == 1);
}
auto ranks(R)(R r)
{
    return r.map!(a => a.rank);
}
version (unittestChow)
unittest
{
    import std.stdio, std.string;
    import gbmj.meld;
    while (true)
    {
        auto chows = [randomChow];
        chows ~= randomChow();
        string hand;
        hand = "%-(%s%): ".format(chows.map!(a => Meld(MeldType.chowMiddle, a)));
        if (auto result = chows.sort().array.chow2)
            hand.writeln(result.front);
        chows ~= randomChow();
        hand = "%-(%s%): ".format(chows.map!(a => Meld(MeldType.chowMiddle, a)));
        if (auto result = chows.sort().array.chow3)
            hand.writeln(result.front);
        chows ~= randomChow();
        hand = "%-(%s%): ".format(chows.map!(a => Meld(MeldType.chowMiddle, a)));
        if (auto result = chows.sort().array.chow4)
            hand.writeln(result.front);
        hand.writeln(chows.sort().array.chowAll);
        if (chows.sort().array.chow4 == [Fan.quadrupleChow])
        {
            break;
        }
    }
}
auto randomChow()
{
    import std.random : uniform;
    return Tile([Suit.character, Suit.bamboo, Suit.dot][uniform(0u, 3u)], uniform(ushort(1), ushort(8)));
}
