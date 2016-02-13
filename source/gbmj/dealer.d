module gbmj.dealer;
import gbmj.tile;

/** The wall.

TODO:
duplicate mode
*/
class Dealer
{
    /// Shuffle and build the wall.
    this ()
    {
        this.tiles = allTiles;
        debug (withoutShuffle) {} else
        {
            import std.random;
            randomShuffle(tiles);
        }
    }
    /// Check if the wall is _empty.
    bool empty() @property
    {
        return tiles.length == 0;
    }
    /// Deal a Tile[] of length 13 for a player.
    Tile[] deal()
    in
    {
        assert (13 <= tiles.length);
    }
    body
    {
        auto ret = tiles[0..13];
        tiles = tiles[13..$];
        return ret;
    }
    /// Pick a Tile for a player.
    Tile pick()
    in
    {
        assert (!empty);
    }
    body
    {
        auto ret = tiles[0];
        tiles = tiles[1..$];
        return ret;
    }
private:
    Tile[] tiles;
}
