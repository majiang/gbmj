module gbmj.protocol;

import gbmj.tile, gbmj.player, gbmj.dealer;

import std.experimental.logger;

unittest
{
    Server server = new ServerImpl;
    Client[] clients = [new ClientImpl(0), new ClientImpl(1), new ClientImpl(2), new ClientImpl(3)];
    ServerAction serverAction = server.start();
    // null indicates the end of a game.
    while (serverAction !is null)
        serverAction = serverAction.visit(clients[serverAction.target.firstSeat]).visit(server);
}

class ClientImpl : Client
{
    this (size_t firstSeat)
    {
        this._player = Player(firstSeat);
    }
    ClientReactionDeal accept(DealTiles dealTiles)
    {
        // workaround
        import std.string;
        tracef("client %d: received deal %s", _player.firstSeat, "%-(%s%)".format(dealTiles.tiles));

//        should, but does not work. probably a safe/trusted/system-related bug in std.experimental.logger:
//        tracef("client %d: received deal %-(%s%)", _player.firstSeat, dealTiles.tiles);
//        src\phobos\std\experimental\logger\core.d(1106): Error: safe function 'std.experimental.logger.core.Logger.memLogFunctions!cast(LogLevel)cast(ubyte)32u.logImplf!(27, "source\\gbmj\\protocol\\package.d", "gbmj.protocol.ClientImpl.accept", "ClientReactionDeal gbmj.protocol.ClientImpl.accept(DealTiles dealTiles)", "gbmj.protocol", immutable(uint), Tile[]).logImplf' cannot call system function 'std.format.formattedWrite!(MsgRange, char, immutable(uint), Tile[]).formattedWrite'
//        src\phobos\std\experimental\logger\core.d(562): Error: template instance std.experimental.logger.core.Logger.memLogFunctions!cast(LogLevel)cast(ubyte)32u.logImplf!(27, "source\\gbmj\\protocol\\package.d", "gbmj.protocol.ClientImpl.accept", "ClientReactionDeal gbmj.protocol.ClientImpl.accept(DealTiles dealTiles)", "gbmj.protocol", immutable(uint), Tile[]) error instantiating
        return new ClientDealtTiles(_player);
    }
    ClientReactionPick accept(PickTile pickTile)
    {
        import std.string;
        tracef("client %d: received pick %s", _player.firstSeat, pickTile.tile.toString);
        return new ClientDiscard(_player, pickTile.tile);
    }
private:
    Player _player;
}

class ServerImpl : Server
{
    Dealer dealer;
    Player[] players;
    IDealTiles start()
    {
        players = [Player(0), Player(1), Player(2), Player(3)];
        this.dealer = new Dealer;
        return new DealTiles(players[0], dealer.deal);
    }
    ServerReactionDealt accept(ClientDealtTiles clientDealtTiles)
    {
        tracef("server: received OK for deal from client %d", clientDealtTiles.source.firstSeat);
        auto sourceLogicalSeat = clientDealtTiles.source.logicalSeat;
        if (sourceLogicalSeat == 3)
            return new PickTile(players[players.logical(0)], dealer.pick);
        auto nextClient = players.logical(sourceLogicalSeat + 1);
        return new DealTiles(players[nextClient], dealer.deal);
    }
    ServerAction accept(ClientDealError clientDealError)
    {
        trace("server: received error for deal");
        return null;
    }
    ServerAction accept(ClientHuSelfdrawn clientHu)
    {
        trace("server: received hu");
        return null;
    }
    ServerAction accept(ClientDiscard clientDiscard)
    {
        tracef("server: received discard %s from client %d", clientDiscard.tile.toString, clientDiscard.source.firstSeat);
        if (dealer.empty)
            return null;
        return new PickTile(players[players.logical((clientDiscard.source.logicalSeat + 1) & 3)], dealer.pick);
    }
}

size_t logical(Player[] players, size_t logicalSeat)
{
    foreach (i, player; players)
        if (player.logicalSeat == logicalSeat)
            return i;
    assert (0);
}

interface Server
{
    IDealTiles start();
    ServerReactionDealt accept(ClientDealtTiles clientDealtTiles);
    ServerAction accept(ClientDealError clientDealError);
    ServerAction accept(ClientHuSelfdrawn clientHu);
    ServerAction accept(ClientDiscard clientDiscard);
}
interface Client
{
    ClientReactionDeal accept(DealTiles dealTiles);
    ClientReactionPick accept(PickTile pickTile);
}
interface ServerAction
{
    Player target() @property;
    ClientAction visit(Client);
}
interface ClientAction
{
    ServerAction visit(Server);
}
interface IDealTiles : ServerAction
{
}
interface ServerReactionDealt : ServerAction
{
}
class DealTiles : IDealTiles, ServerReactionDealt
{
    mixin (serverMessageMixin);
    this (Player target, Tile[] tiles)
    {
        this (target);
        this.tiles = tiles;
    }
    Tile[] tiles;
}
class PickTile : ServerReactionDealt
{
    mixin (serverMessageMixin);
    this (Player target, Tile tile)
    {
        this (target);
        this.tile = tile;
    }
    Tile tile;
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
