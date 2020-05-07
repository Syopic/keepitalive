package ld.view.unit;

import h2d.filter.Outline;
import h2d.Anim;
import h2d.Graphics;
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
	var animContainer:Object;

	var selection:Bitmap;
	var bitmap:Bitmap;
	var anim:Anim;
	var healthbar:Graphics;
	var textBlobId:String;
	var selectDelay:Float = 0;
	var isOver:Bool = false;

	public var moveDelay:Float = 0;

	var path:Array<Coordinate> = null;
	public var hp:Float = 10;
	var hpCapacity:Float = 10;
	var hpKoef:Float = 1;
	var pe:ParticleEmitter;
	var interaction:Interactive;

	public function new(tileItem:TileItem, ?parent:Object) {
		super(parent);
		this.tileItem = tileItem;
		var tile = Game.controller.mapDataStorage.getTileById(tileItem.id);

		bitmap = new Bitmap(tile, this);
		bitmap.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
		animContainer = new Object(this);
		animContainer.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);

		healthbar = new h2d.Graphics(this);
		healthbar.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
		selection = new Bitmap(Game.controller.mapDataStorage.getTileById(72), this);
		select(false);

		if (this.tileItem.type != Std.string(UnitType.Stone)) {
			interaction = new Interactive(16, 16, this);
			interaction.propagateEvents = true;
			interaction.cursor = Cursor.Button;
			interaction.onOver = function(event:hxd.Event) {
				if (!Game.controller.isLocked) {
					Game.view.interaction.cursor = Cursor.Button;
					bitmap.filter = new Glow(Globals.COLOR_SET.White, 1, 0.1);
					isOver = true;
					// textBlobId = Game.uiManager.showTextBlob(Std.int(position.x + 8), Std.int(position.y), tileItem.type);
					animContainer.filter = new Glow(Globals.COLOR_SET.White, 1, 0.1);
				}
			}


			interaction.onOut = function(event:hxd.Event) {
				if (!Game.controller.isLocked) {
					Game.view.interaction.cursor = Cursor.Default;
					bitmap.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
					isOver = false;

					animContainer.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
					

					// Game.uiManager.hideTextBlob(textBlobId);
				}
			}

			// interaction.onClick = function(event:hxd.Event) {
			// 	if (!Game.controller.isLocked) {
			// 		Game.view.setSelectedUnit(this);
			// 	}
			// }
		}
	}
	

	public function select(isSelect:Bool) {
		selected = isSelect;
	}

	public function setPath(path:Array<Coordinate>) {
		this.path = path;
	}

	public function wound(hp:Int) {
		this.hp -= hp * hpKoef;
		this.hp = this.hp < 0 ? 0 : this.hp;
		if (this.hp < this.hpCapacity / 2) {
			if (pe == null)
				pe = ParticleHelper.bloodEmiter();
		} else {
			if (pe != null) {
				Game.view.ps.removeEmitter(pe);
				pe = null;
			}
		}
		checked = true;
		moveDelay = 0.3;
	}

	public function updateHealthbar(isShow:Bool = false) {
		healthbar.clear();
		if (isShow) {
			// healthbar.lineStyle(1, Globals.COLOR_SET.SpringRain);
			healthbar.beginFill(Globals.COLOR_SET.SpringRain);
			healthbar.drawRect(3, 14, 10, 1);

			healthbar.beginFill(Globals.COLOR_SET.Clear);
			var w = Math.round((this.hp / hpCapacity) * 10);
			healthbar.drawRect(w + 3, 14, 10 - w, 1);
		}
	}

	override function update(dt:Float) {
		super.update(dt);
		updateHealthbar(selected || isOver);
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
				Game.view.pathView.drawPath(path);
				var nC = path.shift();
				checked = false;
				position = new Point(nC.x * Globals.CELL_SIZE, nC.y * Globals.CELL_SIZE);
				Game.soundManager.playSound(Globals.SFX_SET.UnitStep, 0.6);
				if (path.length == 0)
				Game.view.checkLinks();
			}
		}
		if (pe != null) {
			pe.position = new Point(position.x + Globals.CELL_SIZE / 2, position.y + Globals.CELL_SIZE / 3);
		}
		if (anim != null) {
			anim.currentFrame += dt * anim.speed * 3;
		}
	}


	public function dispose() {
		if (pe != null) {
			Game.view.ps.removeEmitter(pe);
			pe = null;
		}
	}
}
