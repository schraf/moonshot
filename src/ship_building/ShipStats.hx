package ship_building;

import h2d.Text;
import h2d.Flow.FlowAlign;
import dn.Process;

class ShipStats {
    var flow: h2d.Flow;
    var spr: HSprite;

    public var _mass: Int = 0;
    public var _cost: Int = 0;
    public var _fuel: Int = 0;

    private var massText: Text;
    private var costText: Text;
    private var fuelText: Text;

    public function new() {
        spr = new HSprite(Assets.tiles);
        ShipBuilding.ME.root.add(spr, Const.DP_MAIN);

        flow = new h2d.Flow(spr);
        flow.layout = Vertical;
        flow.fillWidth = true;
        flow.fillHeight = true;
        flow.horizontalAlign = Left;
        flow.verticalAlign = Middle;
        
        fuelText = addText();
        costText = addText();
        massText = addText();
    }

    public function clear() {
        _mass = _cost = _fuel = 0;
    }

    public function mass() {return _mass;}
    public function fuel() {return _fuel;}
    public function cost() {return _cost;}

    public function addMass(mass: Int) {
        _mass += mass;
        massText.text = format("Mass",_mass);
    }
    public function addCost(cost: Int) {
        _cost += cost;
        costText.text = format("Cost",_cost);
    }
    public function addFuel(fuel: Int) {
        _fuel += fuel;
        fuelText.text = format("Fuel",_fuel);
    }

    function addText(str="", c=0xFFFFFF) {
		var tf = new h2d.Text(Assets.fontPixel, flow);
		tf.scale(3);
		tf.text = str;
        tf.textColor = c;
        return tf;
    }

    function format(title: String, v: Int) {
        return " " + title + ": " + v;
    }
}
