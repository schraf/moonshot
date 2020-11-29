package sim.en;

import Entity.EntityTypeFlags;
import box2D.dynamics.B2FilterData;
import box2D.common.math.B2Vec2;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2Body;

class Package extends Entity {
	var w = 10; // w and h sprite coords
	var h = 10;

	var time:Float = 0.;

	// x and y in sprite coords
	public function new(b2world, x, y) {
		super(x, y);
		this.typeFlags |= EntityTypeFlags.PACKAGE;

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

		spr.set(Assets.background, "package");
		spr.setCenterRatio();
		setScale(40 / spr.tile.width);

		this.body.applyTorque((Math.random() - Math.random()) * Const.PACKAGE_ROTATION_SPEED);
	}

	override function onCollision (entity: Entity) {
		if (entity.isA(EntityTypeFlags.HOUSE)) {
			destroy();
		}
	}

	override function update() {
		var p = body.getPosition();
		setPosPixel(p.x * 100, p.y * 100);
		spr.rotation = body.getAngle();
	}
}