
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
	function isOnType<T>(fixture: B2Fixture, classCheck: Class<T>) {
		return fixture.getUserData() != null && Type.getClass(fixture.getUserData()) == classCheck;
	}

	override function beginContact(contact:B2Contact):Void {
		var fixtureA = contact.getFixtureA();
		var fixtureB = contact.getFixtureB();
		if (isOnType(fixtureA, sim.en.Ship) || isOnType(fixtureB, sim.en.Ship)) {
			Game.ME.ship.onCollision();
		}
		if (isOnType(fixtureA, sim.en.Package) && isOnType(fixtureB, sim.en.House)) {
			(fixtureA.getUserData() : Package).destroy();
			(fixtureB.getUserData() : House).destroy();
			Main.ME.leaderboards.addToScore(500);
		}
		if (isOnType(fixtureA, sim.en.House) && isOnType(fixtureB, sim.en.Package)) {
			(fixtureA.getUserData() : House).destroy();
			(fixtureB.getUserData() : Package).destroy();
			Main.ME.leaderboards.addToScore(500);
		}
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

	public var ship: Ship;
	var up:B2Vec2;

	public function new(gameMode: Data.GameMode, shipDefinition: ShipDefinition) {
		super(Main.ME);
		ME = this;
		this.gameMode = gameMode;

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

		var background = new Background();
		background.addStars(bounds);
		scroller.add(background, Const.DP_BG);

		Process.resizeAll();

		world = new B2World(new B2Vec2(0, 0), true);
		up = new B2Vec2(0, -50);

		ship = new Ship(shipDefinition, world, Const.VIEWPORT_HEIGHT - 300, 300);

		var moonPosition = new h2d.col.Point(bounds.width * 0.7, bounds.height * 0.25);
		moon = new Moon(world, Math.floor(moonPosition.x), Math.floor(moonPosition.y));

		for (i in 0 ... this.gameMode.numAsteroids) {
			var point = new h2d.col.Point(1.0, 0.0);
			var angle = Math.random() * 2.0 * Math.PI;
			var distance = (Math.random() * bounds.height * 0.75) + sim.en.Moon.Radius;

			point.rotate(angle);
			point.scale(distance);
			point = point.add(moonPosition);

			// clamp to bounds
			point.x = Math.max(Math.min(point.x, bounds.width), 0.0);
			point.y = Math.max(Math.min(point.y, bounds.height), 0.0);

			// move towards moon
			var dir = point.sub(moonPosition);
			dir.normalize();
			dir.scale(1000.0);

			var asteroid = new Asteroid(world, Math.floor(point.x), Math.floor(point.y));
			asteroid.body.applyForce(new B2Vec2(dir.x, dir.y), asteroid.body.getPosition());
		}

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

		for(e in Entity.ALL) if( !e.destroyed ) e.fixedUpdate();
	}

	public function endGame () {
		delayer.addF(function() {
			destroy();
		}, 1);

		Main.ME.startPostGame(this.gameMode);
	}

	override function update() {
		super.update();

		if (!ui.Console.ME.hasFlag('nogravity')) {
			for(e in Entity.ALL) if( !e.destroyed ) {
				e.update();
				if (e.body != null && !e.ignoreGravity) {
					moon.applyGravity(e.body);
				}
			}
		}

		if (Entity.HOUSES.length == 0) {
			endGame();
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

