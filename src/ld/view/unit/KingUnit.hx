package ld.view.unit;

import h2d.Anim;
import hxd.Res;
import ld.data.MapDataStorage.TileItem;
import h2d.Object;

class KingUnit extends BaseUnit {

    
    public function new(tileItem:TileItem, ?parent:Object) {
        super(tileItem, parent);
        hpKoef = 5;

        
        bitmap.visible = false;
        var tile = Res.img.anim.crone_png.toTile();
        anim = new Anim(tile.split(2), 1 + Math.random(), animContainer);
        anim.pause = true;
    }
}