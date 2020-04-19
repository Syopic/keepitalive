package ld.view.ui;

import hxd.Res;
import ld.data.Globals;
import hxd.Key;
import h2d.Bitmap;
import h2d.Object;

class IntroScreen extends h2d.Object {
	var bgImage:Bitmap;

	public function new(parent:Object) {
		super(parent);

		var tile = hxd.Res.img.concept.toTile();
		bgImage = new Bitmap(tile, this);

		

		hxd.Window.getInstance().addEventTarget(onEvent);
	}

	function onEvent(event:hxd.Event) {
		// keyboard
		if (event.kind == EKeyDown) {
			switch (event.keyCode) {
				case Key.ESCAPE:
					Game.uiManager.changeScreen(Globals.LEVELSELECT_SCREEN);
			}
		}
	}

	public function dispose() {
		hxd.Window.getInstance().removeEventTarget(onEvent);
	}
}
