import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Flow.FlowAlign;
import dn.Process;

class Tutorial extends Process {
	public static var ME : Tutorial;

	var flow: h2d.Flow;
	var ca : dn.heaps.Controller.ControllerAccess;

	public function new() {
		super(Main.ME);
		createRoot(Main.ME.root);
		ME = this;

		ca = Main.ME.controller.createAccess("tutorial");

		var bounds = new h2d.col.Bounds();
		bounds.set(0.0, 0.0, Const.VIEWPORT_WIDTH, Const.VIEWPORT_HEIGHT);
		var center = bounds.getCenter();
		var camera = Boot.ME.s2d.camera;
		camera.setAnchor(0.5, 0.5);
		camera.setPosition(center.x, center.y);

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.fillWidth = true;
		flow.fillHeight = true;
		flow.horizontalAlign = Left;
		flow.verticalAlign = Middle;

		var background = new Background(root);
		background.addStars(bounds);
		background.addMoon(Const.VIEWPORT_WIDTH * 0.8, Const.VIEWPORT_HEIGHT * 0.1, 0.3);

		var colWidth = Const.VIEWPORT_WIDTH / 2;
		addSection("Welcome to the Lunar Postal Service!", Assets.background.getTile('package'), colWidth);
		addSection("Welcome to the Lunar Postal Service!Welcome to the Lunar Postal Service!Welcome to the Lunar Postal Service!Welcome to the Lunar Postal Service!Welcome to the Lunar Postal Service!Welcome to the Lunar Postal Service!Welcome to the Lunar Postal Service!Welcome to the Lunar Postal Service!Welcome to the Lunar Postal Service!Welcome to the Lunar Postal Service!", Assets.background.getTile('package'), colWidth);

		Process.resizeAll();
	}

	function addSection(text:String, img: Tile, width: Float) {
		flow = new h2d.Flow(flow);
		flow.layout = Horizontal;
		flow.verticalAlign = Middle;
		flow.maxWidth = cast width;
		flow.fillWidth = true;
		flow.paddingHorizontal = 20;
		
		if (img != null) {
			addImage(img, flow);
			flow.addSpacing(10);
		}
		addText(text, flow);
	}

	function addText(str:String, parent: Object) {
		var tf = new h2d.Text(Assets.fontSmall, parent);
		tf.text = str;
		tf.textColor = 0xFFFFFF;
	}

	function addImage(tile: Tile, parent: Object) {
		var img = new h2d.Bitmap(tile, parent);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}

	override function update() {
        if (ca.bPressed()) {
            destroy();
            Main.ME.showMenu();
        }
    }
}

