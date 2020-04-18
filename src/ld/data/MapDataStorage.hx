package ld.data;

import pathfinder.EHeuristic;
import pathfinder.Coordinate;
import pathfinder.Pathfinder;
import h2d.TileGroup;
import h2d.Tile;
import hxd.res.Resource;

class MapDataStorage {
	public var mapWidth:Int = 0;
	public var mapHeight:Int = 0;
	public var tileWidth:Int = 0;
	public var tileHeight:Int = 0;

	public var tileImage:Tile;
    public var tileItems:Array<TileItem>;

	private var tiledMapData:TiledMapData;
	private var mapData:MapData;
	
    private var tileSet:TiledMapSet;
	private var tiles:Array<Tile>;
	private var pathFinder:Pathfinder;

	public function new(mapData:Resource) {
		tileImage = hxd.Res.img.tileSet.toTile();
		parse(mapData);
	}
	
	private function parse(res:Resource) {
		tiledMapData = haxe.Json.parse(res.entry.getText());
		mapWidth = tiledMapData.width;
		mapHeight = tiledMapData.height;
		tileWidth = tiledMapData.tilewidth;
		tileHeight = tiledMapData.tileheight;
		tileSet = tiledMapData.tilesets[0];
		tileItems = tileSet.tiles;
		tiles = [
			for (y in 0...Std.int(tileImage.height / tileHeight))
				for (x in 0...Std.int(tileImage.width / tileWidth))
					tileImage.sub(x * tileWidth, y * tileHeight, tileWidth, tileHeight)
		];
		
		mapData = new MapData(mapWidth, mapHeight);

		updateWalkableMap();
		pathFinder = new Pathfinder(mapData);
	}

	public function updateWalkableMap() {
		for (y in 0...mapHeight) {
			for (x in 0...mapWidth) {
				var tid = getTileId(x, y, 0);
				mapData.setWalkable(x, y, tid == 0);
			}
		}
	}

	public function setWalkable(x:Int, y:Int, value:Bool) {
		mapData.setWalkable(x, y, value);
	}
	
	public function findPath(from:Coordinate, to:Coordinate):Array<Coordinate> {
		return pathFinder.createPath(from, to, EHeuristic.PRODUCT, false, true);
	}
    
    public function getTileById(id:Int):Tile {
		return tiles[id];
    }
    
    public function getTile(x:Int, y:Int, layer:Int = 0):Tile {
		return getTileById(getTileId(x, y, layer));
	}

	public function getTileId(x:Int, y:Int, layer:Int = 0):Int {
		return tiledMapData.layers[layer].data[x + y * mapWidth];
	}

	public function getObjects(layer:Int = 1):Array<MapObject> {
		return tiledMapData.layers[layer].objects;
	}

	// public function getObjectById(id:Int, layer:Int = 2):MapObject {
	//     return  tiledMapData.layers[layer].objects;
	// }

	public function getTileItemById(id:Int):TileItem {
		for (t in tileSet.tiles) {
			if (t.id == id - 1) {
				return t;
			}
		}
		return null;
	}

	public function getTileItem(x:Int, y:Int, layer:Int = 0):TileItem {
		var tid = tiledMapData.layers[0].data[x + y * mapWidth];
		return tileSet.tiles[tid - 1];
	}
}
enum UnitType {
	King;
	Defender;
	Archer;
}

enum CellType {
	Wall;
	WinTarget;
}


typedef TiledMapData = {
	var layers:Array<TiledMapLayer>;
	var tilesets:Array<TiledMapSet>;
	var tilewidth:Int;
	var tileheight:Int;
	var width:Int;
	var height:Int;
}

typedef TiledMapLayer = {
	var data:Array<Int>;
	var name:String;
	var type:String;
	var image:String;
	var opacity:Float;
	var offsetx:Int;
	var offsety:Int;
	var x:Int;
	var y:Int;
	var objects:Array<MapObject>;
}

typedef MapObject = {
	@:optional var gid:Int;
	@:optional var id:Int;
	@:optional var x:Int;
	@:optional var y:Int;
	@:optional var rotation:Float;
	@:optional var name:String;
	@:optional var type:String;
	@:optional var width:Int;
	@:optional var height:Int;
	@:optional var properties:Array<ObjectProperty>;
}

typedef TileItem = {
	id:Int,
	type:String,
	properties:Array<ObjectProperty>
}

typedef TiledMapSet = {
	var firstgid:Int;
	var name:String;
	var source:String;
	var columns:Int;
	var tilecount:Int;
	var tiles:Array<TileItem>;
}

typedef ObjectProperty = {
	var name:String;
	var type:String;
	var value:Any;
}
