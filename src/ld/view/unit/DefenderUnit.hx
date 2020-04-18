package ld.view.unit;

import ld.data.MapDataStorage.TileItem;
import h2d.Bitmap;
import h2d.filter.Glow;
import hxd.Cursor;
import h2d.Interactive;
import h2d.Object;
import ld.data.Globals;

class DefenderUnit extends BaseUnit {

    
    public function new(tileItem:TileItem, ?parent:Object) {
        super(tileItem, parent);
    }
}