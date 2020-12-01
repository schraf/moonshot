import hxd.Key;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
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
		flow.maxHeight = Const.VIEWPORT_HEIGHT;
		flow.multiline = true;
		flow.horizontalAlign = Middle;
		flow.verticalAlign = Middle;
		flow.paddingLeft = 40;

		var background = new Background(root);
		background.addStars(bounds);
		background.addMoon(Const.VIEWPORT_WIDTH * 0.8, Const.VIEWPORT_HEIGHT * 0.1, 0.3);

		addSection("Welcome to the Lunar Postal Service!", Assets.background.getTile('package'), Const.VIEWPORT_WIDTH, 0.75);
		addSection("Your mission is to deliver packages to houses on the moon for as cheap as possible.", Assets.background.getTile('house'), Const.VIEWPORT_WIDTH, 0.75);
		flow.addSpacing(20);
		addSection("First you must build a ship, click to place pieces, mouse wheel to rotate.", null, Const.VIEWPORT_WIDTH, 0.5);
		flow.addSpacing(20);
		addSection("W A S D to move, if you have the thrusters for it.", Assets.ship.getTile('thruster'), Const.VIEWPORT_WIDTH, 0.35);
		addSection("Space to charge up the package cannon, space again to shoot at the mouse pointer.", Assets.ship.getTile('storage'), Const.VIEWPORT_WIDTH, 0.35);
		addSection("Lasers will destory asteroids if you have enough power.", Assets.ship.getTile('laser'), Const.VIEWPORT_WIDTH, 0.35);
		addSection("Firing weapons takes energy, use batteries to store as much as you can.", Assets.ship.getTile('battery'), Const.VIEWPORT_WIDTH, 0.35);
		addSection("Use solar panels to charge up your batteries faster.", Assets.ship.getTile('solar'), Const.VIEWPORT_WIDTH, 0.35);
		addSection("Shields deplete energy, but protect from collisions.", Assets.ship.getTile('shield'), Const.VIEWPORT_WIDTH, 0.35);
		flow.addSpacing(20);
		addSection("Once all packages are delivered, your mission is complete! Good luck!", null, Const.VIEWPORT_WIDTH, 1, h2d.Flow.FlowAlign.Middle);
		addSection("Final score is calculated from the following:", null, Const.VIEWPORT_WIDTH, 1, 0x1CE019, h2d.Flow.FlowAlign.Middle);
		addSection("Leftover budget [25%], Speed [25%], Damage taken [25%], Gently delivering packages [25%].", null, Const.VIEWPORT_WIDTH, 1, 0x1CE019, h2d.Flow.FlowAlign.Middle);

		Process.resizeAll();
	}

	function addSection(text:String, img: Tile, width: Float, imgScale: Float, color = 0xFFFFFF, align = h2d.Flow.FlowAlign.Left) {
		var localFlow = new h2d.Flow(flow);
		localFlow.layout = Horizontal;
		localFlow.verticalAlign = Middle;
		localFlow.horizontalAlign = align;
		localFlow.maxWidth = cast width;
		localFlow.fillWidth = true;
		localFlow.paddingHorizontal = 20;
		
		if (img != null) {
			addImage(img, localFlow, imgScale);
			localFlow.addSpacing(10);
		}
		addText(text, localFlow, color);
	}

	function addText(str:String, parent: Object, color: Int) {
		var tf = new h2d.Text(Assets.fontSmall, parent);
		tf.text = str;
		tf.textColor = color;
	}

	function addImage(tile: Tile, parent: Object, imgScale: Float) {
		var img = new h2d.Bitmap(tile, parent);
		img.setScale(imgScale);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}

	override function update() {
        if (ca.aPressed() || ca.bPressed() || ca.xPressed() || ca.yPressed() || ca.isKeyboardPressed(Key.ESCAPE)|| ca.isKeyboardPressed(Key.MOUSE_LEFT)) {
            destroy();
            Main.ME.showMenu();
        }
    }
}

