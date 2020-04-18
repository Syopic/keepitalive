package ld.controller;

import ld.data.Globals;
import ld.utils.particles.ParticleHelper;
import ld.view.unit.BaseUnit;
import ld.data.MapDataStorage;

class GameController {
	public var mapDataStorage:MapDataStorage;

	public var isPause:Bool = false;
	public var isLocked:Bool = false;
	public var steps:Int = 0;

	public function new() {
		mapDataStorage = new MapDataStorage(hxd.Res.map);
	}

	public function startGame() {
		Game.view.init();
		Game.inputController = new InputController();
		this.isPause = false;
		steps =0;
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
					if (Game.uiManager.hudScreen != null) {
						Game.uiManager.hudScreen.showResult();
						// lock screen
					}
				}
		}
	}

	public function checkTrap(unit:BaseUnit):Bool {
		var result:Bool = false;
		var c = unit.getCoordinate();
		var ti = Game.mapDataStorage.getTileItem(c.x, c.y, 0);
		if (ti!= null && ti.type == Std.string(CellType.Trap)) {
			unit.wound(2);
			for (i in 0 ... 30)
			Game.view.ps.addParticle(ParticleHelper.fontan(Std.int(unit.position.x + Globals.CELL_SIZE / 2), Std.int(unit.position.y + Globals.CELL_SIZE / 2), Globals.COLOR_SET.Como));
			result = true;
		}

		return result;
	}

	public function pause(isPause:Bool) {
		this.isPause = isPause;
	}

	public function update(dt:Float) {
		if (!this.isPause && Game.view != null)
			Game.view.update(dt);
	}

	public function dispose() {
		Game.view.dispose();
		Game.inputController.dispose();
		Game.inputController = null;
	}
}
