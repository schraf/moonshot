
enum abstract ShipPartAttachment(Int) to Int {
	var Bottom	= 1 << 0;
	var Top		= 1 << 1;
	var Left	= 1 << 2;
	var Right	= 1 << 3;
}

class ShipPartDefinition {
	public var x: Int;
	public var y: Int;
	public var attachments: Int;
	public var part: Data.ShipPart;
	public var rotation: Int;

	public function new (x: Int, y: Int, rotation: Int, part: Data.ShipPart, attachments: Int) {
		this.x = x;
		this.y = y;
		this.rotation = rotation;
		this.attachments = attachments;
		this.part = part;
	}
}

class ShipDefinition {
	public var parts: Array<ShipPartDefinition>;

	public function new () {
		parts = [];
	}
}
