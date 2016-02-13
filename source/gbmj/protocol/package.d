module gbmj.protocol;
public import
    gbmj.protocol.server,
    gbmj.protocol.client,
    gbmj.protocol.serveraction,
    gbmj.protocol.clientaction;
package import
    gbmj.tile,
    gbmj.player,
    std.experimental.logger;

unittest
{
    Server server = new ServerImpl;
    Client[] clients = [new ClientImpl(0), new ClientImpl(1), new ClientImpl(2), new ClientImpl(3)];
    ServerAction serverAction = server.start();
    // null indicates the end of a game.
    while (serverAction !is null)
        serverAction = serverAction.visit(clients[serverAction.target.firstSeat]).visit(server);
}

interface ClientAction
{
    ServerAction visit(Server);
}
interface ClientReactionDeal : ClientAction
{
}
class ClientDealtTiles : ClientReactionDeal
{
    mixin (clientMessageMixin);
}
class ClientDealError : ClientReactionDeal
{
    mixin (clientMessageMixin);
}
interface ClientReactionPick : ClientAction
{
}
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
