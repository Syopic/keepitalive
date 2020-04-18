package ld.view.ui;

import hxd.Cursor;
import h2d.Interactive;
import h2d.Tile;
import ld.view.ui.components.ResultviewComp;
import h2d.filter.Glow;
import h2d.Text;
import hxd.Res;
import h3d.Vector;
import ld.view.ui.components.GamemenuviewComp;
import ld.view.ui.components.MuteSoundButton;
import ld.data.Globals;
import hxd.Key;
import ld.view.ui.components.MenuviewComp;
import h2d.Flow.FlowAlign;
import h2d.Bitmap;
import h2d.Object;

class HUDScreen extends h2d.Object {
	var bgImage:Bitmap;
	var menuView:GamemenuviewComp;
	var resultView:ResultviewComp;
	var panelFlow:h2d.Flow;
	var resultFlow:h2d.Flow;
	var tint:Bitmap;
	var winTF:Text;
	var scoreTF:Text;


	public function new(parent:Object) {
		super(parent);

		var tile = hxd.Res.img.hudScreen.toTile();
		bgImage = new Bitmap(tile, this);

		tint = new Bitmap(hxd.Res.img.tint.toTile(), this);
		var interaction = new Interactive(Globals.STAGE_WIDTH, Globals.STAGE_HEIGHT, tint);
		// interaction.propagateEvents = true;
		interaction.cursor = Cursor.Default;

		panelFlow = new h2d.Flow(this);
		panelFlow.padding = 5;

		panelFlow.verticalSpacing = 5;

		panelFlow.paddingTop = 50;
		panelFlow.paddingLeft = 32;

		resultFlow = new h2d.Flow(this);
		resultFlow.padding = 5;

		resultFlow.verticalSpacing = 5;
		resultFlow.layout = Vertical;

		resultFlow.paddingTop = 70;
		resultFlow.paddingLeft = 32;

		menuView = new GamemenuviewComp(panelFlow);
		Game.uiManager.style.addObject(menuView);
		

		winTF = new Text(Res.font.gb.toFont());
		
		winTF.setScale(2);
		winTF.textColor = Globals.COLOR_SET.Como;
		winTF.text = "LEVEL\nCOMPLETE";
		winTF.textAlign = Center;
		winTF.setPosition(84, 20);
		this.addChild(winTF);
		winTF.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
		resultView = new ResultviewComp(resultFlow);
		Game.uiManager.style.addObject(resultView);


		panelFlow.visible = false;
		resultFlow.visible = false;
		winTF.visible = false;
		tint.visible = false;

		hxd.Window.getInstance().addEventTarget(onEvent);

		bgImage.filter = new Glow(Globals.COLOR_SET.Aztec, 1, 0.1);
		
	}

	public function pause() {
		panelFlow.visible = !panelFlow.visible;
		tint.visible = panelFlow.visible;
		Game.controller.pause(panelFlow.visible);
		if (!panelFlow.visible) {
			menuView.clearAll();
			menuView.currentIndex = 0;
			menuView.changeIndex(0);
		} else
			menuView.continueButton.setFocus(true);
	}

	public function showResult() {
		resultFlow.visible = true;
		winTF.visible = true;
		tint.visible = true;
	}

	public function setScore(value:Int) {
		// scoreTF.text = value + "";
	}

	function onEvent(event:hxd.Event) {
		// keyboard
		if (event.kind == EKeyDown) {
			if (event.keyCode != Key.ESCAPE && !Game.controller.isPause && Game.uiManager.briefComp != null) {
				Game.uiManager.briefComp.next();
			}
			switch (event.keyCode) {
				case Key.DOWN:
					{
						if (panelFlow.visible)
							menuView.changeIndex(1);
					}
				case Key.UP:
					{
						if (panelFlow.visible)
							menuView.changeIndex(-1);
					}
				case Key.ENTER:
					{
						if (panelFlow.visible)
							menuView.doAction();
					}
				case Key.ESCAPE:
					{
						pause();
					}
			}
		}
	}

	public function dispose() {
		hxd.Window.getInstance().removeEventTarget(onEvent);
		panelFlow.visible = false;
		resultFlow.visible = false;
		winTF.visible = false;
		tint.visible = false;
		Game.view.dispose();
	}
}
