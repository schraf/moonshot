package sim.en;

import PostGame.PostGameMode;
import sim.components.PowerSupply;
import sim.components.Laser;
import Entity.EntityTypeFlags;
import ShipDefinition.ShipPartDefinition;
import box2D.dynamics.B2FilterData;
import hxd.res.Font;
import hxd.res.DefaultFont;
import h2d.Bitmap;
import box2D.dynamics.B2World;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.joints.B2WeldJointDef;
import hxd.Res;

class Ship extends Entity {
	var ca:dn.heaps.Controller.ControllerAccess;
	var time:Float = 0.;

	public var shipPartSize = 30;
	var shipPartOffsetX = Const.SHIP_WIDTH * 30 * 0.5;
	var shipPartOffsetY = Const.SHIP_HEIGHT * 30 * 0.5;

	var packageLauncherPower = 0.0;
	var packageLauncherPowerModifier = 0.5;

	var shipDefinition: ShipDefinition;
	var visuals: h2d.Object;
	var powerSupply: sim.components.PowerSupply;

	var numPackages = 0;
	var numShields = 0;
	var hullStrength: Float = Const.SHIP_HULL_STRENGTH;
	var mass: Int;
	var forwardBoosters: Array<B2Body> = [];
	var backwardsBoosters: Array<B2Body> = [];
	var leftBoosters: Array<B2Body> = [];
	var rightBoosters: Array<B2Body> = [];
	var forwardLasers: Array<B2Vec2> = [];
	var rearLasers: Array<B2Vec2> = [];
	var leftLasers: Array<B2Vec2> = [];
	var rightLasers: Array<B2Vec2> = [];
	var lasers: Array<Laser>;

	public static var shape: B2PolygonShape;
	public static var filterData: B2FilterData;
	public static var b2world: B2World;

	// x and y in sprite coords
	public function new(shipDefinition: ShipDefinition, b2world, x, y) {
		super(x, y);
		setPosPixel(x, y);

		this.typeFlags |= EntityTypeFlags.SHIP;

		this.shipDefinition = shipDefinition;
		this.lasers = new Array<Laser>();

		visuals = ShipVisuals.createFromDefinition(this.shipDefinition, shipPartSize, shipPartSize, spr);

		Ship.b2world = b2world;
		Ship.filterData = new B2FilterData();
		Ship.filterData.groupIndex = -1;

		Ship.shape = new B2PolygonShape();
		shape.setAsBox(shipPartSize/200, shipPartSize/200);

		var fixtureDef = new B2FixtureDef();
		fixtureDef.density = 1;
		fixtureDef.shape = shape;
		fixtureDef.friction = 0;
		fixtureDef.filter = Ship.filterData;
		fixtureDef.userData = this;

		var bodyDef = new B2BodyDef();
		bodyDef.type = B2BodyType.DYNAMIC_BODY;
		bodyDef.position.set(x/100, y/100); // div by 100 for b2 coords

		this.body = b2world.createBody(bodyDef);
		this.body.createFixture(fixtureDef);

		var powerCapacity: Float = 0.0;
		var powerRechargeRate: Float = 0.0;

		for(shipPart in shipDefinition.parts) {
			powerCapacity += shipPart.part.power_capacity;
			powerRechargeRate += shipPart.part.recharge_rate;

			var offsetX = shipPart.x * shipPartSize - shipPartOffsetX + shipPartSize * 0.5;
			var offsetY = shipPart.y * shipPartSize - shipPartOffsetY + shipPartSize * 0.5;
			var componentShape = new B2PolygonShape();
			componentShape.setAsOrientedBox(shipPartSize / 200, shipPartSize / 200, new B2Vec2(offsetX/100, offsetY/100));

			var componentFixtureDef = new B2FixtureDef();
			componentFixtureDef.density = 1;
			componentFixtureDef.shape = componentShape;
			componentFixtureDef.friction = 0;
			componentFixtureDef.filter = Ship.filterData;
			componentFixtureDef.userData = this;
			this.body.createFixture(componentFixtureDef);

			switch shipPart.part.id {
				case Data.ShipPartKind.Booster:
					addBooster(shipPart);
				case Data.ShipPartKind.Laser:
					addLaser(shipPart);
				case Data.ShipPartKind.Shield:
					addShield(shipPart);
				case Data.ShipPartKind.SolarPanel:
				case Data.ShipPartKind.Battery:
				case Data.ShipPartKind.Package:
					addPackage(shipPart);
				case Data.ShipPartKind.Core:
			}
		}

		this.powerSupply = new sim.components.PowerSupply(powerCapacity, powerRechargeRate);
		ca = Main.ME.controller.createAccess("hero"); // creates an instance of controller
	}

