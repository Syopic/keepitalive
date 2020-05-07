package ld.view.unit;

import h2d.Anim;
import hxd.Res;
import ld.data.MapDataStorage.TileItem;
import h2d.Object;

class ArcherUnit extends BaseUnit {

    public function new(tileItem:TileItem, ?parent:Object) {
        super(tileItem, parent);
        hpKoef = 1;

        bitmap.visible = false;
        var tile = Res.img.anim.arch1.toTile();
        anim = new Anim(tile.split(3), Math.random(), animContainer);
        anim.pause = true;

        // anim.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
    }
}