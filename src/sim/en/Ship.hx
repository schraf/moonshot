package sim.en;

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

	var shipPartWidth = 30;
	var shipPartHeight = 30;
	var shipPartOffsetX = Const.SHIP_WIDTH * 30 * 0.5;
	var shipPartOffsetY = Const.SHIP_HEIGHT * 30 * 0.5;

	var packageLauncherPower = 0.0;
	var packageLauncherPowerModifier = 0.1;

	var shipDefinition: ShipDefinition;
	var visuals: h2d.Object;

	var numPackages = 0;
	var energyIncome = 0;
	var energyCapacity = 0;
	var shieldIncome = 0;
	var shieldCapacity = 0;
	var forwardBoosters: Array<B2Vec2> = [];
	var backwardsBoosters: Array<B2Vec2> = [];
	var leftBoosters: Array<B2Vec2> = [];
	var rightBoosters: Array<B2Vec2> = [];
	var forwardLasers: Array<B2Vec2> = [];
	var rearLasers: Array<B2Vec2> = [];
	var leftLasers: Array<B2Vec2> = [];
	var rightLasers: Array<B2Vec2> = [];

	// x and y in sprite coords
	public function new(shipDefinition: ShipDefinition, b2world, x, y) {
		super(x, y);

		this.shipDefinition = shipDefinition;

		visuals = ShipVisuals.createFromDefinition(this.shipDefinition, shipPartWidth, shipPartHeight, spr);
		
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
		
		for(shipPart in shipDefinition.parts) {
			switch shipPart.part.id {
				case Data.ShipPartKind.Booster:
					addBooster(shipPart);
				case Data.ShipPartKind.Laser:
					addLaser(shipPart);
				case Data.ShipPartKind.Shield:
					addShield(shipPart);
				case Data.ShipPartKind.SolarPanel:
					addSolarPanel(shipPart);
				case Data.ShipPartKind.Battery:
					addBattery(shipPart);
				case Data.ShipPartKind.Package:
					addPackage(shipPart);
				case Data.ShipPartKind.Core:
			}

			shape.setAsOrientedBox(shipPartWidth / 200, shipPartHeight / 200, new B2Vec2((shipPart.x * shipPartWidth - shipPartOffsetX + (shipPartWidth / 2)) / 100, (shipPart.y * shipPartHeight - shipPartOffsetY + (shipPartHeight / 2)) / 100));
			this.body.createFixture(fixtureDef);
		}

		ca = Main.ME.controller.createAccess("hero"); // creates an instance of controller
	}

	function addBooster(shipPart: ShipPartDefinition) {
		var origin = new B2Vec2();
		origin.x += shipPart.x * shipPartWidth - shipPartOffsetX;
		origin.y += shipPart.y * shipPartHeight - shipPartOffsetY;
		
		switch shipPart.rotation {
			case 0:
				forwardBoosters.push(origin);
			case 90:
				leftBoosters.push(origin);
			case 180:
				backwardsBoosters.push(origin);
			case 270:
				rightBoosters.push(origin);
		}
	}

	function addLaser(shipPart: ShipPartDefinition) {
		var origin = new B2Vec2();
		origin.x += shipPart.x * shipPartWidth - shipPartOffsetX;
		origin.y += shipPart.y * shipPartHeight - shipPartOffsetY;

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
		shieldIncome += 5;
		shieldCapacity += 100;
	}

	function addSolarPanel(shipPart: ShipPartDefinition) {
		energyIncome += 10;
	}

	function addBattery(shipPart: ShipPartDefinition) {
		energyCapacity += 100;
	}

	function addPackage(shipPart: ShipPartDefinition) {
		numPackages += 1;
	}

	override function dispose() {
		super.dispose();
		ca.dispose(); // release on destruction
	}

	override function update() {
		super.update();
		var theta = body.getAngle();
		var p = body.getPosition();
		setPosPixel(p.x * 100, p.y * 100);
		spr.rotation = theta;

		var center = this.body.getPosition();
		if (ca.upDown() || ca.isKeyboardDown(hxd.Key.UP)) {		
			var forceVec = this.body.getWorldVector(new B2Vec2(0, forwardBoosters.length *-1));
			this.body.applyForce(forceVec, center);
			fireBoosterParticles(forwardBoosters, theta);
		}

		if (ca.downDown() || ca.isKeyboardDown(hxd.Key.DOWN)) {
		  var forceVec = this.body.getWorldVector(new B2Vec2(0, backwardsBoosters.length));
		  this.body.applyForce(forceVec, center);
		  fireBoosterParticles(backwardsBoosters, theta + Math.PI);
		}

		if (ca.leftDown() || ca.isKeyboardDown(hxd.Key.LEFT)) {
			var forceVec = this.body.getWorldVector(new B2Vec2(leftBoosters.length *-1, 0));
			this.body.applyForce(forceVec, center);
			fireBoosterParticles(leftBoosters, theta + Math.PI + Math.PI/2);
		}
		if (ca.rightDown() || ca.isKeyboardDown(hxd.Key.RIGHT)) {
			var forceVec = this.body.getWorldVector(new B2Vec2(rightBoosters.length, 0));
			this.body.applyForce(forceVec, center);
			fireBoosterParticles(rightBoosters, theta + Math.PI/2);
		}


		if (ca.xPressed() && numPackages > 0) {
			if (packageLauncherPower == 0) {
				packageLauncherPower = 1;
			} else {
				launchPackage();
				packageLauncherPower = 0;
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