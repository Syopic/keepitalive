package ld.view;

import ld.view.ui.DotView;
import ld.utils.Utils;
import pathfinder.Coordinate;
import ld.view.ui.PathView;
import ld.view.unit.KingUnit;
import ld.view.unit.BaseUnit;
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
import ld.view.unit.ArcherUnit;
import ld.view.unit.UnitsFactory;
import ld.view.ui.GameCursor;

class GameView extends Object {
	public var uiContainer:Object;
	public var dotsContainer:Object;
	public var camera:Camera;
	public var cursor:GameCursor;
	public var selectedUnit:BaseUnit;
	public var pathView:PathView;
	public var units:Array<BaseUnit> = new Array<BaseUnit>();
	public var interaction:Interactive;
	public var dots:Array<DotView>;

	var container:Object;
	var ps:ParticleSystem;
	var bgTiledGroup:TileGroup;

	public function new(parent:Object) {
		super(parent);
		var mask:Mask = new Mask(Globals.STAGE_WIDTH, Globals.STAGE_HEIGHT, this);
		camera = new Camera(mask, Globals.STAGE_WIDTH, Globals.STAGE_HEIGHT, Globals.STAGE_WIDTH / 2, Globals.STAGE_HEIGHT / 2);
		dots = new Array<DotView>();
	}

	public function init() {
		dispose();
		// var tile = hxd.Res.img.concept.toTile();
		// var bgImage = new Bitmap(tile, camera);
		bgTiledGroup = new TileGroup(Game.mapDataStorage.tileImage, camera);

		bgTiledGroup.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);

		uiContainer = new Object(camera);

		cursor = new GameCursor(camera);

		drawMap();
		interaction = new Interactive(Game.mapDataStorage.mapWidth * Globals.CELL_SIZE, Game.mapDataStorage.mapHeight * Globals.CELL_SIZE, camera);
		interaction.propagateEvents = true;
		interaction.cursor = Cursor.Default;
		interaction.onClick = function(event:hxd.Event) {
			if (!Game.controller.isLocked) {
				if (selectedUnit != null) {
					var c = Utils.getCoord(event.relX, event.relY);
					var isFree:Bool = false;
					for (d in dots) {
						if (d.getCoordinate().isEqualTo(c))
							isFree = true;
					}
					if (isFree) {
						var path = Game.mapDataStorage.findPath(selectedUnit.getCoordinate(), c);
						pathView.clearPath();
						selectedUnit.setPath(path);
					}
					clearUnitSelection();
				}
			}
		}

		interaction.onMove = function(event:hxd.Event) {
			if (!Game.controller.isLocked) {
				var c = Utils.getCoord(event.relX, event.relY);
				if (selectedUnit != null) {
					// FIND IN DOTS
					var isFree:Bool = false;
					for (d in dots) {
						if (d.getCoordinate().isEqualTo(c))
							isFree = true;
					}
					if (isFree) {
						var path = Game.mapDataStorage.findPath(selectedUnit.getCoordinate(), c);
						pathView.drawPath(path);
					} else
						pathView.clearPath();
				}

				var t = Game.mapDataStorage.getTileItem(c.x, c.y, 0);
			
				cursor.setPosition(c.x * Globals.CELL_SIZE, c.y * Globals.CELL_SIZE);
			}
		}
	}

	public function drawMap() {
		for (y in 0...Game.mapDataStorage.mapHeight) {
			for (x in 0...Game.mapDataStorage.mapWidth) {
				var tid = Game.mapDataStorage.getTileId(x, y, 0);
				if (tid != 0)
					bgTiledGroup.add(x * Game.mapDataStorage.tileWidth, y * Game.mapDataStorage.tileHeight, Game.mapDataStorage.getTileById(tid - 1));
			}
		}
		pathView = new PathView(camera);
		var mapObjects = Game.mapDataStorage.getObjects();

		for (obj in mapObjects) {
			// 	// sandTiledGroup.add(obj.x, obj.y - obj.height, tiles[obj.gid - 1]);
			var tile = Game.mapDataStorage.getTileItemById(obj.gid);
			var unit:BaseUnit = UnitsFactory.getUnitByTileItem(tile);
			if (unit != null) {
				camera.addChild(unit);
				units.push(unit);
				unit.position.x = obj.x;
				unit.position.y = obj.y - obj.height;
			}
		}
	}

	public function setSelectedUnit(unit:BaseUnit) {
		clearUnitSelection();
		selectedUnit = unit;
		unit.select(true);
	}

	public function clearUnitSelection() {
		for (unit in units) {
			unit.select(false);
		}
		selectedUnit = null;
	}

	public function addDot(c:Coordinate) {
		var dot = new DotView(uiContainer);
		dot.position = new Point((c.x) * Globals.CELL_SIZE, c.y * Globals.CELL_SIZE);
		dots.push(dot);
		dot.update(0);
	}

	public function clearDots(isClear:Bool = true) {
		if (dots != null) {
			for (dot in dots) {
				dot.remove();
				dot = null;
			}
		}
		dots = new Array<DotView>();
	}

	var testC:Array<Coordinate> = new Array<Coordinate>();

	public function checkDot(dotCoordinate:Coordinate) {
		var sc = selectedUnit.getCoordinate();
		testC = new Array<Coordinate>();
		testC.push(dotCoordinate);
		for (n in units) {
			if (!sc.isEqualTo(n.getCoordinate())) // remove selected Unit
				testC.push(n.getCoordinate());
		}
		Game.mapDataStorage.updateCheckMap(testC); // map with units as Walkable

		var isValid:Bool = true;

		for (n in units) {
			if (!sc.isEqualTo(n.getCoordinate())) {
				var path = Game.mapDataStorage.unitFindPath(dotCoordinate, n.getCoordinate());
				if (path == null)
					isValid = false;
			}
		}

		var path = Game.mapDataStorage.findPath(dotCoordinate, sc);

		if (Game.mapDataStorage.isWalkable(dotCoordinate.x, dotCoordinate.y) && path != null && isValid)
			addDot(dotCoordinate);
	}

	public function dispose() {
		if (camera != null)
			camera.removeChildren();
		if (bgTiledGroup != null)
			bgTiledGroup.removeChildren();

		for (unit in units) {
			unit.remove();
			unit = null;
		}
		units = new Array<BaseUnit>();
		if (ps != null)
			ps.dispose();

		if (interaction != null) {
			interaction.remove();
			interaction = null;
		}
	}

	public function update(dt:Float) {
		Game.mapDataStorage.updateWalkableMap();
		for (unit in units) {
			unit.update(dt);
			if (unit != selectedUnit)
				Game.mapDataStorage.setWalkable(unit.getCoordinate().x, unit.getCoordinate().y, false);
		}
		Game.controller.checkGame();
		if (ps != null) {
			ps.update(dt);
		}
		clearDots();

		if (selectedUnit != null) {
			for (unit in units) {
				var c = unit.getCoordinate();
				if (!c.isEqualTo(selectedUnit.getCoordinate())) {
					checkDot(new Coordinate(c.x, c.y - 1));
					checkDot(new Coordinate(c.x, c.y + 1));
					checkDot(new Coordinate(c.x - 1, c.y));
					checkDot(new Coordinate(c.x + 1, c.y));
				}
			}
		}
		camera.update(dt);
	}
}
