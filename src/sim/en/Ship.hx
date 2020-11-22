package sim.en;

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

	var w = 100; // w and h sprite coords
	var h = 200;

	var packageLauncherPower = 0.0;
	var packageLauncherPowerModifier = 0.1;

	var shipDefinition: ShipDefinition;
	var visuals: h2d.Object;

	// x and y in sprite coords
	public function new(shipDefinition: ShipDefinition, b2world, x, y) {
		super(x, y);

		this.shipDefinition = shipDefinition;

		var shape = new B2PolygonShape();
		shape.setAsBox(w/200, h/200); // div by 2 for halfwidth, div by 100 for b2 coords

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
		bodyDef.position.set(x/100, y/100); // div by 100 for b2 coords

		this.body = b2world.createBody(bodyDef);
		this.body.createFixture(fixtureDef);

		visuals = ShipVisuals.createFromDefinition(this.shipDefinition, 30, 30, spr);

		ca = Main.ME.controller.createAccess("hero"); // creates an instance of controller
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
			var sprayOrigin = this.body.getPosition().copy();
			sprayOrigin.multiply(100);
			sprayOrigin.add(this.body.getWorldVector(new B2Vec2(0, 50)));
			Game.ME.fx.spray(sprayOrigin.x, sprayOrigin.y, theta + Math.PI/2);

			var forceVec = this.body.getWorldVector(new B2Vec2(0, -5));
			this.body.applyForce(forceVec, center);
		}
		// if (ca.downDown() || ca.isKeyboardDown(hxd.Key.DOWN)) {
		//   var forceVec = this.body.getWorldVector(new B2Vec2(0, 100000));
		//   this.body.applyForce(forceVec, center);
		// }

		// if (ca.leftDown() || ca.isKeyboardDown(hxd.Key.LEFT)) {
		//   this.body.applyTorque(-100000);
		// }
		// if (ca.rightDown() || ca.isKeyboardDown(hxd.Key.RIGHT)) {
		//   this.body.applyTorque(100000);
		// }


		if (ca.xPressed()) {
			if (packageLauncherPower == 0) {
				packageLauncherPower = 1;
			} else {
				launchPackage();
				packageLauncherPower = 0;
			}
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
		trace(packageLauncherPower);

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