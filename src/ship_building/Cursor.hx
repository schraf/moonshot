package ship_building;

import dn.heaps.Controller.ControllerAccess;

class Cursor {
    var ca : ControllerAccess;
    var spr : HSprite;

    public var destroyed(default,null) = false;
    public var cx = 0;
    public var cy = 0;
    public var xr = 0.5;
    public var yr = 1.0;

    public function new(x, y, size) {
        spr = new HSprite(Assets.tiles);
        ShipBuilding.ME.root.add(spr, Const.DP_MAIN);
        var g = new h2d.Graphics(spr);

        setPosCase(x,y);

        spr.set("empty");
        g.lineStyle(.3,0xffffff,1);
        g.moveTo(-size,-size);
        g.lineTo(-size,size);
        g.lineTo(size,size);
        g.lineTo(size,-size);
        g.lineTo(-size,-size);
    }

    public function dispose() {
      ca.dispose();
      spr.remove();
      spr = null;    
    }

    public function setPosCase(x:Int, y:Int) {
      cx = x;
      cy = y;
      xr = 0.5;
      yr = 1;
    }

    public function postUpdate() {
        spr.x = (cx+xr)*Const.GRID;
        spr.y = (cy+yr)*Const.GRID;
        spr.scaleX = 3.5 * Const.SHIP_PART_SCALE;
        spr.scaleY = 3.5 * Const.SHIP_PART_SCALE;
	}
}