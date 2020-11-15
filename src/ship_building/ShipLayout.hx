package ship_building;

class ShipLayoutCell extends h2d.Object {

	var root: h2d.Object;
	var partType: ShipPartType;
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
		this.partType = ShipPartType.Empty;
		this.interactive = new h2d.Interactive(size, size, this);
		this.layout = layout;

		this.interactive.onPush = function (event: hxd.Event) {
			setPartType(ShipPartPanel.Instance.getSelectedPart());
		}
	}

	public function setPartType (partType: ShipPartType) {
		if (this.partType == partType) {
			return;
		}

		if (partType == ShipPartType.Empty) {
			this.visuals = null;
		} else {
			this.visuals = ShipVisuals.create(partType, this.size, this.size, this);
		}

		this.partType = partType;
	}

	public function getPartType (): ShipPartType {
		return this.partType;
	}
}

class ShipLayout extends h2d.Flow {
	var cells: Array<ShipLayoutCell>;

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
}
