module gbmj.protocol;

import std.experimental.logger;
static import exception = std.exception;

unittest
{
    Server server = new ServerImpl;
    Client client = new ClientImpl;
    server.start.visit(client).visit(server);
}

class ClientImpl : Client
{
    ClientReactionDeal accept(DealTiles dealTiles)
    {
        trace("client: received deal");
        return new ClientDealtTiles;
    }
}

class ServerImpl : Server
{
    IDealTiles start()
    {
        return new DealTiles(Player.init);
    }
    ServerAction accept(ClientDealtTiles clientDealtTiles)
    {
        trace("server: received OK for deal");
        return null;
    }
    ServerAction accept(ClientDealError clientDealError)
    {
        trace("server: received error for deal");
        return null;
    }
}

interface Server
{
    IDealTiles start();
    ServerAction accept(ClientDealtTiles clientDealtTiles);
    ServerAction accept(ClientDealError clientDealError);
}
interface Client
{
    ClientReactionDeal accept(DealTiles dealTiles);
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
class DealTiles : IDealTiles
{
    Player target()
    {
        return _target;
    }
    ClientAction visit(Client client)
    {
        return client.accept(this);
    }
    this (Player target)
    {
        this._target = target;
    }
    Player _target;
}
interface ClientReactionDeal : ClientAction
{
}
class ClientDealtTiles : ClientReactionDeal
{
    ServerAction visit(Server server)
    {
        return server.accept(this);
    }
}
class ClientDealError : ClientReactionDeal
{
    ServerAction visit(Server server)
    {
        return server.accept(this);
    }
}

struct Player
{
    immutable size_t firstSeat;
    size_t physicalSeat() @property
    {
        return _physicalSeat;
    }
    size_t logicalSeat() @property
    {
        return _logicalSeat;
    }
    size_t dealInGame() @property
    {
        return _dealInGame;
    }
    void dealInGame(size_t d) @property
    {
        exception.enforce(d < 16);
        _dealInGame = d;
        /// TODO: seat change ///
    }
private:
    size_t _physicalSeat;
    size_t _logicalSeat;
    size_t _dealInGame;
}
