import sim.en.Moon;
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
import sim.en.Thruster;
import sim.en.Asteroid;

class ContactListener extends B2ContactListener {
	var shipBody :B2Body;
	
	
	public function new(shipBody) {
		super();
		this.shipBody = shipBody;
	}
	function isOnShip(body) {
		if (body == shipBody) return true;
		return !body.shouldCollide(shipBody);
	}
	override function beginContact(contact:B2Contact):Void {
		var bodyA = contact.getFixtureA().getBody();
		var bodyB = contact.getFixtureB().getBody();
		if (isOnShip(bodyA) || isOnShip(bodyB)) {
			trace(Math.random());
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
	public var camera : Camera;
	public var scroller : h2d.Layers;
	public var level : Level;
	public var hud : ui.Hud;

	var world:B2World;
	var ship: Ship;
	var up:B2Vec2;

	var moon: Moon;
	var asteroid1: Asteroid;
	var asteroid2: Asteroid;

	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);
		scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		camera = new Camera();
		level = new Level();
		fx = new Fx();
		hud = new ui.Hud();

		Process.resizeAll();
		trace(Lang.t._("Game is ready."));

		world = new B2World(new B2Vec2(0, 0), true);
		up = new B2Vec2(0, -50);

		ship = new Ship(world, 0, 0);
		var thruster = new Thruster(world, 50, -80, 5, AXIS_LEFT_X_NEG);
		var thruster2 = new Thruster(world, -50, -80, -5, AXIS_LEFT_X_POS);

		var thruster3 = new Thruster(world, 50, 80, -2, AXIS_LEFT_X_POS);
		var thruster4 = new Thruster(world, -50, 80, 2, AXIS_LEFT_X_NEG);
		
		var jointDef = new B2WeldJointDef();
		jointDef.initialize(ship.body, thruster.body, ship.body.getPosition());
		world.createJoint(jointDef);

		jointDef.initialize(ship.body, thruster2.body, ship.body.getPosition());
		world.createJoint(jointDef);

		jointDef.initialize(ship.body, thruster3.body, ship.body.getPosition());
		world.createJoint(jointDef);

		jointDef.initialize(ship.body, thruster4.body, ship.body.getPosition());
		world.createJoint(jointDef);

		asteroid1 = new Asteroid(world, 2000, 300);
		// new Asteroid(world, 400, -300);
		// new Asteroid(world, -400, -300);
		// new Asteroid(world, -20, -300);
		asteroid2 = new Asteroid(world, 600, 700);
		asteroid2.body.applyForce(new B2Vec2(-3000, 0), asteroid2.body.getPosition());

		moon = new Moon(world, 600, -600);

		// for (i in 1...8) {
		// 	new Thruster(world, Math.round(Math.random() * 1000 - 500), Math.round(-Math.random() * 200) - 300, 3, AXIS_LEFT_Y_NEG);
		// }


		camera.zoom = .5;
		camera.trackTarget(ship, true);

		var cl = new ContactListener(ship.body);
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

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
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

	override function update() {
		super.update();
		for(e in Entity.ALL) if( !e.destroyed ) e.update();

		world.step(1 / 60,  3,  3);
		world.clearForces();

		moon.applyGravity(ship.body);
		moon.applyGravity(asteroid1.body);
		moon.applyGravity(asteroid2.body);

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( ca.isKeyboardPressed(Key.ESCAPE) )
				if( !cd.hasSetS("exitWarn",3) )
					trace(Lang.t._("Press ESCAPE again to exit."));
				else
					hxd.System.exit();
			#end

			// Restart
			if( ca.selectPressed() )
				Main.ME.startGame();
		}
	}
}

