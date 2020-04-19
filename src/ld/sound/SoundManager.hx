package ld.sound;

import ld.data.Globals;
import hxd.res.Sound;
import hxd.snd.Channel;

class SoundManager {
	var sounds:Map<String, Sound> = new Map<String, Sound>();
	var channels:Map<String, Channel> = new Map<String, Channel>();
	public var isMute:Bool = false;

	public function new() {
		init();
	}

	private function init() {
		if (hxd.res.Sound.supportedFormat(Mp3)) {
			// music
			sounds[Globals.MUSIC_SET.TitleTheme] = hxd.Res.sound.music.track1;
			// sfx
			sounds[Globals.SFX_SET.UIHover] = hxd.Res.sound.sfx.uiH2;
			sounds[Globals.SFX_SET.Transition] = hxd.Res.sound.sfx.transition;
			sounds[Globals.SFX_SET.MoveStone] = hxd.Res.sound.sfx.moveStone;
			sounds[Globals.SFX_SET.UnitSelect] = hxd.Res.sound.sfx.unitSelect;
			sounds[Globals.SFX_SET.UnitStep] = hxd.Res.sound.sfx.step;
			sounds[Globals.SFX_SET.CrownSelect] = hxd.Res.sound.sfx.CrownSelect;
			sounds[Globals.SFX_SET.Wound] = hxd.Res.sound.sfx.wound;
			sounds[Globals.SFX_SET.Door] = hxd.Res.sound.sfx.door;
		}
	}

	public function playSound(name:String, volume:Float = 1, loop:Bool = false, oneInstance:Bool = false) {
		var sound:Sound = sounds[name];
		if (sound != null && (channels[name] == null || !oneInstance)) {
			var channel = sound.play(loop);
			channel.mute = this.isMute;
			channel.volume = volume;
			channels[name] = channel;
		}
	}

	public function stopSound(name:String) {
		if (channels[name] != null) {
			channels[name].stop();
			channels.remove(name);
		}
	}

	public function pause(isPause:Bool = true) {
		for (c in channels) {
			c.pause = isPause;
		}
	}

	public function mute(isMute:Bool = true) {
		this.isMute = isMute;
		for (c in channels) {
			c.mute = isMute;
		}
	}
}
