package ld.view.unit;

import h2d.Bitmap;
import h2d.filter.Glow;
import hxd.Cursor;
import h2d.Interactive;
import h2d.Object;
import ld.data.Globals;

class DefenderUnit extends BaseUnit {

    var bitmap:Bitmap;
    var textBlobId:String;
    
    public function new(parent:Object) {
        super(parent);
        var tile = Game.controller.mapDataStorage.getTileById(41);
        bitmap = new Bitmap(tile, this);
        // anim.pause = true;

        var interaction = new Interactive(16, 16, this);
        interaction.cursor = Cursor.Button;
		interaction.onOver = function(event:hxd.Event) {
            bitmap = new Bitmap(tile, this);
            bitmap.filter = new Glow(Globals.COLOR_SET.White, 1, 0.1);
            textBlobId = Game.uiManager.showTextBlob(Std.int(position.x + 4), Std.int(position.y), guid);
        }
        
        interaction.onOut = function(event:hxd.Event) {
            bitmap.filter = null;
            Game.uiManager.hideTextBlob(textBlobId);
		}
    }
}