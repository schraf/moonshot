import ship_building.ShipPart;
import hxd.Res;
import dn.Process;
import hxd.Key;

class ShipBuilding extends Process {
    public static var ME : ShipBuilding;
    
    public var ship: Array<Array<ShipPart>>;

	public var ca : dn.heaps.Controller.ControllerAccess;
    
    var background : h2d.Bitmap;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		createRootInLayers(Main.ME.root, Const.DP_BG);
        
        background = new h2d.Bitmap(root);
        background.tile = Res.platform.toTile();

        var xStart: Int = Math.ceil(w() / 2 / Const.GRID) - Math.ceil(Const.SHIP_WIDTH / 2 * Const.SHIP_PART_SCALE);
        var yStart: Int = Math.ceil(h() / 2 / Const.GRID) - Math.ceil(Const.SHIP_HEIGHT / 2 * Const.SHIP_PART_SCALE);
        ship = [
            for(x in 0...Const.SHIP_WIDTH) [
                for(y in 0...Const.SHIP_HEIGHT) new ShipPart(xStart + (x * Const.SHIP_PART_SCALE),yStart + (y * Const.SHIP_PART_SCALE))
            ]
        ];

		Process.resizeAll();
	}

	override function onResize() {
		super.onResize();

        var sx = w()/background.tile.width;
		var sy = h()/background.tile.height;
        var s = Math.min(sx, sy);
		background.setScale(s);
		background.x = ( w()*0.5 - background.tile.width*s*0.5 );
		background.y = ( h()*0.5 - background.tile.height*s*0.5 );
	}

	function gc() {
		if( ShipPart.GC==null || ShipPart.GC.length==0 )
			return;

		for(e in ShipPart.GC)
			e.dispose();
		ShipPart.GC = [];
	}

	override function onDispose() {
        super.onDispose();
        background = null;

		for(e in ShipPart.ALL)
			e.destroy();
		gc();
	}

	override function preUpdate() {
		super.preUpdate();

		for(e in ShipPart.ALL) if( !e.destroyed ) e.preUpdate();
	}

	override function postUpdate() {
		super.postUpdate();

		for(e in ShipPart.ALL) if( !e.destroyed ) e.postUpdate();
		gc();
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		for(e in ShipPart.ALL) if( !e.destroyed ) e.fixedUpdate();
	}

	override function update() {
		super.update();

		for(e in ShipPart.ALL) if( !e.destroyed ) e.update();

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( ca.isKeyboardPressed(Key.ESCAPE) )
				if( !cd.hasSetS("exitWarn",3) )
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					hxd.System.exit();
			#end

			// Restart
			if( ca.selectPressed() )
				Main.ME.startGame();
		}
	}
}

