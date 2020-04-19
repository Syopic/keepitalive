package ld.utils.particles;

import ld.utils.particles.ParticleSystem.EmitterOptions;
import ld.utils.particles.ParticleSystem.ParticleOptions;

class ParticleHelper {
	public static function fontan(x:Int, y:Int, color:Int) {
		var options:ParticleOptions = {
			x: x,
			y: y,
			friction: 0,
			velocity: 0.4,
			lifetime: 1,
			gravity: 30,
			color: color,
			forceX: 0,
			forceY: -1,
			forceRandomRange: 1,
			lifetimeRandomRange: 0.5
		}
		return options;
	}

	public static function trap(x:Int, y:Int, color:Int) {
		var options:ParticleOptions = {
			x: x,
			y: y,
			friction: 0,
			velocity: 0.7,
			lifetime: 0.5,
			gravity: 30,
			color: color,
			forceX: 0,
			forceY: -1,
			forceRandomRange: 3,
			lifetimeRandomRange: 0.5
		}
		return options;
	}

	public static function bloodEmiter():ParticleEmitter {
		var pOption:ParticleOptions = {
			forceX: 0,
			forceY: -0.7,
			velocity: 1,
			gravity: 50,
			lifetime: 0.2,
			color: 0xff0000,
			forceRandomRange: 0.5,
			lifetimeRandomRange: 0.2
		}
        var eOption:EmitterOptions = {
			x: 50,
			y: 50,
			rate: 1000,
			duration: 200,
			positionRange: 1
		}
		return Game.view.ps.addEmitter(eOption, pOption);
	}
}
