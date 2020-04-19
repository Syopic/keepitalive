package ld.view;

import ld.view.ui.LinksView;
import ld.data.MapDataStorage.UnitType;
import ld.controller.GameController;
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
	public var bgContainer:Object;
	public var unitsContainer:Object;
	public var dotsContainer:Object;
	public var camera:Camera;
	public var cursor:GameCursor;
	public var selectedUnit:BaseUnit;
	public var pathView:PathView;
	public var linksView:LinksView;
	public var units:Array<BaseUnit> = new Array<BaseUnit>();
	public var interaction:Interactive;
	public var dots:Array<DotView>;
	public var ps:ParticleSystem;
	public var mousePosition:Point = new Point();

	var container:Object;
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

		ps = new ParticleSystem();

		bgContainer = new Object(camera);

		drawMap();

		linksView = new LinksView(camera);
		pathView = new PathView(camera);

		unitsContainer = new Object(camera);
		var mapObjects = Game.mapDataStorage.getObjects();

		for (obj in mapObjects) {
			var tile = Game.mapDataStorage.getTileItemById(obj.gid);
			var unit:BaseUnit = UnitsFactory.getUnitByTileItem(tile);
			if (unit != null) {
				unitsContainer.addChild(unit);
				units.push(unit);
				unit.position.x = obj.x;
				unit.position.y = obj.y - obj.height;
			}
		}

		dotsContainer = new Object(camera);
		dotsContainer.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
		interaction = new Interactive(Game.mapDataStorage.mapWidth * Globals.CELL_SIZE, Game.mapDataStorage.mapHeight * Globals.CELL_SIZE, camera);
		interaction.propagateEvents = true;
		interaction.cursor = Cursor.Default;
		interaction.onClick = function(event:hxd.Event) {
			if (!Game.controller.isLocked) {
				var c = Utils.getCoord(event.relX, event.relY);
				var unit = getUnitByCoord(c.x, c.y);
				if (selectedUnit != null) {
					if (unit != null) {
						if (unit.tileItem.type == Std.string(UnitType.Stone)
							&& selectedUnit.tileItem.type == Std.string(UnitType.Defender)) {
							if (Utils.getDistanceCoord(unit.getCoordinate(), selectedUnit.getCoordinate()) == 1) {
								Game.controller.moveStone(unit, selectedUnit.getCoordinate());
								Game.uiManager.hudScreen.setScore(++Game.controller.steps);
							}
							cursor.setMode(CursorMode.Default);
						} else if (unit.tileItem.type != Std.string(UnitType.Stone)) {
							setSelectedUnit(unit);
						} else {
							clearUnitSelection();
						}
					} else {
						var isFree:Bool = false;
						for (d in dots) {
							if (d.getCoordinate().isEqualTo(c))
								isFree = true;
						}
						if (isFree) {
							var path = Game.mapDataStorage.findPath(selectedUnit.getCoordinate(), c,
								selectedUnit.tileItem.type == Std.string(UnitType.Archer));
							pathView.clearPath();
							selectedUnit.setPath(path);
							Game.uiManager.hudScreen.setScore(++Game.controller.steps);
						}
						clearUnitSelection();
					}
				} else if (unit != null && unit.tileItem.type != Std.string(UnitType.Stone)) {
					setSelectedUnit(unit);
				}
			}
		}

		interaction.onMove = function(event:hxd.Event) {
			mousePosition = new Point(event.relX, event.relY);
		}
		uiContainer = new Object(camera);

		cursor = new GameCursor(uiContainer);
		cursor.visible = false;
		camera.addChild(ps);
	}

	public function drawMap() {
		if (bgTiledGroup != null) {
			bgContainer.removeChild(bgTiledGroup);
			bgTiledGroup.removeChildren();
			bgTiledGroup = null;
		}

		bgTiledGroup = new TileGroup(Game.mapDataStorage.tileImage, bgContainer);
		bgTiledGroup.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
		for (y in 0...Game.mapDataStorage.mapHeight) {
			for (x in 0...Game.mapDataStorage.mapWidth) {
				var tid = Game.mapDataStorage.getTileId(x, y, 0);
				if (tid != 0)
					bgTiledGroup.add(x * Game.mapDataStorage.tileWidth, y * Game.mapDataStorage.tileHeight, Game.mapDataStorage.getTileById(tid - 1));
			}
		}
	}

	public function setSelectedUnit(unit:BaseUnit) {
		clearUnitSelection();
		selectedUnit = unit;
		unit.select(true);
		if (unit.tileItem.type == Std.string(UnitType.King)) {
			Game.soundManager.playSound(Globals.SFX_SET.CrownSelect, 0.8);
		} else {
			Game.soundManager.playSound(Globals.SFX_SET.UnitSelect, 0.5);
		}
	}

	public function clearUnitSelection() {
		for (unit in units) {
			unit.select(false);
		}
		selectedUnit = null;
	}

	public function addDot(c:Coordinate) {
		var dot = new DotView(dotsContainer);
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

	public function checkDot(dotCoordinate:Coordinate, unit:BaseUnit = null) {
		var sc = null;
		if (unit != null) {
			sc = unit.getCoordinate();
		} else {
			sc = selectedUnit.getCoordinate();
		}
		testC = new Array<Coordinate>();
		testC.push(dotCoordinate);
		for (n in units) {
			if (!sc.isEqualTo(n.getCoordinate()) && n.tileItem.type != Std.string(UnitType.Stone)) {
				// trace(n.tileItem.type);
				testC.push(n.getCoordinate());
			}
		}
		Game.mapDataStorage.updateCheckMap(testC); // map with units as Walkable

		var isValid:Bool = true;

		for (n in units) {
			if (!sc.isEqualTo(n.getCoordinate()) && n.tileItem.type != Std.string(UnitType.Stone)) {
				var path = Game.mapDataStorage.unitFindPath(dotCoordinate, n.getCoordinate());
				if (path == null)
					isValid = false;
			}
		}

		if (selectedUnit != null) {
			var path = Game.mapDataStorage.findPath(dotCoordinate, sc, selectedUnit.tileItem.type == Std.string(UnitType.Archer));
			
			if (Game.mapDataStorage.isWalkable(dotCoordinate.x, dotCoordinate.y) && path != null && isValid)
				addDot(dotCoordinate);
		}
	}

	public function checkLinks() {
		linksView.clear();
		// if (selectedUnit != null)
		// 	checkDot(new Coordinate(selectedUnit.getCoordinate().x, selectedUnit.getCoordinate().y));

		for (n in units) {
			for (n2 in units) {
				checkDot(n.getCoordinate(), n2);
			}
		}

		for (n in units) {
			for (n2 in units) {
				if (!n2.getCoordinate().isEqualTo(n.getCoordinate())
					&& n.tileItem.type != Std.string(UnitType.Stone)
					&& n2.tileItem.type != Std.string(UnitType.Stone)) {
					var path = Game.mapDataStorage.unitFindPath(n.getCoordinate(), n2.getCoordinate());
					if (path != null)
						linksView.drawPath(path);
				}
			}
		}
	}

	public function getUnitByCoord(x:Int, y:Int) {
		for (unit in units) {
			var c = unit.getCoordinate();
			if (c.isEqualTo(new Coordinate(x, y)))
				return unit;
		}
		return null;
	}

	public function dispose() {
		if (camera != null) {
			camera.removeChildren();
			camera.viewX = Globals.STAGE_WIDTH / 2;
			camera.viewY = Globals.STAGE_HEIGHT / 2;
		}
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
		clearDots();
	}

	public function update(dt:Float) {
		Game.mapDataStorage.updateWalkableMap();

		for (unit in units) {
			unit.update(dt);
			if (!unit.checked)
				Game.controller.checkTrap(unit);
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

		// mouse
		if (!Game.controller.isLocked) {
			cursor.visible = true;
			cursor.setMode(CursorMode.Default);

			var c = Utils.getCoord(mousePosition.x, mousePosition.y);
			var unit = getUnitByCoord(c.x, c.y);

			if (selectedUnit != null) {
				if (selectedUnit == unit) {
					cursor.visible = false;
				}

				if (unit != null) {
					if (unit.tileItem.type == Std.string(UnitType.Stone) && selectedUnit.tileItem.type == Std.string(UnitType.Defender)) {
						if (Utils.getDistanceCoord(unit.getCoordinate(), selectedUnit.getCoordinate()) == 1)
							cursor.setMode(CursorMode.Push);
					}
					pathView.clearPath();
				} else {
					// FIND IN DOTS
					var isFree:Bool = false;
					for (d in dots) {
						if (d.getCoordinate().isEqualTo(c))
							isFree = true;
					}
					if (isFree) {
						var path = Game.mapDataStorage.findPath(selectedUnit.getCoordinate(), c, selectedUnit.tileItem.type == Std.string(UnitType.Archer));
						pathView.drawPath(path);
					} else
						pathView.clearPath();
				}
			}

			cursor.setPosition(c.x * Globals.CELL_SIZE, c.y * Globals.CELL_SIZE);
		} else
			cursor.visible = false;

		checkLinks();
	}
}
