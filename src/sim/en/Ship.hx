package sim.en;

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

class Ship extends Entity {
	var ca:dn.heaps.Controller.ControllerAccess;
	var time:Float = 0.;

	var shipPartSize = 30;
	var shipPartOffsetX = Const.SHIP_WIDTH * 30 * 0.5;
	var shipPartOffsetY = Const.SHIP_HEIGHT * 30 * 0.5;

	var packageLauncherPower = 0.0;
	var packageLauncherPowerModifier = 0.1;

	var shipDefinition: ShipDefinition;
	var visuals: h2d.Object;
	var powerSupply: sim.components.PowerSupply;

	var numPackages = 0;
	var numShields = 0;
	var hullStrength: Float = Const.SHIP_HULL_STRENGTH;
	var mass: Int;
	var forwardBoosters: Array<B2Vec2> = [];
	var backwardsBoosters: Array<B2Vec2> = [];
	var leftBoosters: Array<B2Vec2> = [];
	var rightBoosters: Array<B2Vec2> = [];
	var forwardLasers: Array<B2Vec2> = [];
	var rearLasers: Array<B2Vec2> = [];
	var leftLasers: Array<B2Vec2> = [];
	var rightLasers: Array<B2Vec2> = [];
	var lasers: Array<Laser>;

	// x and y in sprite coords
	public function new(shipDefinition: ShipDefinition, b2world, x, y) {
		super(x, y);

		this.typeFlags |= EntityTypeFlags.SHIP;

		this.shipDefinition = shipDefinition;
		this.lasers = new Array<Laser>();

		visuals = ShipVisuals.createFromDefinition(this.shipDefinition, shipPartSize, shipPartSize, spr);

		var shape = new B2PolygonShape();

		var filterData = new B2FilterData();
		filterData.groupIndex = -1;

		var fixtureDef = new B2FixtureDef();
		fixtureDef.density = 1;
		fixtureDef.shape = shape;
		fixtureDef.friction = 0;
		fixtureDef.filter = filterData;
		fixtureDef.userData = this;

		var bodyDef = new B2BodyDef();
		bodyDef.type = B2BodyType.DYNAMIC_BODY;

		// trace(Xoffset);
		// trace(Yoffset);

		bodyDef.position.set(x/100, y/100); // div by 100 for b2 coords

		this.body = b2world.createBody(bodyDef);
		this.mass = 0;

		var powerCapacity: Float = 0.0;
		var powerRechargeRate: Float = 0.0;

		for(shipPart in shipDefinition.parts) {
			powerCapacity += shipPart.part.power_capacity;
			powerRechargeRate += shipPart.part.recharge_rate;
			this.mass += shipPart.part.mass;

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

			shape.setAsOrientedBox(shipPartSize / 200, shipPartSize / 200, new B2Vec2((shipPart.x * shipPartSize - shipPartOffsetX + (shipPartSize / 2)) / 100, (shipPart.y * shipPartSize - shipPartOffsetY + (shipPartSize / 2)) / 100));
			this.body.createFixture(fixtureDef);
		}

		this.powerSupply = new sim.components.PowerSupply(powerCapacity, powerRechargeRate);
		ca = Main.ME.controller.createAccess("hero"); // creates an instance of controller
	}

	function addBooster(shipPart: ShipPartDefinition) {
		var origin = new B2Vec2();
		origin.x += shipPart.x * shipPartSize - shipPartOffsetX;
		origin.y += shipPart.y * shipPartSize - shipPartOffsetY;

		switch shipPart.rotation {
			case 0:
				forwardBoosters.push(origin);
			case 90:
				rightBoosters.push(origin);
			case 180:
				backwardsBoosters.push(origin);
			case 270:
				leftBoosters.push(origin);
		}
	}

	function addLaser(shipPart: ShipPartDefinition) {
		var origin = new B2Vec2();
		origin.x += shipPart.x * shipPartSize - shipPartOffsetX;
		origin.y += shipPart.y * shipPartSize - shipPartOffsetY;

		this.lasers.push(new Laser(origin.x, origin.y, spr));

		switch shipPart.rotation {
			case 0:
				forwardLasers.push(origin);
			case 90:
				leftLasers.push(origin);
			case 180:
				rearLasers.push(origin);
			case 270:
				rightLasers.push(origin);
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
			this.hullStrength = Math.max(0, this.hullStrength - damage);
			game.hud.hull.setValue(this.hullStrength / Const.SHIP_HULL_STRENGTH);
			Main.ME.leaderboards.removeFromScore(1);

			if (this.hullStrength <= 0) {
				// POLISH: explosion
				Game.ME.endGame();
			}
		}
	}

