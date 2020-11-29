import h2d.Text;
import hxd.Event.EventKind;
import hxd.Key;
import hxd.Window;
import dn.Process;

enum PostGameState {
	ENTER_NAME;
	FINALIZE_SCORE;
	LOAD_LEADERBOARD;
	WAIT;
	READY;
}

enum PostGameMode {
	WIN;
	DESTROYED;
	OUT_OF_TIME;
	LEADERBOARD;
}

class PostGame extends Process {
	public static var ME : PostGame;

	var flow: h2d.Flow;
	var ca : dn.heaps.Controller.ControllerAccess;
	var state: PostGameState;
	var gameMode: Data.GameModeKind;
	var loadingText: Text;
	var inputText: h2d.Text;
	var inputInstructions: h2d.Text;

	public function new(gameMode: Data.GameModeKind, postGameMode: PostGameMode) {
		super(Main.ME);
		createRoot(Main.ME.root);
		ME = this;

		hxd.Window.getInstance().addEventTarget(textInput);
		
		this.gameMode = gameMode;
		this.ca = Main.ME.controller.createAccess("postgame");
		
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
		
		switch postGameMode {
			case LEADERBOARD:
				this.state = LOAD_LEADERBOARD;
				addTitle('LEADERBOARDS');
			case WIN:
				this.state = ENTER_NAME;
				addTitle('GAME OVER');
				addTitle('all packages delivered!', 0x00FF00, true);
				flow.addSpacing(100);
				inputInstructions = addTitle('Press enter when complete:');
				inputArray = generateName();
				inputText = addTitle(inputArray.join(''), 0xD04B38, true);
			case DESTROYED:
				this.state = LOAD_LEADERBOARD;
				addTitle('GAME OVER');
				addTitle('ship destroyed!', 0xFF0000, true);
			case OUT_OF_TIME:
				this.state = LOAD_LEADERBOARD;
				addTitle('GAME OVER');
				addTitle('out of time!', 0xFF0000, true);
		}

		var background = new Background(root);
		background.addStars(bounds);
		background.addMoon(Const.VIEWPORT_WIDTH * 0.8, Const.VIEWPORT_HEIGHT * 0.1, 0.3);

		flow.addSpacing(100);
		this.loadingText = addText('');

		Process.resizeAll();
	}

	function addTitle(text:String, c: Int = 0xFFFFFF, small: Bool = false): h2d.Text {
		var tf = new h2d.Text(small ? Assets.fontMedium : Assets.fontLarge, flow);
		tf.text = text;
		tf.textColor = c;
		return tf;
	}

	function addText(text:String, ?color: Null<Int>): h2d.Text {
		var tf = new h2d.Text(Assets.fontSmall, this.flow);
		tf.text = text;
		tf.textColor = color != null ? color : 0xFFFFFF;
		return tf;
	}

	function addRanking(ranking: Leaderboards.LeaderboardRanking) {
		var color = 0xFFFFFF;

		if (ranking.name == Main.ME.leaderboards.getName()) {
			color = 0xD04B38;
		}

		addText('${StringTools.lpad(Std.string(ranking.score), '0', 5)} ${ranking.name}', color);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}

	var inputIndex = 0;
	var inputArray = [];
	function textInput(event : hxd.Event) {
		if (this.state == PostGameState.ENTER_NAME && event.kind.equals(EventKind.ETextInput)) {
			inputArray[inputIndex++] = String.fromCharCode(event.charCode);
			inputIndex %= inputArray.length;
			inputText.text = inputArray.join('');
		}
	}

	function generateName() {
		var name = [];
		while (name.length < 5) {
			name.push(String.fromCharCode(Math.floor(Math.random() * 26) + 65));
		}
		return name;
	}

	override function update() {
		switch (this.state) {
			case PostGameState.ENTER_NAME: {
				delayer.addS(function () {
					if (ca.bPressed()) {
						Main.ME.leaderboards.setName(inputArray.join(''));
						this.loadingText.text = "Loading leaderboards ...";
						this.inputText.remove();
						this.inputInstructions.remove();
						this.state = PostGameState.FINALIZE_SCORE;
					}
				}, 1);
			}
			case PostGameState.FINALIZE_SCORE: {
				this.state = PostGameState.WAIT;
				delayer.addS(function () {
					Main.ME.leaderboards.finalizeScore(this.gameMode);
					this.state = PostGameState.LOAD_LEADERBOARD;
				}, 1);
			}

			case PostGameState.LOAD_LEADERBOARD: {
				var leaderboard = Main.ME.leaderboards.getLeaderboard(this.gameMode);

				if (leaderboard == null) {
					Main.ME.leaderboards.loadLeaderboard(this.gameMode);
					leaderboard = Main.ME.leaderboards.getLeaderboard(this.gameMode);
				}

				if (!leaderboard.isLoading) {
					this.loadingText.remove();

					for (ranking in leaderboard.rankings) {
						addRanking(ranking);
					}

					this.flow.addSpacing(100);

					this.state = PostGameState.WAIT;
					delayer.addS(function () {
						this.state = PostGameState.READY;
						addText('Press Any Key');
					}, 3);
				}
			}

			case PostGameState.WAIT: {
			}

			case PostGameState.READY: {
				if (ca.aPressed() || ca.bPressed() || ca.xPressed() || ca.yPressed() || ca.isKeyboardPressed(Key.ESCAPE)|| ca.isKeyboardPressed(Key.MOUSE_LEFT)) {
					destroy();
					Main.ME.showMenu();
				}
			}
		}
	}
}

