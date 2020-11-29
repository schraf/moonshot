package sim.en;

import box2D.dynamics.B2FilterData;
import Entity.EntityTypeFlags;
import box2D.collision.shapes.B2CircleShape;
import h2d.Bitmap;
import box2D.dynamics.B2World;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2PolygonShape;
import dn.heaps.GamePad.PadKey;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;

class Asteroid extends Entity {
  var time: Float = 0.;

	var r = 20;

	public function new(b2world, x, y) {
		super(x, y);
		this.typeFlags |= EntityTypeFlags.ASTEROID;
		this.ignoreGravity = true;

		Entity.ASTEROIDS.push(this);

		var shape = new B2CircleShape(r/100);

		var wallFilterData = new B2FilterData();
		wallFilterData.groupIndex = -2;

		var fixtureDef = new B2FixtureDef();
		fixtureDef.density = 10;
		fixtureDef.shape = shape;
		fixtureDef.friction = 0;
		fixtureDef.userData = this;
		fixtureDef.filter = wallFilterData;

		var bodyDef = new B2BodyDef();
		bodyDef.type = B2BodyType.DYNAMIC_BODY;
		bodyDef.position.set(x/100, y/100);

		this.body = b2world.createBody(bodyDef);
		this.body.createFixture(fixtureDef);

		spr.set(Assets.background, Math.random() <= 0.5 ? "asteroid_a" : "asteroid_b");
		spr.setCenterRatio();
		setScale((r<<1) / spr.tile.width);

		this.body.applyTorque((Math.random() - Math.random()) * Const.ASTEROID_ROTATION_SPEED);
		this.collider = new h2d.col.Circle(x, y, r);
	}

	override function dispose() {
		Entity.ASTEROIDS.remove(this);
		super.dispose();
	}

	override function onCollision(entity:Entity) {
		if (entity.isA(EntityTypeFlags.PROJECTILE)) {
			destroy();
		}
	}

	override function update() {
		var theta = body.getAngle();
		var pos = getBodyPosition();
		setPosPixel(pos.x, pos.y);
		spr.rotation = body.getAngle();

		var collider = cast(this.collider, h2d.col.Circle);
		collider.x = pos.x;
		collider.y = pos.y;

		if (pos.x < 0.0 || pos.x > Const.FIELD_WIDTH || pos.y < 0.0 || pos.y > Const.FIELD_HEIGHT) {
			destroy();
		}
	}
}