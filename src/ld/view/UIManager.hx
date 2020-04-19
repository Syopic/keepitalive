package ld.view;

import ld.view.ui.IntroScreen;
import hxd.Res;
import ld.view.ui.components.MuteSoundButton;
import ld.view.ui.HUDScreen;
import h2d.domkit.Style;
import ld.view.ui.GameOverScreen;
import ld.view.ui.LevelSelectScreen;
import ld.data.Globals;
import ld.view.ui.TitleScreen;
import ld.view.ui.CreditsScreen;
import ld.view.ui.GameOverScreen;
import ld.view.ui.TransitionView;
import h2d.Object;
import ld.view.ui.components.BriefComp;
import ld.view.ui.components.TextBlob;

class UIManager extends Object {
	public var style:Style = new Style();

	private var transitionView:TransitionView;
	private var titleScreen:TitleScreen;
	private var creditsScreen:CreditsScreen;
	private var gameOverScreen:GameOverScreen;
	private var levelSelectScreen:LevelSelectScreen;
	private var introScreen:IntroScreen;

	public var briefComp:BriefComp;

	var muteSoundBtn:MuteSoundButton;

	public var hudScreen:HUDScreen;

	private var inGameContainer:Object;
	private var screenContainer:Object;

	public var currentScreen:String = "";
	public var textBlobs:Map<String, TextBlob>;
	public var selectedLevel:Int = 1;

	public function new(parent:Object) {
		super(parent);
		style.load(hxd.Res.styles.styles);

		textBlobs = new Map<String, TextBlob>();
		inGameContainer = new Object(this);
		screenContainer = new Object(this);
		muteSoundBtn = new MuteSoundButton(this);
		muteSoundBtn.setPosition(146, 6);
		transitionView = new TransitionView(this);
		if (Globals.skipMainMenu) {
			changeScreen(Globals.HUD_SCREEN, true);
		} else
			changeScreen(Globals.TITLE_SCREEN, true);
	}

	public function changeScreen(screenName:String, isFirst:Bool = false, isRestart:Bool = false) {
		currentScreen = screenName;
		hideBrief("");
		if (!isFirst)
			transitionView.show();
		Game.soundManager.playSound(Globals.SFX_SET.Transition, 0.5);
		haxe.Timer.delay(function() {
			if (creditsScreen != null) {
				creditsScreen.dispose();
				creditsScreen.remove();
			}
			if (gameOverScreen != null) {
				gameOverScreen.dispose();
				gameOverScreen.remove();
			}
			if (hudScreen != null) {
				Game.controller.endGame();
				hudScreen.dispose();
				hudScreen.remove();
			}
			if (titleScreen != null) {
				titleScreen.dispose();
				titleScreen.remove();
			}
			if (levelSelectScreen != null) {
				levelSelectScreen.dispose();
				levelSelectScreen.remove();
			}

			if (introScreen != null) {
				introScreen.dispose();
				introScreen.remove();
			}
			switch (screenName) {
				case Globals.TITLE_SCREEN:
					{
						// Game.soundManager.stopSound(Globals.MUSIC_SET.TitleTheme);
						Game.soundManager.playSound(Globals.MUSIC_SET.TitleTheme, 0.5, true, true);
						titleScreen = new TitleScreen(screenContainer);
					}
				case Globals.CREDITS_SCREEN:
					{
						creditsScreen = new CreditsScreen(screenContainer);
					}
				case Globals.GAMEOVER_SCREEN:
					{
						gameOverScreen = new GameOverScreen(screenContainer);
					}
				case Globals.LEVELSELECT_SCREEN:
					{
						levelSelectScreen = new LevelSelectScreen(screenContainer);
					}
				case Globals.INTRO_SCREEN:
					{
						Game.soundManager.stopSound(Globals.MUSIC_SET.TitleTheme);
						introScreen = new IntroScreen(screenContainer);
						showBrief(Globals.INTRO_SCREEN, introScreen);
					}
				case Globals.HUD_SCREEN:
					{
						Game.soundManager.stopSound(Globals.MUSIC_SET.TitleTheme);
						// Game.soundManager.playSound(Globals.MUSIC_SET.TitleTheme, 0.5, true, true);
						Game.controller.startGame(selectedLevel);
						if (selectedLevel < 4 && !isRestart) {
							showBrief("level " + selectedLevel, inGameContainer);
							Game.controller.lockInput(true);
						}
						// showTextBlob(30, 30, "MOCK\nMOCLOCK", 4200);
						// Game.soundManager.playSound(Globals.MUSIC_SET.TitleTheme, 0.6, true, true);
						hudScreen = new HUDScreen(screenContainer);
					}
			}
		}, 250);
	}

