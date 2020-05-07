package ld.data;

import ld.utils.macros.ProjectMacros;

class Globals {
	// Config
	public static var skipMainMenu:Bool = true;

	// Constants
	public static var VERSION:String = "v. " + "0.1.0.1 " + ProjectMacros.getBuildDate().toString();
    public static var SCALE_FACTOR:Float = 4;
    public static var STAGE_WIDTH:Int = 160;
	public static var STAGE_HEIGHT:Int = 144;
	public static var CELL_SIZE:Int = 16;

    public static var COLOR_SET = {
		Transparent: 16777215,
		Clear: 0x00000000,
		White: 0xffffffff,
		SpringRain: 0xffc4cfa1,
		Como: 0xff8b956d,
		TimberGreen: 0xff4d533c,
		Aztec: 0xff090909
	}

	public static var MUSIC_SET = {
		TitleTheme: "track1"
	}

	public static var SFX_SET = {
		UIHover: "uiHov",
		Transition: "transition",
		MoveStone: "moveStone",
		UnitSelect: "UnitSelect",
		CrownSelect: "CrownSelect",
		UnitStep: "UnitStep",
		Wound: "Wound",
		Door: "Door",
	}

	public static inline var TITLE_SCREEN = "titleScreen";
	public static inline var CREDITS_SCREEN = "creditsScreen";
	public static inline var GAMEOVER_SCREEN = "gameoverScreen";
	public static inline var HUD_SCREEN = "hudScreen";
	public static inline var LEVELSELECT_SCREEN = "levelSelect";
	public static inline var INTRO_SCREEN = "introScreen";
}