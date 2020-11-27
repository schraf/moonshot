import PostGame.PostGameState;
import Data;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : dn.heaps.Controller;
	public var ca : dn.heaps.Controller.ControllerAccess;
	public var scene : h2d.Scene;
	public var leaderboards: Leaderboards;

	public function new(s:h2d.Scene) {
		super();
		ME = this;
		this.scene = s;
		createRoot(s);

		// Engine settings
		hxd.Timer.wantedFPS = Const.FPS;
		engine.backgroundColor = 0xff<<24|0x000000;
		#if( hl && !debug )
		engine.fullScreen = true;
		#end

		// Resources
		#if(hl && debug)
		hxd.Res.initLocal();
		#else
		hxd.Res.initEmbed();
		#end

		// Hot reloading
		#if debug
		hxd.res.Resource.LIVE_UPDATE = true;
		hxd.Res.data.watch(function() {
			delayer.cancelById("cdb");

			delayer.addS("cdb", function() {
				Data.load( hxd.Res.data.entry.getBytes().toString() );
				if( Game.ME!=null )
					Game.ME.onCdbReload();
			}, 0.2);
		});
		#end

		// Assets & data init
		Assets.init();
		new ui.Console(Assets.fontSmall, s);
		Lang.init("en");
		Data.load(hxd.Res.data.entry.getText());

		// Game controller
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(X, Key.SPACE, Key.F, Key.E);
		controller.bind(A, Key.UP, Key.Z, Key.W);
		controller.bind(B, Key.ENTER, Key.NUMPAD_ENTER);
		controller.bind(SELECT, Key.R);
		controller.bind(START, Key.N);

		controller.bind(AXIS_LEFT_Y_POS, Key.UP, Key.W);
		controller.bind(AXIS_LEFT_Y_NEG, Key.DOWN, Key.S);

		// Post FX
		PostFX.init(s);

		this.leaderboards = new Leaderboards();

		// Start
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.fontMedium);
		delayer.addF( showSplashScreens, 1 );
	}

	public function startGame(gameMode: Data.GameMode, shipDefinition: ShipDefinition) {
		if( Game.ME!=null ) {
			Game.ME.destroy();
			delayer.addF(function() {
				new Game(gameMode, shipDefinition);
			}, 1);
		}
		else
			new Game(gameMode, shipDefinition);
	}

	public function startShipBuilding(gameMode: Data.GameMode) {
		if( ShipBuilding.ME!=null ) {
			ShipBuilding.ME.destroy();
			delayer.addF(function() {
				new ShipBuilding(gameMode);
			}, 1);
		}
		else
			new ShipBuilding(gameMode);
	}

	public function startPostGame(gameMode: Data.GameMode) {
		if(PostGame.ME != null) {
			PostGame.ME.destroy();

			delayer.addF(function() {
				new PostGame(gameMode.Id);
			}, 1);
		}
		else {
			new PostGame(gameMode.Id);
		}
	}

	public function startLeaderboards(gameMode: Data.GameMode) {
		if(PostGame.ME != null) {
			PostGame.ME.destroy();

			delayer.addF(function() {
				new PostGame(gameMode.Id, PostGameState.LOAD_LEADERBOARD);
			}, 1);
		}
		else {
			new PostGame(gameMode.Id, PostGameState.LOAD_LEADERBOARD);
		}
	}

	public function showMenu() {
		if( Menu.ME!=null ) {
			Menu.ME.destroy();
			delayer.addF(function() {
				new Menu();
			}, 1);
		}
		else
			new Menu();
	}

	public function showCredits() {
		if( Credits.ME!=null ) {
			Credits.ME.destroy();
			delayer.addF(function() {
				new Credits();
			}, 1);
		}
		else
			new Credits();
	}

	public function showTutorial() {
		if( Tutorial.ME!=null ) {
			Tutorial.ME.destroy();
			delayer.addF(function() {
				new Tutorial();
			}, 1);
		}
		else
			new Tutorial();
	}

	public function showSplashScreens() {
		new SplashScreens();
	}

	override public function onResize() {
		super.onResize();

		// Auto scaling
		if( Const.AUTO_SCALE_TARGET_WID>0 )
			Const.SCALE = M.ceil( w()/Const.AUTO_SCALE_TARGET_WID );
		else if( Const.AUTO_SCALE_TARGET_HEI>0 )
			Const.SCALE = M.ceil( h()/Const.AUTO_SCALE_TARGET_HEI );

		Const.UI_SCALE = Const.SCALE;
	}

	override function update() {
		Assets.fx.tmod = tmod;
		super.update();
		PostFX.update(tmod);
	}
}