	function createJoint(componentBody) {
		var jointDef = new B2WeldJointDef();
		jointDef.initialize(this.body, componentBody, this.body.getPosition());
		Ship.b2world.createJoint(jointDef);
	}

	function addBooster(shipPart) {
		var fixtureDef = new B2FixtureDef();
		fixtureDef.density = 1;
		fixtureDef.shape = shape;
		fixtureDef.friction = 0;
		fixtureDef.filter = Ship.filterData;
		fixtureDef.userData = this;
		var bodyPosition = this.body.getPosition();
		var offsetX = shipPart.x * shipPartSize - shipPartOffsetX + shipPartSize * 0.5;
		var offsetY = shipPart.y * shipPartSize - shipPartOffsetY + shipPartSize * 0.5;
		var bodyDef = new B2BodyDef();
		bodyDef.type = B2BodyType.DYNAMIC_BODY;
		bodyDef.position.set(bodyPosition.x + offsetX/100, bodyPosition.y + offsetY/100);

		var boosterBody = b2world.createBody(bodyDef);
		boosterBody.createFixture(fixtureDef);
		createJoint(boosterBody);

		switch shipPart.rotation {
			case 0:
				forwardBoosters.push(boosterBody);
			case 90:
				rightBoosters.push(boosterBody);
			case 180:
				backwardsBoosters.push(boosterBody);
			case 270:
				leftBoosters.push(boosterBody);
		}
	}

	function addLaser(shipPart: ShipPartDefinition) {
		var offset = new B2Vec2();
		offset.x += shipPart.x * shipPartSize - shipPartOffsetX;
		offset.y += shipPart.y * shipPartSize - shipPartOffsetY;
		this.lasers.push(new Laser(offset.x, offset.y, spr));

		switch shipPart.rotation {
			case 0:
				forwardLasers.push(offset);
			case 90:
				leftLasers.push(offset);
			case 180:
				rearLasers.push(offset);
			case 270:
				rightLasers.push(offset);
		}
	}

	function addShield(shipPart: ShipPartDefinition) {
		numShields += 1;
	}

	function addPackage(shipPart: ShipPartDefinition) {
		numPackages += 1;
	}

	override function dispose() {
		super.dispose();
		ca.dispose(); // release on destruction
	}

	public static var totalPackageSpeed = 0.0;
	var collisionCount = 0;
	override function onCollision (entity: Entity) {
		if (entity.isA(EntityTypeFlags.PROJECTILE) || entity.isA(EntityTypeFlags.PACKAGE)) {
			return;
		}

		if (cd.has('shipCollision')) {
			return;
		}

		cd.setS('shipCollision', 0.5);

		var damage: Float = 100.0;

		if (numShields >= 1) {
			if (this.powerSupply.consumePower(Data.shipPart.get(Data.ShipPartKind.Shield).power_usage)) {
				damage -= 10.0;
			}
		}

		if (damage > 0) {
			Game.collisionCount += 1;
			Game.ME.trackingCamera.shakeS(1, 2);
			Res.audio.hit.play(false, 0.1);

			this.hullStrength = Math.max(0, this.hullStrength - damage);
			game.hud.hull.setValue(this.hullStrength / Const.SHIP_HULL_STRENGTH);

			if (this.hullStrength <= 0) {
				// POLISH: explosion
				Game.ME.endGame(PostGameMode.DESTROYED);
			}
		}
	}

