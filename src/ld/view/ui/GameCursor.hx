package ld.view.ui;

import h2d.Bitmap;
import h2d.Object;
import ld.view.base.GameObject;

class GameCursor extends GameObject {
    var selection:Bitmap;
    public function new(?parent:Object) {
        super(parent);
        selection = new Bitmap(Game.controller.mapDataStorage.getTileById(72), this);
    }
}