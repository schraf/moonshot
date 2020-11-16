package ship_building;

class ShipPartButton extends h2d.Object {
	static var HOVER_COLOR = 0xFFD0D0D0;
	static var HOVER_SIZE = 2.0;
	static var SELECTED_COLOR = 0xFFFFFFFF;
	static var SELECTED_SIZE = 4.0;

	var part: Data.ShipPart;
	var visuals: h2d.Drawable;
	var interactive: h2d.Interactive;
	var outline: h2d.filter.Outline;
	var selected: Bool;
	var panel: ShipPartPanel;

	public function new (part: Data.ShipPart, width: Float, height: Float, panel: ShipPartPanel) {
		super(panel);
		this.part = part;
		this.visuals = ShipVisuals.create(this.part, width, height, this);
		this.interactive = new h2d.Interactive(width, height, this.visuals);
		this.outline = new h2d.filter.Outline();
		this.selected = false;
		this.panel = panel;

		this.interactive.onOver = function (event: hxd.Event) {
			if (!this.selected) {
				this.outline.color = HOVER_COLOR;
				this.outline.size = HOVER_SIZE;
				this.visuals.filter = this.outline;
			}
		}

		this.interactive.onOut = function (event: hxd.Event) {
			if (!this.selected) {
				this.visuals.filter = null;
			}
		}

		this.interactive.onPush = function (event: hxd.Event) {
			if (!this.selected) {
				this.outline.color = SELECTED_COLOR;
				this.outline.size = SELECTED_SIZE;
				this.visuals.filter = this.outline;
				this.selected = true;
				this.panel.onSelected(this);
			}
		}
	}

	public function getPart (): Data.ShipPart {
		return this.part;
	}

	public function deselect () {
		if (this.selected) {
			this.selected = false;
			this.visuals.filter = null;
		}
	}
}

class ShipPartPanel extends h2d.Flow {
	public static var Instance: ShipPartPanel;

	var selectedPart: ShipPartButton;

	public function new (?parent: h2d.Object) {
		super(parent);
		Instance = this;
	}

	public function addPart (shipPart: Data.ShipPart, width: Float, height: Float): ShipPartButton {
		return new ShipPartButton(shipPart, width, height, this);
	}

	public function getSelectedPart (): Data.ShipPart {
		if (this.selectedPart != null) {
			return this.selectedPart.getPart();
		}

		return null;
	}

	public function onSelected (part: ShipPartButton) {
		if (part == this.selectedPart) {
			return;
		}

		if (this.selectedPart != null) {
			this.selectedPart.deselect();
		}

		this.selectedPart = part;
	}
}
