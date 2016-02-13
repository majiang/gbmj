module gbmj.dealer;
import gbmj.tile;

///
class Dealer
{
    ///
    this ()
    {
        this.tiles = allTiles;
        debug (withoutShuffle) {} else
        {
            import std.random;
            randomShuffle(tiles);
        }
    }
    ///
    bool empty() @property
    {
        return tiles.length == 0;
    }
    ///
    auto deal()
    {
        auto ret = tiles[0..13];
        tiles = tiles[13..$];
        return ret;
    }
    ///
    auto pick()
    {
        auto ret = tiles[0];
        tiles = tiles[1..$];
        return ret;
    }
private:
    Tile[] tiles;
}
