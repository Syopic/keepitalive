package ld.view.unit;

import h2d.Anim;
import hxd.Res;
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
        hpKoef = 0.5;
        bitmap.visible = false;
        var tile = Res.img.anim.def_png.toTile();
        anim = new Anim(tile.split(2), 0.5 + Math.random(), animContainer);
        anim.pause = true;
    }
}