
import box2D.dynamics.B2FilterData;
import hxsl.Ast.Const;
import PostGame.PostGameMode;
import hxd.Res;
import haxe.macro.Type.ClassType;
import box2D.collision.B2Manifold;
import hxsl.Types.Vec;
import dn.Process;
import hxd.Key;

import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.B2ContactListener;
import box2D.dynamics.joints.B2PrismaticJointDef;
import box2D.dynamics.joints.B2WeldJointDef;
import box2D.dynamics.joints.B2WeldJoint;
import box2D.dynamics.B2World;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.B2AABB;
import box2D.collision.shapes.B2Shape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2CircleShape;

import sim.en.Ship;
import sim.en.Asteroid;
import sim.en.Package;
import sim.en.Moon;
import sim.en.House;

class ContactListener extends B2ContactListener {
	override function beginContact(contact:B2Contact):Void {
		var entityA = cast (contact.getFixtureA().getUserData(), Entity);
		var entityB = cast (contact.getFixtureB().getUserData(), Entity);

		if (entityA == null || entityB == null) {
			return;
		}

		entityA.onCollision(entityB);
		entityB.onCollision(entityA);
	}

	override function endContact(contact:B2Contact):Void { }
	override function preSolve(contact:B2Contact, oldManifold):Void {}
	override function postSolve(contact:B2Contact, impulse):Void { }
}

class Game extends Process {
	public static var ME : Game;

	public var ca : dn.heaps.Controller.ControllerAccess;
	public var fx : Fx;
	public var scroller : h2d.Layers;
	public var hud : ui.Hud;
	public var gameMode: Data.GameMode;
	public var world:B2World;
	public var moon: Moon;
	public var trackingCamera: Camera;

	public var ship: Ship;
	var up:B2Vec2;

	var lastAsteriodSpawn: Float = 0.0;

	public function new(gameMode: Data.GameMode, shipDefinition: ShipDefinition) {
		super(Main.ME);
		ME = this;
		this.gameMode = gameMode;

		totalPackageSpeed = 0;
		collisionCount = 0;
		packagesLaunched = 0.0;
		totalFrames = 0;

		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);
		scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		fx = new Fx();
		hud = new ui.Hud();

		var bounds = new h2d.col.Bounds();
		bounds.set(0.0, 0.0, Const.VIEWPORT_WIDTH, Const.VIEWPORT_HEIGHT);

		var center = bounds.getCenter();
		var camera = Boot.ME.s2d.camera;
		camera.setAnchor(0.5, 0.5);
		camera.setPosition(center.x, center.y);
		
		var left = 0;
		var top = 0;
		var bottom = Const.FIELD_HEIGHT;
		var right = Const.FIELD_WIDTH;

		var starBounds = new h2d.col.Bounds();
		starBounds.set(left, top, Const.FIELD_WIDTH, Const.FIELD_HEIGHT);
		starBounds.scaleCenter(1.1);
		var background = new Background();
		background.addStars(starBounds);
		scroller.add(background, Const.DP_BG);

		Process.resizeAll();

		world = new B2World(new B2Vec2(0, 0), true);
		up = new B2Vec2(0, -50);

		ship = new Ship(shipDefinition, world, 300, Const.FIELD_HEIGHT - 300);

		trackingCamera = new Camera();
		trackingCamera.trackTarget(ship, true);

		var moonPosition = new h2d.col.Point(starBounds.width * 0.7, starBounds.height * 0.25);
		moon = new Moon(world, Math.floor(moonPosition.x), Math.floor(moonPosition.y));

		// walls
		var wallShape = new B2PolygonShape();
		var wallFilterData = new B2FilterData();
		wallFilterData.groupIndex = -2;
		var wallFixDef = new B2FixtureDef();
		wallFixDef.shape = wallShape;
		wallFixDef.density = 1;
		wallFixDef.filter = wallFilterData;
		var wallBodyDef = new B2BodyDef();
		wallBodyDef.type = B2BodyType.STATIC_BODY;
		//top
		wallShape.setAsBox(Const.FIELD_WIDTH/100, 1);
		wallBodyDef.position.set(left/100, top/100);
		world.createBody(wallBodyDef).createFixture(wallFixDef);
		//bottom
		wallBodyDef.position.set(left/100, bottom/100);
		world.createBody(wallBodyDef).createFixture(wallFixDef);
		//left
		wallShape.setAsBox(1, Const.FIELD_HEIGHT/100);
		wallBodyDef.position.set(left/100, top/100);
		world.createBody(wallBodyDef).createFixture(wallFixDef);
		//right
		wallBodyDef.position.set(right/100, top/100);
		world.createBody(wallBodyDef).createFixture(wallFixDef);

