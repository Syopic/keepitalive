package ld.view.ui;

import h2d.filter.Outline;
import h2d.filter.Glow;
import ld.data.Globals;
import h2d.Graphics;
import pathfinder.Coordinate;
import h2d.Bitmap;
import h2d.Object;
import ld.view.base.GameObject;

class LinksView extends GameObject {
	public var graphics:Graphics;

	public function new(?parent:Object) {
		super(parent);
		graphics = new h2d.Graphics(this);
		// this.filter = new Outline(0.8, Globals.COLOR_SET.Aztec, 1);
    }
    
    public function clear() {
        graphics.clear();
    }
    
	public function drawPath(path:Array<Coordinate>) {
		if (path != null && path.length > 0) {
            graphics.lineStyle(4, 0x292929);
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
			
		}
		
	}
}



