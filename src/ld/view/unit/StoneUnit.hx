package ld.view.unit;

import ld.data.MapDataStorage.TileItem;
import h2d.Object;

class StoneUnit extends BaseUnit {

    public function new(tileItem:TileItem, ?parent:Object) {
        super(tileItem, parent);
        interaction = null;
    }
}