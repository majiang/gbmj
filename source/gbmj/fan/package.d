module gbmj.fan;

/// Calculate the point of a list of fans.
auto calculate(Fan[] fans)
{
	int point = 8;
	foreach (fan; fans)
		point += pointOfFan[fan];
	version (JMSA)
		point = point.min(88);
	return point;
}

/// Definition of fans.
enum Fan
{
	bigFourWinds,
	bigThreeDragons,
	allGreen,
	nineGates,
	fourKongs,
	sevenShiftedPairs,
	thirteenOrphans,
	allTerminals,
	littleFourWinds,
	littleThreeDragons,
	allHonor,
	fourConcealedPungs,
	pureTerminalChows,
	quadrupleChow,
	fourPureShiftedPungs,
	fourPureShiftedChows,
	threeKongs,
	allTerminalsAndHonors,
	sevenPairs,
	greaterHonorsAndKnittedTiles,
	allEvenPungs,
	fullFlush,
	pureTripleChow,
	pureShiftedPungs,
	upperTiles,
	middleTiles,
	lowerTiles,
	pureStraight,
	threeSuitedTerminalChows,
	pureShiftedChows,
	allFives,
	triplePung,
	threeConcealedPungs,
	lesserHonorsAndKnittedTiles,
	knittedStraight,
	upperFive,
	lowerFive,
	bigThreeWinds,
	mixedStraight,
	reversibleTiles,
	mixedTripleChow,
	mixedShiftedPungs,
	chickenHand,
	lastTileDraw,
	lastTileClaim,
	outWithReplacementTile,
	robbingTheKong,
	twoConcealedKongs,
	allPungs,
	halfFlush,
	mixedShiftedChows,
	allTypes,
	meldedHand,
	twoDragonsPungs,
	outsideHand,
	fullyConcealedHand,
	twoMeldedKongs,
	lastTile,
	dragonPung,
	prevalentWind,
	seatWind,
	concealedHand,
	allChows,
	tileHog,
	doublePung,
	twoConcealedPungs,
	concealedKong,
	allSimples,
	pureDoubleChow,
	mixedDoubleChow,
	shortStraight,
	twoTerminalChows,
	pungOfTerminalsOrHonors,
	meldedKong,
	oneVoidedSuit,
	noHonors,
	edgeWait,
	closedWait,
	singleWaiting,
	selfDrawn,
	flowerTiles
}

version (PWS) version = DoubleKong456;
version (WMO) version = DoubleKong468;
version (JMSA) version = DoubleKong456;

/// Points of fans.
version (DoubleKong456) enum pointOfFan = ungroup(
	88, 7, 64, 6, 48, 2, 32, 3, 24, 9, 16, 6, 12, 5,
	8, 9, 6, 7, 4, 4, 2, 10, 1, 13
);
version (DoubleKong468) enum pointOfFan = ungroup(
	88, 7, 64, 6, 48, 2, 32, 3, 24, 9, 16, 6, 12, 5,
	8, 10, 6, 6, 4, 4, 2, 10, 1, 13
);

static assert (pointOfFan.length == 81);

/* The inverse of std.algorithm.group */
private uint[] ungroup(uint[] args...)
in
{
	assert ((args.length & 1) == 0);
}
body
{
	import std.range, std.array;
	if (args.empty)
		return [];
	else
		return args[0].repeat(args[1]).chain(args[2..$].ungroup).array;
}
