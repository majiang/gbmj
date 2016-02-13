module gbmj.protocol.serveraction;
import gbmj.protocol;


///
interface ServerAction
{
    Player target() @property;///
    ClientAction visit(Client);///
}


///
class DealTiles : ServerAction
{
    mixin (serverMessageMixin);
    ///
    this (Player target, Tile[] tiles)
    {
        this (target);
        this.tiles = tiles;
    }
    ///
    Tile[] tiles;
}
///
class PickTile : ServerAction
{
    mixin (serverMessageMixin);
    ///
    this (Player target, Tile tile)
    {
        this (target);
        this.tile = tile;
    }
    ///
    Tile tile;
}

private enum serverMessageMixin =
q{
    ClientAction visit(Client client)
    {
        return client.accept(this);
    }
    this (Player target)
    {
        this._target = target;
    }
    private Player _target;
    Player target() @property
    {
        return _target;
    }
};
