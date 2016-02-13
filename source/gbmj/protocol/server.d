module gbmj.protocol.server;
import gbmj.protocol;

///
interface Server
{
    IDealTiles start();///
    ServerReactionDealt accept(ClientDealtTiles clientDealtTiles);///
    ServerAction accept(ClientDealError clientDealError);///
    ServerAction accept(ClientHuSelfdrawn clientHu);///
    ServerAction accept(ClientDiscard clientDiscard);///
}

class ServerImpl : Server
{
    import gbmj.dealer;
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
        auto nextPlayer = players.next(clientDealtTiles.source);
        if (nextPlayer.logicalSeat == 0)
            return new PickTile(nextPlayer, dealer.pick);
        return new DealTiles(nextPlayer, dealer.deal);
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
        return new PickTile(players.next(clientDiscard.source), dealer.pick);
    }
}
