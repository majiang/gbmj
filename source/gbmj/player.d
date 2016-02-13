module gbmj.player;

static import exception = std.exception;

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
