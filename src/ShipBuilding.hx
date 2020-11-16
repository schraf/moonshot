import ship_building.*;
import dn.Process;

class ShipBuilding extends Process {
	public static var ME : ShipBuilding;

	public var layout: ShipLayout;
	public var panel: ShipPartPanel;
	var stats: ShipStats;

	public function new() {
		super(Main.ME);
		ME = this;
		createRootInLayers(Main.ME.root, Const.DP_BG);

		var bounds = new h2d.col.Bounds();
		bounds.set(0.0, 0.0, Const.VIEWPORT_WIDTH, Const.VIEWPORT_HEIGHT);
		var center = bounds.getCenter();
		var camera = Boot.ME.s2d.camera;
		camera.setAnchor(0.5, 0.5);
		camera.setPosition(center.x, center.y);

		var background = new Background(root);
		background.addStars(bounds);
		background.addMoon(Const.VIEWPORT_WIDTH * 0.1, Const.VIEWPORT_HEIGHT * 0.1, 0.3);
		background.addGround();

		layout = new ShipLayout(90, root);
		layout.x = 420;
		layout.y = 75;

		initPanel();

		stats = new ShipStats();
		calculateStats();

		Process.resizeAll();
	}

	private function initPanel () {
		panel = new ShipPartPanel(root);
		panel.overflow = h2d.Flow.FlowOverflow.Limit;
		panel.multiline = true;
		panel.maxWidth = Const.SHIP_PANEL_WIDTH;
		panel.x = Const.VIEWPORT_WIDTH - Const.SHIP_PANEL_WIDTH - 100;
		panel.y = 100;

		var partSize = Math.floor(Const.SHIP_PANEL_WIDTH * 0.5);
		panel.addPart(Data.shipPart.get(Data.ShipPartKind.Battery), partSize, partSize);
		panel.addPart(Data.shipPart.get(Data.ShipPartKind.Booster), partSize, partSize);
		panel.addPart(Data.shipPart.get(Data.ShipPartKind.Package), partSize, partSize);
		panel.addPart(Data.shipPart.get(Data.ShipPartKind.Laser), partSize, partSize);
		panel.addPart(Data.shipPart.get(Data.ShipPartKind.SolarPanel), partSize, partSize);
	}

	public function calculateStats() {
		stats.clear();

		for (cell in layout.cells) {
			var part = cell.getPart();

			if (part != null) {
				stats.addMass(part.mass);
				stats.addCost(part.cost);

				if (part.power_capacity > 0) {
					stats.addFuel(part.power_capacity);
				}
			}
		}
	}

}

