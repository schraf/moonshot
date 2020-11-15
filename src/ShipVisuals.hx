
class ShipVisuals {

	static function createPartVisuals(tileName: String, width: Float, height: Float, ?parent: h2d.Object): h2d.Drawable {
		var part = new h2d.Bitmap(Assets.tiles.getTile(tileName), parent);
		part.width = width;
		part.height = height;
		return part;
	}

	static function createSimpleShipPart(tileName: String, width: Float, height: Float, ?parent: h2d.Object): h2d.Drawable {
		var base = createPartVisuals("base", width, height, parent);
		createPartVisuals(tileName, width, height, base);
		return base;
	}

	public static function create(partType: ship_building.ShipPartType, width: Float, height: Float, ?parent: h2d.Object): h2d.Drawable {
		switch (partType) {
			case ship_building.ShipPartType.Package: return createSimpleShipPart("storage", width, height, parent);
			case ship_building.ShipPartType.Booster: return createSimpleShipPart("thruster", width, height, parent);
			case ship_building.ShipPartType.Laser: return createSimpleShipPart("laser", width, height, parent);
			case ship_building.ShipPartType.Battery: return createSimpleShipPart("battery", width, height, parent);
			case ship_building.ShipPartType.SolarPanel: return createSimpleShipPart("solar", width, height, parent);
			case ship_building.ShipPartType.Empty: return null;
			default: ui.Console.ME.error('unsupported ship part visual $partType');
		}

		return null;
	}
}
