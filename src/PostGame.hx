import hxd.Key;
import dn.Process;

enum PostGameState {
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
	var loadingText: h2d.Object;

	public function new(gameMode: Data.GameModeKind, postGameMode: PostGameMode) {
		super(Main.ME);
		createRoot(Main.ME.root);
		ME = this;

		
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
				this.state = FINALIZE_SCORE;
				addTitle('GAME OVER');
				addTitle('all packages delivered!', 0x00FF00, true);
			case DESTROYED:
				this.state = LOAD_LEADERBOARD;
				addTitle('GAME OVER');
				addTitle('ship destoryed!', 0xFF0000, true);
			case OUT_OF_TIME:
				this.state = LOAD_LEADERBOARD;
				addTitle('GAME OVER');
				addTitle('out of time!', 0xFF0000, true);
		}

		var background = new Background(root);
		background.addStars(bounds);
		background.addMoon(Const.VIEWPORT_WIDTH * 0.8, Const.VIEWPORT_HEIGHT * 0.1, 0.3);

		flow.addSpacing(100);
		this.loadingText = addText('Loading leaderboards ...');

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

	override function update() {
		switch (this.state) {
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

