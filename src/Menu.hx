import hxd.Res;
import h2d.Interactive;
import h2d.Text;
import h2d.Flow.FlowAlign;
import dn.Process;

class Menu extends Process {
	public static var ME : Menu;

	var flow: h2d.Flow;
	var ca : dn.heaps.Controller.ControllerAccess;

	var NEW_GAME: Int = 1;
	var HOW_TO_PLAY: Int = 2;
	var LEADERBOARD: Int = 3;
	var CREDITS: Int = 4;

	var options: Array<Int>;

	var selectedOption: Int;

	public function new() {
		#if skip_menu
		destroy();
		// Main.ME.startShipBuilding(Data.gameMode.get(Data.GameModeKind.ClassA));
		Main.ME.showSelectDifficulty();
		return;
		#end

		super(Main.ME);
		ME = this;
		createRoot(Main.ME.root);

		ca = Main.ME.controller.createAccess("menu");

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

		addText("MAIN MENU");
		flow.addSpacing(50);
		addButton("New Game", 0);
		addButton("How To Play", 1);
		addButton("Leaderboards", 2);
		addButton("Credits", 3);

		options = [NEW_GAME, HOW_TO_PLAY, LEADERBOARD, CREDITS];
		selectedOption = 0;
		select(0, false);

		Process.resizeAll();
	}

	function addText(str:String, c=0xFFFFFF) {
		var tf = new h2d.Text(Assets.fontLarge, flow);
		tf.text = str;
		tf.textColor = c;
		return tf;
	}

	function addButton(str:String, option: Int) {
		var tf = addText(str);
		var interactive = new Interactive(tf.calcTextWidth(str), tf.textHeight, tf);
		interactive.enableRightButton = true;

		interactive.onPush = function (event: hxd.Event) {
			if (event.button == 0) {
				selectedOption = option;
				buttonPressed();
			}
		}

		interactive.onOver = function (event: hxd.Event) {
			select(option);
		}
	}

	function select(optionToSelect: Int, play: Bool = true) {
		if(play) {
			Res.audio.select.play(false, 0.1);
		}

		if (optionToSelect >= options.length) {
			optionToSelect = 0;
		} else if (optionToSelect < 0) {
			optionToSelect = options.length - 1;
		}

		flow.getChildAt(options[selectedOption]).alpha = 1;
		flow.getChildAt(options[optionToSelect]).alpha = 0.5;
		selectedOption = optionToSelect;
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}

	override function onDispose() {
		super.onDispose();
		options = null;
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
		if (ca.upPressed()) {
			select(selectedOption - 1);
		}
		else if (ca.downPressed()) {
			select(selectedOption + 1);
		} else if (ca.bPressed()) {
			buttonPressed();
		}
	}

	function buttonPressed() {
		if (options[selectedOption] == CREDITS) {
			destroy();
			Main.ME.showCredits();
		}
		else if (options[selectedOption] == NEW_GAME) {
			destroy();
			Main.ME.showSelectDifficulty();
		}
		else if (options[selectedOption] == HOW_TO_PLAY) {
			destroy();
			Main.ME.showTutorial();
		}
		else if (options[selectedOption] == LEADERBOARD) {
			destroy();
			Main.ME.showSelectDifficulty(true);
		}
	}
}

