module gbmj.tile;

import std.algorithm, std.range, std.ascii;
static import exception = std.exception;
import gbmj.internal;

/// Typecode for the suit of a tile.
enum Suit
{
    wind, dragon, character, bamboo, dot, flower, joker, unknown
}
enum honorSuits = [Suit.wind, Suit.dragon];
enum numericSuits = [Suit.character, Suit.bamboo, Suit.dot];
enum specialSuits = [Suit.flower, Suit.joker, Suit.unknown];

/// Type for the rank of a tile.
alias Rank = uint;


// Whether the rule use flower tiles or not.
version (PWS) version = UseFlower;
version (WMO) version = UseFlower;
version (JMSA) version = NoFlower;

/// The number of different tiles of a numeric suit.
enum Rank maxOfNumeric = 9;
/// The number of different tiles of a suit.
version (UseFlower) enum Rank[] maxOfSuit = [
    4, 3, maxOfNumeric, maxOfNumeric, maxOfNumeric, 8, 0, 1];
version (NoFlower) enum Rank[] maxOfSuit = [
    4, 3, maxOfNumeric, maxOfNumeric, maxOfNumeric, 0, 0, 1];
enum tilePositionOffset =
(){
    auto ret = new Rank[1];
    foreach (m; maxOfSuit)
        ret ~= m + ret[$-1];
    return ret;
}();

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

/// The array of all tiles.
Tile[] allTiles()
{
    import std.traits;
    Tile[] tiles;
    foreach (suit; EnumMembers!Suit)
        foreach (rank; 0..maxOfSuit[suit])
            foreach (i; 0..duplicationOfSuit[suit])
                tiles ~= Tile(suit, rank);
    return tiles;
}

bool isNumeric(Suit suit)
{
    with (Suit)
    return suit == character
        || suit == bamboo
        || suit == dot;
}

///
bool isNumeric(Tile tile)
{
    return tile.suit.isNumeric;
}

bool isHonor(Suit suit)
{
    with (Suit)
    return suit == wind
        || suit == dragon;
}

///
bool isHonor(Tile tile)
{
    return tile.suit.isHonor;
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
bool isNormal(Tile tile)
{
    return tile.isNumeric || tile.isHonor;
}

///
bool isSpecial(Tile tile)
{
    return !tile.isNormal;
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

/// Green tiles: 23468 bamboos or green dragon.
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

/// Reversible tiles: 245689 of bamboos, 1234589 of dots or white dragon.
bool isReversible(Tile tile)
{
    if (tile.suit == Suit.bamboo)
        return [2, 4, 5, 6, 8, 9].canFind(tile.rank + 1);
    if (tile.suit == Suit.dot)
        return [1, 2, 3, 4, 5, 8, 9].canFind(tile.rank + 1);
    return tile.isWhiteDragon;
}

/** The code points of the first tiles of the suits.

Reference:
<a href="http://unicode.org/charts/PDF/U1F000.pdf">Unicode Character Code Charts : Other Symbols : Game Symbols : Mahjong Tiles</a>
*/
enum dchar[] unicodeOffsetOfSuit = [
    0x1F000, // East wind (south, west, north)
    0x1F004, // Red dragon (green, white)
    0x1F007, // 1 character
    0x1F010, // 1 bamboo
    0x1F019, // 1 dot
    0x1F022, // plum (mei) flower (orchid, bamboo, chrysanthemum, spring, summer, autumn, winter)
    0x1F02A, // joker (baida)
    0x1F02B];// back

/// Convert a Tile to a unicode character.
dchar toUnicodeChar(Tile tile)
{
    return unicodeOffsetOfSuit[tile.suit] + tile.rank;
}

/// Convert a Tile to a human-readable ASCII string.
string toAsciiString(Tile tile)
{
    immutable rank = tile.rank;
    import std.conv : to;
    final switch (tile.suit)
    {
        case Suit.wind: return "ESWN"[rank] ~ "w";
        case Suit.dragon: return "RGW"[rank] ~ "d";

        case Suit.character: return (rank+1).to!string ~ "c";
        case Suit.bamboo: return (rank+1).to!string ~ "b";
        case Suit.dot: return (rank+1).to!string ~ "d";

        case Suit.flower: return "F" ~ rank.to!string;
        case Suit.joker: return "JK";
        case Suit.unknown: return "--";
    }
}

/// Convert an ASCII string to a Tile[].
Tile[] readTiles(string s)
{
    Tile[] ret;
    while (!s.empty)
    {
        while (s[0] == ' ')
            s = s[1..$];
        ret ~= s[0..2].readTile;
        s = s[2..$];
    }
    return ret;
}

/// Convert a two-character ASCII string to a Tile.
Tile readTile(string s)
{
    if ("ESWNRG".canFind(s[0]))
        return s.readHonor;
    if (s[0].isDigit)
        return s.readNumeric;
    return s.readSpecial;
}

private:

Tile readHonor(string s)
{
    switch (s[1])
    {
        case 'w': return "ESWN".countUntil(s[0]).wind;
        case 'd': return "RGW".countUntil(s[0]).dragon;
        default:
            assert (false, "illegal honor");
    }
}

Tile readNumeric(string s)
{
    switch (s[1])
    {
        case 'c': return (s[0] - '1').character;
        case 'b': return (s[0] - '1').bamboo;
        case 'd': return (s[0] - '1').dot;
        default:
            assert (false, "illegal numeric");
    }
}

Tile readSpecial(string s)
{
    if (s == "JK")
        return joker;
    if (s == "BK")
        return unknown;
    exception.enforce(s[0] == 'F');
    exception.enforce('0' <= s[1]);
    exception.enforce(s[1] < '0' + maxOfSuit[Suit.flower]);
    return (s[1] - '0').flower;
}
