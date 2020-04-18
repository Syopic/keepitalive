package ld.utils;

import ld.data.Globals;
import pathfinder.Coordinate;

class Utils {
	public static function uid():String {
		var result = "";

		for (j in 0...10) {
			if (j == 8) {
				result += "-";
			}
			result += StringTools.hex(Math.floor(Math.random() * 16));
		}

		return result.toUpperCase();
	}

	public static function safeDestroy(obj:Dynamic, ?destroy:Bool = false):Bool {
		if (obj == null)
			return false;

		var objs:Array<Dynamic> = Std.is(obj, Array) ? obj : [obj];

		for (o in objs) {
			if (o == null)
				continue;
			if (destroy)
				try {
					o.destroy();
				} catch (e:Dynamic) {
					trace("[Error on object: " + o + ", {" + e + "}");
				}

			var parent = null;
			try {
				parent = o.parent;
			} catch (e:Dynamic) {
				// trace(e);
			}
			if (parent != null)
				parent.removeChild(o);
		}
		return true;
	}

	public static function getCoord(x:Float, y:Float):Coordinate {
		return new Coordinate(Std.int(x / Globals.CELL_SIZE), Std.int(y / Globals.CELL_SIZE));
	}

	public static function getDistanceCoord(coordinate1:Coordinate, coordinate2:Coordinate):Float {
		var dx = Math.abs(coordinate1.x - coordinate2.x);
		var dy = Math.abs(coordinate1.y - coordinate2.y);

		return Math.sqrt(dx * dx + dy * dy);
	}

	public static var checkMap:Map<Coordinate, Bool> = new Map<Coordinate, Bool>();
	public static function checkRecursive(c:Coordinate, array:Array<Coordinate>):Bool {
		for (a in array) {
			if (getDistanceCoord(c, a) == 1) {
				checkMap[c]  = true;
				return checkRecursive(a, array);
				return true;
			}
		}
		return false;
	}
}