	override function update() {
		super.update();

		var theta = body.getAngle();
		var p = body.getPosition();
		setPosPixel(p.x * 100, p.y * 100);
		spr.rotation = theta;

		var center = this.body.getPosition();

		if (ca.xPressed() && numPackages > 0) {
			if (packageLauncherPower == 0) {
				packageLauncherPower = 1;
			} else {
				launchPackage();
				packageLauncherPower = 0;
			}
		}

		for (asteroid in Entity.ASTEROIDS) {
			var asteroidPosition = asteroid.getBodyPosition();
			for (laser in this.lasers) {
				if (laser.canFireAt(asteroidPosition)) {
					var power = Data.shipPart.get(Data.ShipPartKind.Laser).power_usage;
					if (this.powerSupply.consumePower(power)) {
						laser.resetCooldown();
						var pos = laser.getWorldPosition();
						var vel = asteroidPosition.sub(new h2d.col.Point(pos.x, pos.y)).normalized().multiply(Const.PROJECTILE_SPEED);
						new Projectile(pos.x, pos.y, vel.x, vel.y);
					}
				}
			}
		}
		game.hud.launcher.setValue(packageLauncherPower / 10);
	}

	function fireBooster(boosterBody: B2Body, theta) {
		if (!this.powerSupply.consumePower(Data.shipPart.get(Data.ShipPartKind.Booster).power_usage)) {
			return;
		}
		var position = boosterBody.getPosition().copy();
		position.multiply(100);
		var thrustAngle = this.body.getAngle() + Math.PI / 2 + theta;
		Game.ME.fx.spray(position.x, position.y, thrustAngle);

		var dir = new B2Vec2(Math.cos(thrustAngle), Math.sin(thrustAngle));
		var forceVec = dir.copy();
		forceVec.multiply(-1 * Const.THRUST_FORCE);

		boosterBody.applyForce(forceVec, boosterBody.getPosition());
		if (!launchPlaying) {
			Res.audio.rocketLaunchShort.play(true, .5);
			launchPlaying = true;
		}
		boosterFired = true;
	}

	var boosterFired = false;
	var launchPlaying = false;
	override function fixedUpdate() {
		super.fixedUpdate();
		this.powerSupply.fixedUpdate();
		game.hud.powerSupply.setValue(this.powerSupply.getCurrentPowerPercentage());

		boosterFired = false;
		if (ca.upDown() || ca.isKeyboardDown(hxd.Key.UP)) {
			for (body in forwardBoosters) {
				fireBooster(body, 0);
			}
		}

		if (ca.downDown() || ca.isKeyboardDown(hxd.Key.DOWN)) {
			for (body in backwardsBoosters) {
				fireBooster(body, Math.PI);
			}
		}

		if (ca.leftDown() || ca.isKeyboardDown(hxd.Key.LEFT)) {
			for (body in leftBoosters) {
				fireBooster(body, Math.PI * 3 / 2);
			}
		}

		if (ca.rightDown() || ca.isKeyboardDown(hxd.Key.RIGHT)) {
			for (body in rightBoosters) {
				fireBooster(body, Math.PI / 2);
			}
		}

		if (!boosterFired && launchPlaying) {
			Res.audio.rocketLaunchShort.stop();
			launchPlaying = false;
		}

		if (packageLauncherPower != 0) {
			packageLauncherPower += packageLauncherPowerModifier;
			if (packageLauncherPower >= 10) {
				packageLauncherPowerModifier = -0.5;
			}
			if (packageLauncherPower <= 1) {
				packageLauncherPowerModifier = 0.5;
			}
		}

		for (base in this.visuals) {
			for (child in base) {
				for (partDefinition in this.shipDefinition.parts) {
					if (child.name == partDefinition.id) {
						if (partDefinition.part.flags.has(Data.ShipPart_flags.rotateAnimation)) {
							child.rotate(Const.SHIP_PART_ROTATE_SPEED * Const.FPS);
						}
					}
				}
			}
		}
	}

	function launchPackage() {
		// numPackages -= 1;
		Game.packagesLaunched += 1;

		var packagePosition = body.getPosition();
		packagePosition.multiply(100);
		var newPackage = new Package(Game.ME.world , cast packagePosition.x, cast packagePosition.y);
		var x = Main.ME.scene.mouseX - Game.ME.scroller.x;
		var y = Main.ME.scene.mouseY - Game.ME.scroller.y;

		var dx = x - packagePosition.x;
		var dy = y - packagePosition.y;

		var vec: B2Vec2 = new B2Vec2(dx, dy);
		vec.normalize();
		vec.multiply(packageLauncherPower);

		packagePosition.multiply(1/100);
		newPackage.body.applyForce(vec, packagePosition);
	}
}