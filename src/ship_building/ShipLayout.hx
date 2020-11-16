package ship_building;

import ShipDefinition.ShipPartDefinition;

class ShipLayoutCell extends h2d.Object {

	var root: h2d.Object;
	var part: Null<Data.ShipPart>;
	var visuals: h2d.Drawable;
	var interactive: h2d.Interactive;
	var cellX: Int;
	var cellY: Int;
	var size: Float;
	var layout: ShipLayout;

	public function new (x: Int, y: Int, size: Float, layout: ShipLayout) {
		super(layout);
		this.cellX = x;
		this.cellY = y;
		this.size = size;
		this.interactive = new h2d.Interactive(size, size, this);
		this.layout = layout;

		this.interactive.onPush = function (event: hxd.Event) {
			setPart(ShipPartPanel.Instance.getSelectedPart());
		}
	}

	public function setPart (part: Null<Data.ShipPart>) {
		if (this.part == part) {
			return;
		}

		if (part == null) {
			this.visuals = null;
		} else {
			this.visuals = ShipVisuals.create(part, this.size, this.size, this);
		}

		this.part = part;

		ShipBuilding.ME.calculateStats();
	}

	public function getPart (): Data.ShipPart {
		return this.part;
	}

	public function toDefinition (): ShipPartDefinition {
		if (this.part != null) {
			return new ShipPartDefinition(this.cellX, this.cellY, this.part);
		}

		return null;
	}
}

class ShipLayout extends h2d.Flow {
	public var cells: Array<ShipLayoutCell>;

	public function new (cellSize: Float, ?parent: h2d.Object) {
		super(parent);
		debug = true;
		cells = [];

		this.overflow = h2d.Flow.FlowOverflow.Limit;
		this.multiline = true;
		this.maxWidth = Math.ceil(Const.SHIP_WIDTH * cellSize);

		for (y in 0...Const.SHIP_HEIGHT) {
			for (x in 0...Const.SHIP_WIDTH) {
				cells.push(new ShipLayoutCell(x, y, cellSize, this));
			}

		}
	}

	public function toShipDefinition (): ShipDefinition {
		var definition = new ShipDefinition();

		for (cell in this.cells) {
			var partDefinition = cell.toDefinition();

			if (partDefinition != null) {
				definition.parts.push(partDefinition);
			}
		}

		return definition;
	}
}
