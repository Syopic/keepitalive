package ld.view;

import h2d.col.Point;
import h2d.Bitmap;
import ld.view.base.GameObject;
import h2d.filter.Glow;
import h2d.TileGroup;
import hxd.Cursor;
import h2d.Mask;
import h2d.Interactive;
import ld.utils.particles.ParticleSystem;
import ld.data.Globals;
import h2d.Object;
import ld.view.base.Camera;
import ld.view.thing.AnimCoinThing;
import ld.view.unit.DefenderUnit; 

class GameView extends Object {
	public var uiContainer:Object;
	public var camera:Camera;

	var container:Object;
	var ps:ParticleSystem;
	var objects:Array<GameObject> = new Array<GameObject>();
	var interaction:Interactive;
	var bgTiledGroup:TileGroup;

	

	public function new(parent:Object) {
		super(parent);
		var mask:Mask = new Mask(Globals.STAGE_WIDTH, Globals.STAGE_HEIGHT, this);
		camera = new Camera(mask, Globals.STAGE_WIDTH, Globals.STAGE_HEIGHT, Globals.STAGE_WIDTH / 2, Globals.STAGE_HEIGHT / 2);
	}

	public function init() {
		dispose();
		// var tile = hxd.Res.img.concept.toTile();
		// var bgImage = new Bitmap(tile, camera);
		bgTiledGroup = new TileGroup(Game.mapDataStorage.tileImage, camera);
		drawMap();

		// bushTiledGroup = new TileGroup(Game.mapDataStorage.tileImage, camera);
		// bushTiledGroup.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
		// objectsTiledGroup.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);

		// // var fireUnit:FireUnit = new FireUnit(camera);
		// // fireUnit.position = new Point(40, 40);
		// // units.push(fireUnit);

		uiContainer = new Object(camera);
	}

	public function drawMap() {
		for (y in 0...Game.mapDataStorage.mapHeight) {
			for (x in 0...Game.mapDataStorage.mapWidth) {
				var tid = Game.mapDataStorage.getTileId(x, y, 0);
				if (tid != 0)
					bgTiledGroup.add(x * Game.mapDataStorage.tileWidth, y * Game.mapDataStorage.tileHeight, Game.mapDataStorage.getTileById(tid - 1));
			}
		}

		var mapObjects = Game.mapDataStorage.getObjects();

		for (obj in mapObjects) {
		// 	// sandTiledGroup.add(obj.x, obj.y - obj.height, tiles[obj.gid - 1]);

			var defender = new DefenderUnit(camera);
			objects.push(defender);
			defender.position.x = obj.x;
			defender.position.y = obj.y - obj.height;
		}
	}

	public function update(dt:Float) {
		for (obj in objects) {
			if (obj != null) {
				// obj.position.x += 0.1;
				obj.update(dt);
				Game.uiManager.hudScreen.setScore(Std.int(obj.position.x));
				// ps.addParticle(ParticleHelper.fontan(Std.int(unit.position.x + 2), Std.int(unit.position.y), Globals.COLOR_SET.Como));
				if (obj.position.x > Globals.STAGE_WIDTH) {
					obj.position.x = 0;
					obj.position.y = Std.random(144);
				}
			}
		}
		if (ps != null) {
			ps.update(dt);
		}

		camera.update(dt);
	}

	public function dispose() {
		if (camera != null)
			camera.removeChildren();
		if (bgTiledGroup != null)
			bgTiledGroup.removeChildren();

		for (obj in objects) {
			obj.remove();
			obj = null;
		}
		objects = new Array<GameObject>();
		if (ps != null)
			ps.dispose();

		if (interaction != null) {
			interaction.remove();
			interaction = null;
		}
	}
}
