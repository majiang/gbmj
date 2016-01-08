/** Basic rules library of Mahjong (Guobiao Majiang).

There are three versions of rules supported.

PWS (defaultPWS):
	Pai Wang Sai.
WMO:
	World Mahjong Organization.
JMSA:
	Japan Mahjong Sports Association.
*/
module gbmj;

import gbmj.fan, gbmj.tile, gbmj.hand;

/* There must be only one version of the rules. */
static assert (
	definedVersions!("PWS", "WMO", "JMSA").length <= 1,
	"conflicting version specifications: %-(%s, %)".format(
		cast(string[])[definedVersions!("PWS", "WMO", "JMSA")]));

import std.algorithm, std.range;

unittest
{
	auto bestHand = [
		Fan.bigThreeDragons,
		Fan.allHonor,
		Fan.fourConcealedPungs,
		Fan.fourKongs,
		Fan.prevalentWind,
		Fan.seatWind,
		Fan.lastTileDraw,
		Fan.outWithReplacementTile,
		Fan.selfDrawn];
	assert (bestHand.valid);
	assert (bestHand.calculate == 333);
	auto onePointsHand = [
		Fan.selfDrawn,
		Fan.closedWait,
		Fan.oneVoidedSuit,
		Fan.noHonors,
		Fan.pungOfTerminalsOrHonors,
		Fan.meldedKong,
		Fan.pureDoubleChow,
		Fan.mixedDoubleChow];
	assert (onePointsHand.valid);
	assert (onePointsHand.calculate == 16);
	auto threeAndEightIsSixteen = [
		Fan.allChows,
		Fan.mixedDoubleChow,
		Fan.flowerTiles,
		Fan.flowerTiles,
		Fan.flowerTiles,
		Fan.flowerTiles,
		Fan.flowerTiles];
	assert (!threeAndEightIsSixteen.valid);
	assert (threeAndEightIsSixteen.calculate == 16);
	auto twoPointsHand = [// 123333/456[EEEE]WW+W
		Fan.concealedHand,
		Fan.seatWind,
		Fan.prevalentWind,
		Fan.dragonPung,
		Fan.twoConcealedPungs,
		Fan.concealedKong,
		Fan.tileHog,
		Fan.oneVoidedSuit];
	assert (twoPointsHand.valid);
	assert (twoPointsHand.calculate == 23);
}

/// given an array of fans, check for valid hu.
bool valid(Fan[] fans)
{
	int point;
	foreach (fan; fans)
		if (fan != Fan.flowerTiles)
		{
			point += pointOfFan[fan];
			if (8 <= point)
				return true;
		}
	return false;
}

unittest
{
	import std.stdio;
	import gbmj.internal;
	stderr.writeln(Hand([], [], [0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 8], [], [], []));
	stderr.writeln(Hand([], [], [1, 2, 3, 3, 4, 5], [1, 2, 3], [1, 2, 3, 4], []));
	stderr.writeln(Hand([1.dragon], [
		2.bamboo.chowLow,
		2.bamboo.chowHigh,
		5.bamboo.pungOpposite,
		7.bamboo.pungRightKong]));
}

unittest
{
	import std.stdio;
	stderr.writefln("gbmj.package: All green!");
}


// version magic
template isDefined(string versionIdentifier)
{
	mixin ("
		version("~versionIdentifier~")
			enum isDefined = true;
		else
			enum isDefined = false;"
	);
}

import std.meta : Filter;
alias definedVersions(versionIdentifiers...) =
	Filter!(isDefined, versionIdentifiers);

enum noVersionDefinedOf(versionIdentifiers...) =
	definedVersions!versionIdentifiers.length == 0;
