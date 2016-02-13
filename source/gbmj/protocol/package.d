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
