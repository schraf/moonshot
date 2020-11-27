import hxd.Key;
import h2d.Text;
import h2d.Flow.FlowAlign;
import dn.Process;

class Credits extends Process {
    public static var ME : Credits;

    var flow: h2d.Flow;
    var ca : dn.heaps.Controller.ControllerAccess;

	public function new() {
        super(Main.ME);
        createRoot(Main.ME.root);
        ME = this;

        ca = Main.ME.controller.createAccess("credits");

        var bounds = new h2d.col.Bounds();
		bounds.set(0.0, 0.0, Const.VIEWPORT_WIDTH, Const.VIEWPORT_HEIGHT);
		var center = bounds.getCenter();
		var camera = Boot.ME.s2d.camera;
		camera.setAnchor(0.5, 0.5);
		camera.setPosition(center.x, center.y);

		var background = new Background(root);
		background.addStars(bounds);
		background.addMoon(Const.VIEWPORT_WIDTH * 0.8, Const.VIEWPORT_HEIGHT * 0.1, 0.3);

        flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.fillWidth = true;
		flow.fillHeight = true;
		flow.horizontalAlign = Middle;
		flow.verticalAlign = Middle;

        addText("CREDITS");
        flow.addSpacing(50);
        addText("Developed by");
        addText("Edric Yu");
        addText("James White");
        addText("Marc Scraffenberger");
        addText("Luke Brom");
        flow.addSpacing(50);
        addText("(press enter button to go back)");

		Process.resizeAll();
	}

	function addText(str:String, c=0xFFFFFF) {
		var tf = new h2d.Text(Assets.fontLarge, flow);
		tf.text = str;
		tf.textColor = c;
    }

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
    }

    override function onDispose() {
        super.onDispose();
        ca.dispose();
	}

	function gc() {
		if( Entity.GC==null || Entity.GC.length==0 )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
    }

    override function update() {
        if (ca.aPressed() || ca.bPressed() || ca.xPressed() || ca.yPressed() || ca.isKeyboardPressed(Key.ESCAPE)) {
            destroy();
            Main.ME.showMenu();
        }
    }
}