		// asteroids
		for (i in 0 ... this.gameMode.numAsteroids) {
			var point = new h2d.col.Point(1.0, 0.0);
			var angle = Math.random() * 2.0 * Math.PI;
			var distance = (Math.random() * starBounds.height * 0.75) + sim.en.Moon.Radius;

			point.rotate(angle);
			point.scale(distance);
			point = point.add(moonPosition);

			// clamp to starBounds
			point.x = Math.max(Math.min(point.x, starBounds.width), 0.0);
			point.y = Math.max(Math.min(point.y, starBounds.height), 0.0);

			// move towards moon
			var dir = point.sub(moonPosition);
			dir.normalize();
			dir.scale(Const.ASTEROID_SPEED);

			var asteroid = new Asteroid(world, Math.floor(point.x), Math.floor(point.y));
			asteroid.body.applyImpulse(new B2Vec2(dir.x, dir.y), asteroid.body.getPosition());
		}

		// houses
		var separationAngle = (2.0 * Math.PI) / this.gameMode.numHouses;
		for (i in 0 ... this.gameMode.numHouses) {
			var point = new h2d.col.Point(1.0, 0.0);
			var angle = (i * separationAngle) + ((2.0 * Math.random() - 1.0) * separationAngle * 0.5);
			var distance = sim.en.Moon.Radius;

			point.rotate(angle);
			point.scale(distance);
			point = point.add(moonPosition);

			new House(world, Math.floor(point.x), Math.floor(point.y), angle);
		}

		var cl = new ContactListener();
		world.setContactListener(cl);
	}

	public function onCdbReload() {
	}

	override function onResize() {
		super.onResize();
		// scroller.setScale(Const.SCALE);
	}

	function gc() {
		if( Entity.GC==null || Entity.GC.length==0 )
			return;

		if (!world.isLocked()) {
			for(e in Entity.GC) {
				e.dispose();
			}
			Entity.GC = [];
		}
	}

	override function onDispose() {
		super.onDispose();

		fx.destroy();
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

		totalFrames += 1;
		for(e in Entity.ALL) if( !e.destroyed ) e.fixedUpdate();
	}

	public var totalFrames = 0;
	public var totalPackageSpeed = 0.0;
	public var collisionCount = 0.0;
	public var packagesLaunched = 0.0;
	function calculateScore() {
		// Time component. Divides down score from time per 5 seconds past 15.
		var timeScore = (totalFrames / Const.FPS) / 5;
		var simScore = 25000 / Math.max(1, timeScore - 2);
		simScore += 20000 / (collisionCount + 1);
		simScore += 20000 / (packagesLaunched - Game.ME.gameMode.numHouses + 1);
		simScore += 10000 / Math.max(1, totalPackageSpeed - 10);
		Main.ME.leaderboards.addToScore(Math.floor(simScore));
	}

	public function endGame (postGameMode: PostGameMode) {
		delayer.addF(function() {
			calculateScore();
			destroy();
			Res.audio.space_music.stop();
			Main.ME.playMusic();
		}, 1);

		Main.ME.startPostGame(this.gameMode, postGameMode);
	}

	override function update() {
		super.update();

		if (Entity.HOUSES.length == 0) {
			endGame(PostGameMode.WIN);
		}

		//asteroid belt
		var time = framesToSec(ftime);
		if (time - lastAsteriodSpawn > 2) {
			var asteroid = new Asteroid(world, Math.floor(Const.FIELD_WIDTH), Const.ASTEROID_BELT_Y);
			var vx = -Const.ASTEROID_BELT_SPEED - Math.random();
			var vy = (Math.random() - Math.random()) * 0.5;
			asteroid.body.applyImpulse(new B2Vec2(vx, vy), asteroid.body.getPosition());
			lastAsteriodSpawn = time - Math.random() * 0.25;
		}
		

		if (!ui.Console.ME.hasFlag('nogravity')) {
			for(e in Entity.ALL) if( !e.destroyed ) {
				e.update();
				if (e.body != null && !e.ignoreGravity) {
					moon.applyGravity(e.body);
				}
			}
		}

		world.step(1 / 60,  3,  3);
		world.clearForces();

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( ca.isKeyboardPressed(Key.ESCAPE) )
				if( !cd.hasSetS("exitWarn",3) )
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					hxd.System.exit();
			#end
		}
	}
}

