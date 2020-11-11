import hxd.Res;
import dn.Process;
import hxd.Key;

class ShipBuilding extends Process {
	public static var ME : ShipBuilding;

	public var ca : dn.heaps.Controller.ControllerAccess;
    
    var background : h2d.Bitmap;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		createRootInLayers(Main.ME.root, Const.DP_BG);
        
        background = new h2d.Bitmap(root);
        background.tile = Res.platform.toTile();

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
		if( Entity.GC==null || Entity.GC.length==0 )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	override function onDispose() {
        super.onDispose();
        background = null;

		for(e in Entity.ALL)
			e.destroy();
		gc();
	}

	override function preUpdate() {
		super.preUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate();
	}

	override function postUpdate() {
		super.postUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();
		gc();
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.fixedUpdate();
	}

	override function update() {
		super.update();

		for(e in Entity.ALL) if( !e.destroyed ) e.update();

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

