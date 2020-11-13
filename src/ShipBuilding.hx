import hxd.Event.EventKind;
import ship_building.*;
import hxd.Res;
import dn.Process;
import hxd.Key;
import hxd.Window;

class ShipBuilding extends Process {
    public static var ME : ShipBuilding;
    
    public var ship: Array<Array<ShipPart>>;
    public var parts: Array<ShipPart>;

	public var ca : dn.heaps.Controller.ControllerAccess;
    
	var background : h2d.Bitmap;

	var xStart: Int = Math.ceil(w() / 2 / Const.GRID) - Math.ceil(Const.SHIP_WIDTH / 2 * Const.SHIP_PART_SCALE);
	var yStart: Int = Math.ceil(h() / 2 / Const.GRID) - Math.ceil(Const.SHIP_HEIGHT / 2 * Const.SHIP_PART_SCALE);

	var selected: ShipPart;
	var sxy: Array<Int>;
	var cursor: Cursor;

	var shopCursor: Cursor;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		createRootInLayers(Main.ME.root, Const.DP_BG);
        
        background = new h2d.Bitmap(root);
		background.tile = Res.platform.toTile();

		// hxd.Window.getInstance().addEventTarget(clickListener);

        ship = [
            for(x in 0...Const.SHIP_WIDTH) [
                for(y in 0...Const.SHIP_HEIGHT) new ShipPart(xStart + (x * Const.SHIP_PART_SCALE),yStart + (y * Const.SHIP_PART_SCALE))
            ]
		];

		selected = ship[0][0];
		sxy = [0,0];

		cursor = new Cursor(
			Std.int(selected.cx + selected.xr * Const.SHIP_PART_SCALE), 
			Std.int(selected.cy + selected.yr * Const.SHIP_PART_SCALE),
			Std.int(Const.SHIP_PART_SCALE * .45)
		);
		cursor.setPosCase(Math.floor(selected.centerX / Const.GRID + Const.SHIP_PART_SCALE / 2), Math.floor(selected.centerY / Const.GRID + Const.SHIP_PART_SCALE / 2));

		var startOfParts = [180,15];
		var types = ShipPartType.createAll();
		types.remove(ShipPartType.Empty);
		var shopPartScale = 2.5;
		parts = [
			for (i in 0...types.length) new ShipPart(
				Std.int(startOfParts[0] + (i % 2) * Const.SHIP_PART_SCALE * shopPartScale),
				Std.int(startOfParts[1] + Std.int(i / 2) * Const.SHIP_PART_SCALE * shopPartScale),
				types[i],
				shopPartScale
			)
		];

		shopCursor = new Cursor(
			Std.int(startOfParts[0]),
			Std.int(startOfParts[1]),
			Std.int(Const.SHIP_PART_SCALE * shopPartScale * .45)
		);
		var shopSelected = parts[currentShipPartIndex];
		cursor.setPosCase(
			Math.floor(shopSelected.centerX / Const.GRID + (Const.SHIP_PART_SCALE + shopPartScale) / 2),
			Math.floor(shopSelected.centerY / Const.GRID + (Const.SHIP_PART_SCALE + shopPartScale) / 2)
		);
		
		Process.resizeAll();
	}

	private function select(x: Int,y: Int) {
		x = x > Const.SHIP_WIDTH - 1 ? Const.SHIP_WIDTH - 1 : x;
		x = x < 0 ? 0 : x;
		y = y > Const.SHIP_HEIGHT - 1 ? Const.SHIP_HEIGHT - 1 : y;
		y = y < 0 ? 0 : y;
		sxy = [x,y];
		selected = ship[x][y];
		cursor.setPosCase(Math.floor(selected.centerX / Const.GRID + Const.SHIP_PART_SCALE / 2), Math.floor(selected.centerY / Const.GRID + Const.SHIP_PART_SCALE / 2));
	}

	// function clickListener(event : hxd.Event) {
	// 	if (event.kind == EventKind.ERelease) {
	// 		var xTile = event.relX / Const.GRID;
	// 		var yTile = event.relY / Const.GRID;
	// 		if (
	// 			xTile >= xStart && xTile < xStart + Const.SHIP_WIDTH * Const.SHIP_PART_SCALE &&
	// 			yTile >= yStart && yTile < yStart + Const.SHIP_HEIGHT * Const.SHIP_PART_SCALE
	// 		) {
	// 			var part = ship[Math.floor((xTile - xStart) / Const.GRID)][Math.floor((yTile - yStart) / Const.GRID)];
	// 			if (selected == null) {
	// 				part.select();
	// 				selected = part;
	// 			} else {
	// 				selected = null;
	// 			}
	// 		}
	// 	}
	// }

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

		cursor.dispose();
	}

	override function preUpdate() {
		super.preUpdate();

		for(e in ShipPart.ALL) if( !e.destroyed ) e.preUpdate();

	}

	override function postUpdate() {
		super.postUpdate();

		cursor.postUpdate();

		for(e in ShipPart.ALL) if( !e.destroyed ) e.postUpdate();
		gc();
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		for(e in ShipPart.ALL) if( !e.destroyed ) e.fixedUpdate();
	}

	var currentShipPartIndex = 0;
	function cycleShipPartType() {
		currentShipPartIndex++;
		if (currentShipPartIndex >= parts.length) currentShipPartIndex = 0;
		trace(parts[currentShipPartIndex].getType());
	}

	override function update() {
		super.update();

		// cursor.update();

		for(e in ShipPart.ALL) if( !e.destroyed ) e.update();
	
		if(ca.leftPressed()) {
			select(sxy[0] - 1,sxy[1]);
		}

		if(ca.rightPressed())
			select(sxy[0] + 1,sxy[1]);
		
		if(ca.upPressed())
			select(sxy[0],sxy[1] - 1);

		if(ca.downPressed())
			select(sxy[0],sxy[1] + 1);

		if (ca.bPressed()) {
			ship[sxy[0]][sxy[1]].setType(parts[currentShipPartIndex].getType());
		}

		if (ca.xPressed()) {
			cycleShipPartType();
		}

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

