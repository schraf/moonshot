package ship_building;

import h2d.Text;

class ShipStats {
	public var panel: ui.Panel;

	public var mass: Int = 0;
	public var cost: Int = 0;
	public var fuel: Int = 0;

	private var massText: Text;
	private var costText: Text;
	private var fuelText: Text;

	public function new() {
		fuelText = addText();
		costText = addText();
		massText = addText();
		refresh();

		panel = new ui.Panel('BUILD COSTS', ShipBuilding.ME.root);
		panel.x = 30;
		panel.y = 400;
		panel.addRow(fuelText);
		panel.addRow(costText);
		panel.addRow(massText);
		panel.addFooter();
	}

	public function clear() {
		mass = cost = fuel = 0;
	}

	function addText(str="", c=0xFFFFFF) {
		var tf = new h2d.Text(Assets.fontMedium);
		tf.text = str;
		tf.textColor = c;
		return tf;
	}

	public function refresh() {
		fuelText.text = "Power: " + fuel;
		costText.text = "Cost: " + cost;
		massText.text = "Mass: " + mass;
	}
}
