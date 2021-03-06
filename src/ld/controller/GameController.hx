package ld.controller;

import pathfinder.Coordinate;
import ld.view.unit.UnitsFactory;
import ld.view.unit.StoneUnit;
import ld.data.Globals;
import ld.utils.particles.ParticleHelper;
import ld.view.unit.BaseUnit;
import ld.data.MapDataStorage;

class GameController {
	public var mapDataStorage:MapDataStorage;

	public var isPause:Bool = false;
	public var isLocked:Bool = false;
	public var isCompleted:Bool = false;
	// public var isSkipBrief:Bool = false;
	public var steps:Int = 0;

	public function new() {}

	public function startGame(level:Int = 1) {
		switch (level) {
			case 1:
				mapDataStorage = new MapDataStorage(hxd.Res.map1);
			case 2:
				mapDataStorage = new MapDataStorage(hxd.Res.map2);
			case 3:
				mapDataStorage = new MapDataStorage(hxd.Res.map3);
		}
		Game.mapDataStorage = mapDataStorage;
		Game.view.init();
		Game.inputController = new InputController();
		this.isPause = false;
		steps = 0;
		isCompleted = false;
		lockInput(false);
	}


	public function lockInput(isLock:Bool) {
		isLocked = isLock;
	}

	public function endGame() {
		Game.view.dispose();
	}

	public function checkGame() {
		for (unit in Game.view.units) {
			var c = unit.getCoordinate();
			var ti = Game.mapDataStorage.getTileItem(c.x, c.y, 0);
			if (ti != null)
				if (unit != null
					&& unit.tileItem != null
					&& unit.tileItem.type == Std.string(UnitType.King)
					&& ti.type == Std.string(CellType.WinTarget)) {
					if (Game.uiManager.hudScreen != null && !isCompleted) {
						unit.visible = false;
						for (i in 0...10)
							Game.view.ps.addParticle(ParticleHelper.fontan(Std.int(unit.position.x + Globals.CELL_SIZE / 2),
						Std.int(unit.position.y + Globals.CELL_SIZE / 2), 0x29a2d9));
						if (!isLocked)
							Game.soundManager.playSound(Globals.SFX_SET.Door, 0.2);
							haxe.Timer.delay(function() {
								Game.uiManager.hudScreen.showResult();
							}, 2000);
						lockInput(true);
						isCompleted = true;
					}
				}
		}
	}
	
	public function checkTrap(unit:BaseUnit):Bool {
		var result:Bool = false;
		if (!isCompleted) {
			if (unit.tileItem.type != Std.string(UnitType.Stone)) {
				var c = unit.getCoordinate();
				var ti = Game.mapDataStorage.getTileItem(c.x, c.y, 0);
				if (ti != null && ti.type == Std.string(CellType.Trap)) {
					unit.wound(4);
					Game.soundManager.playSound(Globals.SFX_SET.Wound, 1);
					if (unit.hp <= 0) {

						if (unit.tileItem.type == Std.string(UnitType.King)) {
							unit.setPath([]);
							removeUnit(unit);
						} else {
							Game.controller.setStone(unit);
						}
					}
					for (i in 0...10)
						Game.view.ps.addParticle(ParticleHelper.fontan(Std.int(unit.position.x + Globals.CELL_SIZE / 2),
							Std.int(unit.position.y + Globals.CELL_SIZE / 2), 0xff0000));
					result = true;
				}
			}
		}
		return result;
	}

	public function removeUnit(unit:BaseUnit) {
		if (unit.tileItem.type == Std.string(UnitType.King)) {
			for (i in 0...30)
				Game.view.ps.addParticle(ParticleHelper.fontan(Std.int(unit.position.x + Globals.CELL_SIZE / 2),
					Std.int(unit.position.y + Globals.CELL_SIZE / 2), 0xff0000));
			if (!isLocked)
				haxe.Timer.delay(function() {
					Game.uiManager.changeScreen(Globals.GAMEOVER_SCREEN);
				}, 2000);
			lockInput(true);
		} else {
			Game.view.units.remove(unit);
			unit.dispose();
			unit.remove();
			unit = null;
		}
	}

	public function setStone(unit:BaseUnit) {
		var pos = null;
		for (u in Game.view.units) {
			if (u.guid == unit.guid) {
				pos = u.position.clone();
				break;
			}
		}
		if (pos != null) {
			removeUnit(unit);

			var tile = Game.mapDataStorage.getTileItemById(105);
			var unit:BaseUnit = UnitsFactory.getUnitByTileItem(tile);
			if (unit != null) {
				Game.view.unitsContainer.addChild(unit);
				Game.view.units.push(unit);
				unit.position.x = pos.x;
				unit.position.y = pos.y;
			}
		}
	}

	public function moveStone(unit:BaseUnit, from:Coordinate) {
		var c = unit.getCoordinate();
		var dx = c.x - from.x;
		var dy = c.y - from.y;
		if (Game.mapDataStorage.isWalkable(c.x + dx, c.y + dy)) {
			var ti = Game.mapDataStorage.getTileItem(c.x + dx, c.y + dy);
			if (ti != null && ti.type == Std.string(CellType.Trap)) {
				removeUnit(unit);
				Game.mapDataStorage.setTileId(c.x + dx, c.y + dy, 0);
				Game.view.drawMap();
				for (i in 0...20)
					Game.view.ps.addParticle(ParticleHelper.trap(Std.int((c.x + dx) * Globals.CELL_SIZE + Globals.CELL_SIZE / 2),
						Std.int((c.y + dy) * Globals.CELL_SIZE + Globals.CELL_SIZE / 2), Globals.COLOR_SET.TimberGreen));
			} else {
				var path = [new Coordinate(c.x + dx, c.y + dy)];
				Game.soundManager.playSound(Globals.SFX_SET.MoveStone, 0.5);
				unit.setPath(path);
			}
			for (i in 0...4)
				Game.view.ps.addParticle(ParticleHelper.fontan(Std.int(unit.position.x + Globals.CELL_SIZE / 2),
					Std.int(unit.position.y + Globals.CELL_SIZE / 2), Globals.COLOR_SET.Como));
		} else {
			Game.soundManager.playSound(Globals.SFX_SET.MoveStone, 0.8);
			removeUnit(unit);
			for (i in 0...10)
				Game.view.ps.addParticle(ParticleHelper.fontan(Std.int(unit.position.x + Globals.CELL_SIZE / 2),
					Std.int(unit.position.y + Globals.CELL_SIZE / 2), Globals.COLOR_SET.SpringRain));
		}
	}
	
	public function pause(isPause:Bool) {
		this.isPause = isPause;
	}

	public function update(dt:Float) {
		if (!this.isPause && Game.view != null && mapDataStorage != null)
			Game.view.update(dt);
	}

	public function dispose() {
		Game.view.dispose();
		Game.inputController.dispose();
		Game.inputController = null;
	}
}
