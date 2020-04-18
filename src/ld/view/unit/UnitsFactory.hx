package ld.view.unit;

import ld.data.MapDataStorage.TileItem;
import ld.data.MapDataStorage.UnitType;

class UnitsFactory {
	public static function getUnitByTileItem(tileItem:TileItem):BaseUnit {
		if (tileItem.type ==Std.string(King)) return new KingUnit(tileItem);
		if (tileItem.type ==Std.string(Defender)) return new DefenderUnit(tileItem);
		if (tileItem.type ==Std.string(Archer)) return new ArcherUnit(tileItem);
		if (tileItem.type ==Std.string(Stone)) return new StoneUnit(tileItem);
		return null;
	}
}
