package ship_building;

import ShipDefinition.ShipPartDefinition;
import ShipDefinition.ShipPartAttachment;

class ShipLayoutCell extends h2d.Object {

	var root: h2d.Object;
	var part: Null<Data.ShipPart>;
	var visuals: h2d.Bitmap;
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

		var grid = new h2d.Bitmap(Assets.ship.getTile("grid"), this);
		grid.width = size;
		grid.height = size;

		var gridFilter = new h2d.filter.ColorMatrix();
		gridFilter.matrix.identity();
		gridFilter.matrix.colorSet(0xFFFFFF, 0.1);
		grid.filter = gridFilter;

		this.interactive.onPush = function (event: hxd.Event) {
			setPart(ShipPartPanel.Instance.getSelectedPart());
		}
	}

	public function setPart (part: Data.ShipPart) {
		if (this.part == part) {
			return;
		}

		if (part == null) {
			this.visuals = null;
		} else {
			this.visuals = ShipVisuals.create(part, this.size, this.size, 0, this);
		}

		this.part = part;

		ShipLayout.Instance.onCellModified(this.cellX, this.cellY);
		ShipBuilding.ME.calculateStats();
	}

	public function getPart (): Data.ShipPart {
		return this.part;
	}

	public function getVisuals (): h2d.Bitmap {
		return this.visuals;
	}

	public function toDefinition (): ShipPartDefinition {
		if (this.part != null) {
			return new ShipPartDefinition(this.cellX, this.cellY, this.part, 0);
		}

		return null;
	}
}

class ShipLayout extends h2d.Flow {
	public static var Instance: ShipLayout;

	public var cells: Array<ShipLayoutCell>;

	public function new (cellSize: Float, ?parent: h2d.Object) {
		super(parent);
		Instance = this;
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

	public function getShipPartCell (x: Int, y: Int): ShipLayoutCell {
		var index = y * Const.SHIP_WIDTH + x;

		if (index >= cells.length) {
			return null;
		}

		return cells[index];
	}

	public function onCellModified (x: Int, y: Int) {
		setAttachmentsForCell(x, y);
		setAttachmentsForCell(x - 1, y);
		setAttachmentsForCell(x + 1, y);
		setAttachmentsForCell(x, y - 1);
		setAttachmentsForCell(x, y + 1);
	}

	function setAttachmentsForCell (x: Int, y: Int) {
		var cell = getShipPartCell(x, y);

		if (cell != null && cell.getPart() != null) {
			var attachments = calculateAttachmentFlags(x, y);
			ShipVisuals.setAttachments(cell.getVisuals(), attachments);
		}
	}

	function calculateAttachmentFlags (x: Int, y: Int): Int {
		var flags = 0;

		var top = getShipPartCell(x, y - 1);
		var bottom = getShipPartCell(x, y + 1);
		var left = getShipPartCell(x - 1, y);
		var right = getShipPartCell(x + 1, y);

		if (top != null && top.getPart() != null) {
			flags |= ShipPartAttachment.Top;
		}

		if (bottom != null && bottom.getPart() != null) {
			flags |= ShipPartAttachment.Bottom;
		}

		if (left != null && left.getPart() != null) {
			flags |= ShipPartAttachment.Left;
		}

		if (right != null && right.getPart() != null) {
			flags |= ShipPartAttachment.Right;
		}

		return flags;
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
