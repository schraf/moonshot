import h2d.Bitmap;
import h2d.Flow.FlowAlign;
import dn.Process;

class SplashScreens extends Process {
	var flow: h2d.Flow;
	var cinematic = new dn.Cinematic(Const.FPS);
	var ca : dn.heaps.Controller.ControllerAccess;

	public function new() {
		super(Main.ME);
		createRoot(Main.ME.root);

		ca = Main.ME.controller.createAccess("splash_screens");

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
		flow.horizontalAlign = Middle;
		flow.verticalAlign = Middle;

		var background = new Background(root);
		background.addStars(bounds);
		background.addMoon(Const.VIEWPORT_WIDTH * 0.8, Const.VIEWPORT_HEIGHT * 0.1, 0.3);

		cinematic.create({
			#if !skip_splash
			addText("Untitled Game Studio presents");
			fadeIn();
			1500;
			fadeOut();
			1000;
			removeText();
			addLogo();
			addText("Lunar Postal Service");
			fadeIn();
			3000;
			fadeOut();
			1000;
			#end
			destroy();
			Main.ME.showMenu();
		});

		Process.resizeAll();
	}

	override function update() {
		if (ca.xDown()) {
			destroy();
			Main.ME.showMenu();
		}
	}

	function addLogo() {
		var logo = new h2d.Bitmap(Assets.background.getTile('package'), flow);
		logo.setScale(2);
	}

	function addText(str:String, c=0xFFFFFF) {
		var tf = new h2d.Text(Assets.fontLarge, flow);
		tf.text = str;
		tf.textColor = c;
	}

	function removeText() {
		flow.removeChildren();
	}

	function fadeIn() {
		tw.createMs(flow.alpha, 0>1, 500);
	}

	function fadeOut() {
		tw.createMs(flow.alpha, 0, 1000);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}

	override function preUpdate() {
		super.preUpdate();
		cinematic.update(tmod);
	}
}

