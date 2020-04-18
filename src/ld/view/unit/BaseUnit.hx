package ld.view.unit;

import h2d.col.Point;
import pathfinder.Coordinate;
import ld.data.MapDataStorage.TileItem;
import h2d.filter.Glow;
import hxd.Cursor;
import h2d.Interactive;
import h2d.Object;
import h2d.Bitmap;
import ld.data.Globals;
import h2d.Tile;
import ld.view.base.GameObject;

class BaseUnit extends GameObject {
	public var tileItem:TileItem;
	public var selected:Bool = false;

	var selection:Bitmap;
	var bitmap:Bitmap;
	var textBlobId:String;
    var selectDelay:Float = 0;
    var moveDelay:Float = 0;
    var path:Array<Coordinate> = null;

	public function new(tileItem:TileItem, ?parent:Object) {
		super(parent);
		this.tileItem = tileItem;
		selection = new Bitmap(Game.controller.mapDataStorage.getTileById(72), this);
		select(false);

		var interaction = new Interactive(16, 16, this);
        interaction.cursor = Cursor.Button;
		interaction.onOver = function(event:hxd.Event) {
            if (!Game.controller.isLocked) {
                Game.view.interaction.cursor = Cursor.Button;
				bitmap.filter = new Glow(Globals.COLOR_SET.White, 1, 0.1);
				// textBlobId = Game.uiManager.showTextBlob(Std.int(position.x + 8), Std.int(position.y), tileItem.type);
			}
		}

		interaction.onOut = function(event:hxd.Event) {
			if (!Game.controller.isLocked) {
                Game.view.interaction.cursor = Cursor.Default;
				bitmap.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
				// Game.uiManager.hideTextBlob(textBlobId);
			}
		}

		interaction.onClick = function(event:hxd.Event) {
			if (!Game.controller.isLocked) {
				Game.view.setSelectedUnit(this);
			}
		}
	}

	public function select(isSelect:Bool) {
		selected = isSelect;
    }
    
    public function setPath(path:Array<Coordinate> ) {
		this.path = path;
	}

	override function update(dt:Float) {
		super.update(dt);
		if (selected) {
			if (--selectDelay < 0) {
				selection.visible = !selection.visible;
				selectDelay = 16;
			}
		} else {
			selection.visible = false;
			selectDelay = 0;
        }

        if (this.path != null && path.length > 0) {
            moveDelay -= dt;
            if (moveDelay < 0) {
                moveDelay = 0.01;
                var nC = path.shift();
                position = new Point(nC.x * Globals.CELL_SIZE, nC.y * Globals.CELL_SIZE);
            }
        }
	}
}
