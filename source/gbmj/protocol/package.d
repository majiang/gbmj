module gbmj.protocol;

import gbmj.tile;

import std.experimental.logger;
static import exception = std.exception;

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
        return new ClientDealtTiles(_player.firstSeat);
    }
    ClientReactionPick accept(PickTile pickTile)
    {
        import std.string;
        tracef("client %d: received pick %s", _player.firstSeat, pickTile.tile.toString);
        return new ClientDiscard();
    }
private:
    Player _player;
}

///
class Dealer
{
    ///
    this ()
    {
        this.tiles = allTiles;
        debug
        {}
        else
        {
            // TODO: shuffle
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
        tracef("server: received OK for deal from client %d", clientDealtTiles.client);
        auto sourceLogicalSeat = players[clientDealtTiles.client].logicalSeat;
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
        trace("server: received discard");
        return null;
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
    Player target();
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
    Player target()
    {
        return _target;
    }
    ClientAction visit(Client client)
    {
        return client.accept(this);
    }
    this (Player target, Tile[] tiles)
    {
        this._target = target;
        this.tiles = tiles;
    }
    Player _target;
    Tile[] tiles;
}
class PickTile : ServerReactionDealt
{
    Player target()
    {
        return _target;
    }
    ClientAction visit(Client client)
    {
        return client.accept(this);
    }
    this (Player target, Tile tile)
    {
        this._target = target;
        this.tile = tile;
    }
    Player _target;
    Tile tile;
}
interface ClientReactionDeal : ClientAction
{
}
class ClientDealtTiles : ClientReactionDeal
{
    this (size_t client)
    {
        this.client = client;
    }
    ServerAction visit(Server server)
    {
        return server.accept(this);
    }
    size_t client;
}
class ClientDealError : ClientReactionDeal
{
    ServerAction visit(Server server)
    {
        return server.accept(this);
    }
}
interface ClientReactionPick : ClientAction
{
}
class ClientDiscard : ClientReactionPick
{
    ServerAction visit(Server server)
    {
        return server.accept(this);
    }
}
class ClientHuSelfdrawn : ClientReactionPick
{
    ServerAction visit(Server server)
    {
        return server.accept(this);
    }
}

///
struct Player
{
    ///
    immutable size_t firstSeat;
    ///
    this (size_t firstSeat)
    {
        this.firstSeat = firstSeat;
        dealInGame(0);
    }
    @disable this ();
    ///
    size_t physicalSeat() @property
    {
        return _physicalSeat;
    }
    ///
    size_t logicalSeat() @property
    {
        return _logicalSeat;
    }
    ///
    size_t dealInGame() @property
    {
        return _dealInGame;
    }
    ///
    void dealInGame(size_t d) @property
    {
        exception.enforce(d < 16);
        _dealInGame = d;
        // d & 12 indicates the round.
        _physicalSeat = physicalSeats[(d & 12) | firstSeat];
        _logicalSeat = (physicalSeat - d) & 3;
    }
private:
    size_t _physicalSeat;
    size_t _logicalSeat;
    size_t _dealInGame;
}

private:
version (PWS) version = SeatChange3;
version (WMO) version = SeatChange3;
version (JMSA) version = SeatChange1;
version (SeatChange3) enum physicalSeats = [
    0, 1, 2, 3, // east round
    1, 0, 3, 2, // south round
    3, 2, 0, 1, // west round
    2, 3, 1, 0];// north round
version (SeatChange1) enum physicalSeats = [
    0, 1, 2, 3,
    0, 1, 2, 3,
    1, 0, 3, 2,
    1, 0, 3, 2];
