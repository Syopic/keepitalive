package ld.view.unit;

import ld.data.MapDataStorage.UnitType;
import ld.utils.particles.ParticleHelper;
import ld.utils.particles.ParticleSystem.ParticleOptions;
import ld.utils.particles.ParticleSystem.EmitterOptions;
import ld.utils.particles.ParticleEmitter;
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
	public var checked:Bool = false;

	var selection:Bitmap;
	var bitmap:Bitmap;
	var textBlobId:String;
	var selectDelay:Float = 0;

	public var moveDelay:Float = 0;

	var path:Array<Coordinate> = null;
	var hp:Int = 10;
	var pe:ParticleEmitter;
	var interaction:Interactive;

	public function new(tileItem:TileItem, ?parent:Object) {
		super(parent);
		this.tileItem = tileItem;
		var tile = Game.controller.mapDataStorage.getTileById(tileItem.id);

		bitmap = new Bitmap(tile, this);
		bitmap.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);

		selection = new Bitmap(Game.controller.mapDataStorage.getTileById(72), this);
		select(false);

		// pe = ParticleHelper.bloodEmiter();
		if (this.tileItem.type != Std.string(UnitType.Stone)) {
			interaction = new Interactive(16, 16, this);
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
	}

	public function select(isSelect:Bool) {
		selected = isSelect;
	}

	public function setPath(path:Array<Coordinate>) {
		this.path = path;
	}

	public function wound(hp:Int) {
		this.hp -= hp;
		checked = true;
		moveDelay = 0.5;
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
				moveDelay = 0.06;
				var nC = path.shift();
				checked = false;
				position = new Point(nC.x * Globals.CELL_SIZE, nC.y * Globals.CELL_SIZE);
			}
		}
		if (pe != null)
			pe.position = new Point(position.x + Globals.CELL_SIZE / 2, position.y + Globals.CELL_SIZE / 3);
	}
}
