package ld.view.ui;

import h2d.filter.Glow;
import ld.data.Globals;
import h2d.Graphics;
import pathfinder.Coordinate;
import h2d.Bitmap;
import h2d.Object;
import ld.view.base.GameObject;

class PathView extends GameObject {
	public var graphics:Graphics;

	public function new(?parent:Object) {
		super(parent);
		graphics = new h2d.Graphics(this);
    }
    
    public function clearPath() {
        graphics.clear();
    }
    
	public function drawPath(path:Array<Coordinate>) {
        clearPath();
		if (path != null && path.length > 0) {
            graphics.lineStyle(2, Globals.COLOR_SET.TimberGreen);
			// trace(path);
            
			for (i in 0...path.length) {
                var c = path[i];
				var tx = c.x * Globals.CELL_SIZE + Globals.CELL_SIZE / 2;
				var ty = c.y * Globals.CELL_SIZE + Globals.CELL_SIZE / 2;
				if (i == 0)
					graphics.moveTo(tx, ty);
				else
					graphics.lineTo(tx, ty);
			}
			graphics.beginFill(Globals.COLOR_SET.SpringRain);
			var c = path[path.length - 1];
			var tx = c.x * Globals.CELL_SIZE + Globals.CELL_SIZE / 2;
			var ty = c.y * Globals.CELL_SIZE + Globals.CELL_SIZE / 2;
			graphics.drawRect(tx - 2, ty - 2, 4, 4);
			graphics.endFill();
		}
        // this.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
	}
}