	function calculateForce (boosters: Int): Float {
		if (boosters == 0) {
			return 0.0;
		}

		var powerUsage: Float = boosters * Data.shipPart.get(Data.ShipPartKind.Booster).power_usage;
		var force: Float = 0.0;

		if (this.powerSupply.consumePower(powerUsage)) {
			force = Math.max(0.5, boosters - (this.mass / 500.0));
		}

		return force;
	}

	override function update() {
		super.update();

		this.powerSupply.update();
		game.hud.powerSupply.setValue(this.powerSupply.getCurrentPowerPercentage());

		var theta = body.getAngle();
		var p = body.getPosition();
		setPosPixel(p.x * 100, p.y * 100);
		spr.rotation = theta;

		var center = this.body.getPosition();
		if (ca.upDown() || ca.isKeyboardDown(hxd.Key.UP)) {
			var force = this.calculateForce(forwardBoosters.length);

			if (force > 0.0) {
				var forceVec = this.body.getWorldVector(new B2Vec2(0, force *-1));
				this.body.applyForce(forceVec, center);
				fireBoosterParticles(forwardBoosters, theta);
			}
		}

		if (ca.downDown() || ca.isKeyboardDown(hxd.Key.DOWN)) {
			var force = this.calculateForce(backwardsBoosters.length);

			if (force > 0.0) {
				var forceVec = this.body.getWorldVector(new B2Vec2(0, force));
				this.body.applyForce(forceVec, center);
				fireBoosterParticles(backwardsBoosters, theta + Math.PI);
			}
		}

		if (ca.leftDown() || ca.isKeyboardDown(hxd.Key.LEFT)) {
			var force = this.calculateForce(leftBoosters.length);

			if (force > 0.0) {
				var forceVec = this.body.getWorldVector(new B2Vec2(force *-1, 0));
				this.body.applyForce(forceVec, center);
				fireBoosterParticles(leftBoosters, theta + Math.PI + Math.PI/2);
			}
		}

		if (ca.rightDown() || ca.isKeyboardDown(hxd.Key.RIGHT)) {
			var force = this.calculateForce(rightBoosters.length);

			if (force > 0.0) {
				var forceVec = this.body.getWorldVector(new B2Vec2(force, 0));
				this.body.applyForce(forceVec, center);
				fireBoosterParticles(rightBoosters, theta + Math.PI/2);
			}
		}


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
						var pos = laser.localToGlobal();
						var vel = asteroidPosition.sub(pos).normalized().multiply(Const.PROJECTILE_SPEED);
						new Projectile(pos.x, pos.y, vel.x, vel.y);
					}
				}
			}
		}
	}

	function fireBoosterParticles(origins: Array<B2Vec2>, theta: Float) {
		var position = this.body.getPosition().copy();
		position.multiply(100);
		for (origin in origins) {
			Game.ME.fx.spray(position.x + origin.x,position.y + origin.y, theta + Math.PI/2);
		}
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		if (packageLauncherPower != 0) {
			packageLauncherPower += packageLauncherPowerModifier;
			if (packageLauncherPower >= 10) {
				packageLauncherPowerModifier = -0.1;
			}
			if (packageLauncherPower <= 1) {
				packageLauncherPowerModifier = 0.1;
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
		numPackages -= 1;

		var packagePosition = body.getPosition();
		var newPackage = new Package(Game.ME.world , cast packagePosition.x * 100, cast packagePosition.y * 100);

		var x = Main.ME.scene.mouseX / 100;
		var y = Main.ME.scene.mouseY / 100;

		var dx = x - packagePosition.x;
		var dy = y - packagePosition.y;

		var vec: B2Vec2 = new B2Vec2(dx, dy);
		vec.normalize();
		vec.multiply(packageLauncherPower);

		newPackage.body.applyForce(vec , packagePosition);
	}
}