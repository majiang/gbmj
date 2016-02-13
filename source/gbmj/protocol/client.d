module gbmj.protocol.client;
import gbmj.protocol;

///
interface Client
{
    /// React the deal with confirming the deal or informing of an error.
    ClientReactionDeal accept(DealTiles dealTiles);
    /// React the pick with declaring hu, hua, gang, or discarding a tile.
    ClientReactionPick accept(PickTile pickTile);
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
