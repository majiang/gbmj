module gbmj.protocol.clientaction;
import gbmj.protocol;


///
interface ClientAction
{
    ServerAction visit(Server);///
}

///
interface ClientReactionDeal : ClientAction
{
}
///
interface ClientReactionPick : ClientAction
{
}


///
class ClientDealtTiles : ClientReactionDeal
{
    mixin (clientMessageMixin);
}
///
class ClientDealError : ClientReactionDeal
{
    mixin (clientMessageMixin);
}
///
class ClientDiscard : ClientReactionPick
{
    mixin (clientMessageMixin);
    this (Player source, Tile tile)
    {
        this (source);
        this.tile = tile;
    }
    Tile tile;
}
///
class ClientHuSelfdrawn : ClientReactionPick
{
    mixin (clientMessageMixin);
}


private enum clientMessageMixin =
q{
    ServerAction visit(Server server)
    {
        return server.accept(this);
    }
    this (Player source)
    {
        this._source = source;
    }
    private Player _source;
    Player source() @property
    {
        return _source;
    }
};