	public function showTextBlob(x:Int, y:Int, text:String, duration:Int = 0):String {
		var tb = new TextBlob(text, duration, Game.view.uiContainer);
		tb.setPosition(x, y);
		textBlobs[tb.guid] = tb;
		return tb.guid;
	}

	public function hideTextBlob(id:String) {
		if (textBlobs[id] != null) {
			textBlobs[id].remove();
			textBlobs[id] = null;
		}
	}

	public function hideBrief(id:String) {
		if (briefComp != null) {
			briefComp.remove();
			briefComp.dispose();
			briefComp = null;
			Game.controller.lockInput(false);
		}
		if (id == Globals.INTRO_SCREEN) {
			Game.uiManager.changeScreen(Globals.LEVELSELECT_SCREEN);
		}
	}

	public function update(dt:Float) {
		if (transitionView != null)
			transitionView.update(dt);

		if (briefComp != null)
			briefComp.update(dt);
	}

	public function dispose() {
		if (titleScreen != null)
			titleScreen.dispose();
		if (creditsScreen != null)
			creditsScreen.dispose();
		if (gameOverScreen != null)
			creditsScreen.dispose();
		if (levelSelectScreen != null)
			levelSelectScreen.dispose();
		if (hudScreen != null)
			hudScreen.dispose();
		if (briefComp != null)
			briefComp.dispose();
		if (introScreen != null)
			introScreen.dispose();
	}

	public function showBrief(id, container) {
		hideBrief("");
		if (briefComp != null) {
			briefComp.dispose();
		}
		if (id == "introScreen") {
			briefComp = new BriefComp(id);
			container.addChild(briefComp);
			briefComp.addMessage({img: Res.img.crownBrief.toTile(), text: "Don't you think\nthis game looks\ntoo ordinary?", isLeft: true});
			briefComp.addMessage({img: Res.img.crownBrief.toTile(), text: "Knights,\ndungeons?", isLeft: true});
			briefComp.addMessage({img: Res.img.defBrief.toTile(), text: "I'm ok", isLeft: false});
			briefComp.addMessage({img: Res.img.crownBrief.toTile(), text: "Okay, and what\nto do here?", isLeft: true});
			briefComp.addMessage({img: Res.img.defBrief.toTile(), text: "We have to get you\nto the door", isLeft: false});
			briefComp.addMessage({img: Res.img.defBrief.toTile(), text: "It is necessary\nto stay close\nand bypass traps", isLeft: false});
			briefComp.addMessage({img: Res.img.archBrief.toTile(), text: "You must know\nthat you will die\nvery often", isLeft: false});
			briefComp.addMessage({img: Res.img.crownBrief.toTile(), text: "This is provided\nthat the game\nwill be played", isLeft: true});
			briefComp.addMessage({img: Res.img.crownBrief.toTile(), text: "Ha ha", isLeft: true});
			briefComp.addMessage({img: Res.img.crownBrief.toTile(), text: "And what will be\nthe enemies?", isLeft: true});
			briefComp.addMessage({img: Res.img.archBrief.toTile(), text: "It looks like\nthey are not\nready yet. Heh", isLeft: false});
			briefComp.addMessage({img: Res.img.crownBrief.toTile(), text: "Well. Remember -\nI have to stay\nalive!", isLeft: true});
			briefComp.start();
		} else if (id == "level 1") {
			briefComp = new BriefComp(id);
			container.addChild(briefComp);
			briefComp.addMessage({img: Res.img.crownBrief.toTile(), text: "It seems\nvery simple", isLeft: true});
			briefComp.addMessage({img: Res.img.defBrief.toTile(), text: "archer,\nstand below me", isLeft: false});
			briefComp.addMessage({img: Res.img.defBrief.toTile(), text: "And you stand\nbehind him", isLeft: false});
			briefComp.addMessage({img: Res.img.archBrief.toTile(), text: "you can always\nreplay level\nHeh", isLeft: false});

			briefComp.start();
		} else if (id == "level 2") {
			briefComp = new BriefComp(id);
			container.addChild(briefComp);
			briefComp.addMessage({img: Res.img.defBrief.toTile(), text: "I can move\nstones!\nHo ho ho", isLeft: false});
			briefComp.addMessage({img: Res.img.archBrief.toTile(), text: "Think about\nnot getting\ntrapped", isLeft: false});

			briefComp.start();
		} else if (id == "level 3") {
			briefComp = new BriefComp(id);
			container.addChild(briefComp);
			briefComp.addMessage({img: Res.img.archBrief.toTile(), text: "You can drag\nwith the\nmouse wheel", isLeft: false});

			briefComp.start();
		} else {
			briefComp.dispose();
			briefComp = null;
		}

	}
}
