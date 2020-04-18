package ld.view.unit;

import ld.data.MapDataStorage.TileItem;
import h2d.Bitmap;
import h2d.filter.Glow;
import hxd.Cursor;
import h2d.Interactive;
import h2d.Object;
import ld.data.Globals;

class KingUnit extends BaseUnit {

    
    public function new(tileItem:TileItem, ?parent:Object) {
        super(tileItem, parent);
        var tile = Game.controller.mapDataStorage.getTileById(40);

        bitmap = new Bitmap(tile, this);
        bitmap.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
    }
}