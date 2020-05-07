package ld.controller;

import pathfinder.Coordinate;
import hxd.Cursor;
import h2d.Interactive;
import ld.data.Globals;
import h2d.col.Point;
import hxd.Key;

class InputController {
	var isDrag:Bool = false;
	var startDragPosition:Point = null;

	public function new() {
		hxd.Window.getInstance().addEventTarget(onEvent);
	}

	function onEvent(event:hxd.Event) {
		// keyboard
		if (event.kind == EKeyDown) {
			switch (event.keyCode) {
				case Key.SPACE:
					{
						Game.view.clearUnitSelection();
						Game.view.pathView.clearPath();
					}

				case Key.DOWN:

				case Key.UP:

				case Key.LEFT:

				case Key.ESCAPE:
			}
		} else if (event.kind == EPush) {
			if (event.button == Key.MOUSE_LEFT) {
				startDragPosition = new Point(event.relX + Game.view.camera.viewX * Globals.SCALE_FACTOR,
					event.relY + Game.view.camera.viewY * Globals.SCALE_FACTOR);
				isDrag = true;
			}
		} else if (event.kind == ERelease) {
			isDrag = false;
		} else if (event.kind == EMove) {
			if (isDrag) {
				Game.view.camera.viewX = (startDragPosition.x - event.relX) / Globals.SCALE_FACTOR;
				Game.view.camera.viewY = (startDragPosition.y - event.relY) / Globals.SCALE_FACTOR;
			}
		}
	}

	public function dispose() {
		hxd.Window.getInstance().removeEventTarget(onEvent);
	}
}
