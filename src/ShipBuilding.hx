import ui.Button;
import h2d.Bitmap;
import format.gif.Data.Block;
import h3d.Vector;
import h2d.Text;
import ui.Modal;
import ship_building.*;
import dn.Process;

class ShipBuilding extends Process {
	public static var ME : ShipBuilding;

	public var layout: ShipLayout;
	public var panel: ShipPartPanel;
	public var gameMode: Data.GameMode;
	public var warningMessage: Text;

	private var launching: Bool = false;

	var moonBackground: Background;
	var moon: Bitmap;
	var startingMoonScale: Float = .05;
	var background: Background;
	var stats: ShipStats;
	var storageCount: Int = 0;
	var shipDefinition: ShipDefinition;
	var launchButton: Button;

	public function new(gameMode: Data.GameMode) {
		super(Main.ME);
		ME = this;
		this.gameMode = gameMode;

		createRootInLayers(Main.ME.root, Const.DP_BG);

		var bounds = new h2d.col.Bounds();
		bounds.set(0.0, 0.0, Const.VIEWPORT_WIDTH, Const.VIEWPORT_HEIGHT);
		var center = bounds.getCenter();
		var camera = Boot.ME.s2d.camera;
		camera.setAnchor(0.5, 0.5);
		camera.setPosition(center.x, center.y);

		background = new Background(root);
		background.addStars(bounds);
		background.addMoon(Const.VIEWPORT_WIDTH * 0.1, Const.VIEWPORT_HEIGHT * 0.1, 0.3);
		background.addGround();

		layout = new ShipLayout(90, root);
		layout.x = 420;
		layout.y = 75;

		launchButton = new ui.Button("LAUNCH", 400, 200, root);
		launchButton.x = 30;
		launchButton.y = 800;

		warningMessage = new Text(Assets.fontSmall, root);
		warningMessage.x = 30;
		warningMessage.y = 750;
		warningMessage.color = new Vector(1,0,0);

		launchButton.onPush = function (event: hxd.Event) {
			storageCount = 0;
			shipDefinition = layout.toShipDefinition();
			for (shipPart in shipDefinition.parts) {
				if (shipPart.part.id == Data.ShipPartKind.Package) {
					storageCount++;
				}
			}
			if (this.gameMode.numHouses > storageCount) {
				warningMessage.text = "Need " + (this.gameMode.numHouses - storageCount) + " more storage units";
				return;
			}

			for (cell in layout.cells) cell.alpha = 0.0;
			moonBackground = new Background(root);
			moonBackground.addStars(bounds);
			moon = moonBackground.addMoon(0,0,startingMoonScale);
			Assets.rocketLaunch.play(true);
			launching = true;
		};
		
		initPanel();

		stats = new ShipStats();

		Process.resizeAll();
		layout.addCore();
		Main.ME.leaderboards.resetScore();
	}

	private function warn(text: String) {
		warningMessage.text = text;
		delayer.cancelById('warningMessage');
		delayer.addS('warningMessage', function() {
			warningMessage.text = '';
		}, 5);
	}

	private function initPanel () {
		panel = new ShipPartPanel(root);
		panel.overflow = h2d.Flow.FlowOverflow.Limit;
		panel.multiline = true;
		panel.maxWidth = Const.SHIP_PANEL_WIDTH;
		panel.x = Const.VIEWPORT_WIDTH - Const.SHIP_PANEL_WIDTH - 100;
		panel.y = 100;

		var partSize = Math.floor(Const.SHIP_PANEL_WIDTH * 0.25);

		for (part in Data.shipPart.all) {
			if (part.flags.has(Data.ShipPart_flags.showInPanel)) {
				panel.addPart(part, partSize, partSize);
			}
		}
	}

	public function checkBuildPart(part: Data.ShipPart) {
		if (stats == null || layout == null || part == null) {
			return true;
		}
		if (part.cost + stats.cost > gameMode.maxCost) {
			warn("Cost cannot exceed " + gameMode.maxCost);
			return false;
		}
		if (part.id == Data.ShipPartKind.Package) {
			storageCount = 1;
			for (shipPart in layout.toShipDefinition().parts) {
				if (shipPart.part.id == Data.ShipPartKind.Package) {
					storageCount++;
				}
			}
			if (storageCount > gameMode.numHouses) {
				warningMessage.text = "You only need " + gameMode.numHouses + " storage units.";
				return false;
			}
		}
		return true;
	}

	public function onBuildPart() {
		if (stats == null || layout == null) {
			return;
		}

		stats.clear();

		for (cell in layout.cells) {
			var part = cell.getPart();

			if (part != null) {
				stats.mass += part.mass;
				stats.cost += part.cost;
				stats.fuel += Math.round(part.power_capacity);
			}
		}

		stats.refresh();
	}


// import h3d.Engine;
// import h2d.Tile;
// import h2d.TileGroup;
// import h3d.mat.*;
// import h3d.scene.*;

// class MoonScene {
//   static var PW = 200;
//   static var PH = 200;
//   var scene: Scene;
//   public var root: Object;
//   var renderTarget : Texture;

//   public function new() {
//     scene = new Scene();
//     root = new Object(scene);
//     var prim = new h3d.prim.Sphere(1, 128, 128);
//     prim.translate( 0, 0, 0);
//     prim.addNormals();
//     prim.addUVs();
//     var tex = hxd.Res.img.moon_nasa.toTexture();
//     var obj = new Mesh(prim, h3d.mat.Material.create(tex), root);
//     obj.material.shadows = false;
//     var light = new h3d.scene.fwd.DirLight(new h3d.Vector(0, 1, 0), scene);
//     scene.lightSystem.ambientLight.set(0.3, 0.3, 0.3);
//     // scene.camera.pos.set(x, y, 0);

//     renderTarget = new Texture(PW, PH, [ Target ]);
//     renderTarget.depthBuffer = new DepthBuffer(PW, PH);

//   }

//   public function getTexture(x, y) {
//     scene.camera.pos.set(x, y, 0);
//     var engine = Game.ME.engine;
//     engine.pushTarget(renderTarget);
//     engine.clear(0, 1); // Clears the render target texture and depth buffer
//     scene.render(engine);
//     engine.popTarget();

//     return renderTarget;
//   }

	var alpha = 1.0;
	var moonAlpha = 0.0;
	var currentScale: Float = .05;
	var moonScale: Float = 1;
	override function fixedUpdate() {
		super.fixedUpdate();
		layout.update();

		if (launching) {
			alpha -= 1 / Const.SHIPBUILDING_FADEOUT_SECONDS / 30 * 2;
			warningMessage.alpha = launchButton.alpha = background.alpha = panel.alpha = stats.panel.alpha = alpha;

			moonAlpha = Math.min(1,(1 - alpha) * 2);
			moonBackground.alpha = moonAlpha;
			
			moonScale += .04 / Const.SHIPBUILDING_FADEOUT_SECONDS / Const.FPS;
			currentScale *= moonScale;
			moon.scale(moonScale);
			moon.x = Const.VIEWPORT_WIDTH * .95 - (685 * currentScale / 2);
			moon.y = Const.VIEWPORT_HEIGHT * .5 - (664 * currentScale / 2);

			moon.rotate(.006);

			if (alpha <= -1) {
				finish();
			}
		}
	}

	function finish() {
		Assets.rocketLaunch.stop();
		destroy();
		Main.ME.startGame(this.gameMode, shipDefinition);
	}
}
