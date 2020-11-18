
class ShipVisuals {

	static function createPartVisuals(tileName: String, width: Float, height: Float, ?parent: h2d.Object): h2d.Drawable {
		var part = new h2d.Bitmap(Assets.ship.get(tileName), parent);
		part.width = width;
		part.height = height;
		return part;
	}

	static function createSimpleShipPart(tileName: String, width: Float, height: Float, ?parent: h2d.Object): h2d.Drawable {
		var base = createPartVisuals("base", width, height, parent);
		createPartVisuals(tileName, width, height, base);
		return base;
	}

	public static function create(part: Data.ShipPart, width: Float, height: Float, ?parent: h2d.Object): h2d.Drawable {
		var base = createPartVisuals("base", width, height, parent);
		createPartVisuals(part.tile_name, width, height, base);
		return base;
	}
}
