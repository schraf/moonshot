
class ShipPartDefinition {
	public var x: Int;
	public var y: Int;
	public var part: Data.ShipPart;

	public function new (x: Int, y: Int, part: Data.ShipPart) {
		this.x = x;
		this.y = y;
		this.part = part;
	}
}

class ShipDefinition {
	public var parts: Array<ShipPartDefinition>;

	public function new () {
		parts = [];
	}
}
