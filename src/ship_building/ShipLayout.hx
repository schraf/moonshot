package ship_building;

import ShipDefinition.ShipPartDefinition;
import ShipDefinition.ShipPartAttachment;

class ShipLayoutCell extends h2d.Object {

	var root: h2d.Object;
	public var part: Null<Data.ShipPart>;
	var visuals: h2d.Bitmap;
	var interactive: h2d.Interactive;
	var cellX: Int;
	var cellY: Int;
	var partRotation: Int;
	var size: Float;
	var layout: ShipLayout;
	var id: String;

	public var grid: h2d.Bitmap;

	public function new (x: Int, y: Int, size: Float, layout: ShipLayout) {
		super(layout);
		this.cellX = x;
		this.cellY = y;
		this.partRotation = 0;
		this.size = size;
		this.interactive = new h2d.Interactive(size, size, this);
		this.layout = layout;
		this.id = '${this.cellX}.${this.cellY}';

		grid = new h2d.Bitmap(Assets.ship.getTile("grid"), this);
		grid.width = size;
		grid.height = size;

		var gridFilter = new h2d.filter.ColorMatrix();
		gridFilter.matrix.identity();
		gridFilter.matrix.colorSet(0xFF0000, 0.1);
		grid.filter = gridFilter;

		this.interactive.enableRightButton = true;

		this.interactive.onPush = function (event: hxd.Event) {
			if (event.button == 0) {
				setPart(ShipPartPanel.Instance.getSelectedPart());
			} else {
				setPart(null);
			}
		}

		this.interactive.onWheel = function (event: hxd.Event) {
			if (part != null && part.flags.has(Data.ShipPart_flags.rotatable)) {
				if (event.wheelDelta > 0) {
					this.partRotation = (this.partRotation + 90) % 360;
				} else if (event.wheelDelta < 0) {
					this.partRotation = (this.partRotation + 360 - 90) % 360;
				}

				setVisuals(part);
				ShipLayout.Instance.onCellModified(this.cellX, this.cellY);
			}
		}
	}

	public function setPart (part: Data.ShipPart) {
		if (this.part == part) {
			return;
		}

		if (this.part != null && this.part.flags.has(Data.ShipPart_flags.locked)) {
			return;
		}
		
		if ((part != null && !part.flags.has(Data.ShipPart_flags.locked)) &&
			!ShipLayout.Instance.isCellConnected(cellX, cellY)) {
				return;
			}

		if (this.visuals != null) {
			this.visuals.remove();
			this.visuals = null;
		}

		// reset rotation
		this.partRotation = 0;

		if (part != null) {
			setVisuals(part);
		}

		this.part = part;

		ShipLayout.Instance.onCellModified(this.cellX, this.cellY);
		ShipBuilding.ME.calculateStats();
	}

	function setVisuals(part: Data.ShipPart) {
		if (this.visuals != null) {
			this.visuals.remove();
		}

		this.visuals = ShipVisuals.create(this.id, part, this.size, this.size, this.partRotation, 0, this);
	}

	public function getPart (): Data.ShipPart {
		return this.part;
	}

	public function getVisuals (): h2d.Bitmap {
		return this.visuals;
	}

	public function toDefinition (): ShipPartDefinition {
		if (this.part != null) {
			var attachments = ShipLayout.Instance.calculateAttachmentFlags(this.cellX, this.cellY);
			return new ShipPartDefinition(this.id, this.cellX, this.cellY, this.partRotation, this.part, attachments);
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
		this.colWidth = Math.ceil(cellSize);

		for (y in 0...Const.SHIP_HEIGHT) {
			for (x in 0...Const.SHIP_WIDTH) {
				cells.push(new ShipLayoutCell(x, y, cellSize, this));
			}

		}

		getShipPartCell(Math.floor(Const.SHIP_WIDTH / 2), Math.floor(Const.SHIP_HEIGHT / 2)).setPart(Data.shipPart.get(Data.ShipPartKind.Core));
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

		updateColorForCell(x - 1, y);
		updateColorForCell(x + 1, y);
		updateColorForCell(x, y - 1);
		updateColorForCell(x, y + 1);
	}

	function setAttachmentsForCell (x: Int, y: Int) {
		var cell = getShipPartCell(x, y);

		if (cell != null && cell.getPart() != null) {
			var attachments = calculateAttachmentFlags(x, y);
			ShipVisuals.setAttachments(cell.getVisuals(), attachments);
		}
	}

	function updateColorForCell(x: Int, y: Int) {
		var cell = getShipPartCell(x, y);

		if (cell != null) {
			var c = isCellConnected(x, y) ? 0xFFFFFF : 0xFF0000;

			var gridFilter = new h2d.filter.ColorMatrix();
			gridFilter.matrix.identity();
			gridFilter.matrix.colorSet(c, 0.1);
			cell.grid.filter = gridFilter;
		}
	}

	public function isCellConnected(x: Int, y: Int) {
		var left = getShipPartCell(x - 1, y);
		var right = getShipPartCell(x + 1, y);
		var up = getShipPartCell(x, y - 1);
		var down = getShipPartCell(x, y + 1);

		if ((left == null || left.part == null) &&
			(right == null || right.part == null) &&
			(up == null || up.part == null) &&
			(down == null || down.part == null)) {
				return false;
			}
		return true;
	}

	public function calculateAttachmentFlags (x: Int, y: Int): Int {
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

	public function update () {
		for (cell in this.cells) {
			var part = cell.getPart();

			if (part != null && part.flags.has(Data.ShipPart_flags.rotateAnimation)) {
				var visuals = cell.getVisuals();

				for (child in visuals) {
					if (child.name != "attachment") {
						child.rotate(Const.SHIP_PART_ROTATE_SPEED * Const.FPS);
						needReflow = true;
					}
				}
			}
		}
	}
}
