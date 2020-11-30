package sim.en;

import Entity.EntityTypeFlags;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2BodyDef;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2FixtureDef;
import hxd.Res;

class House extends Entity {
	static var SIZE = 25;

	public var arrow: HouseArrow;
	public var angle: Float;

	public function new(b2world, x, y, angle) {
		super(x, y);
		this.typeFlags |= EntityTypeFlags.HOUSE;

		this.angle = angle;

		Entity.HOUSES.push(this);

		spr.set(Assets.background, "house");
		spr.setCenterRatio();
		spr.rotation = angle + Math.PI * 0.5;
		setScale(SIZE / spr.tile.width);
		setPosPixel(x, y);

		var shape = new B2PolygonShape();
		shape.setAsBox(SIZE/200, SIZE/200); // div by 2 for halfwidth, div by 100 for b2 coords

		var fixtureDef = new B2FixtureDef();
		fixtureDef.density = 10;
		fixtureDef.shape = shape;
		fixtureDef.friction = 0;
		fixtureDef.userData = this;

		var bodyDef = new B2BodyDef();
		bodyDef.type = B2BodyType.STATIC_BODY;
		bodyDef.position.set(x/100, y/100);
		bodyDef.angle = angle;

		this.body = b2world.createBody(bodyDef);
		this.body.createFixture(fixtureDef);

		arrow = new HouseArrow(x, y, this);
	}

	override function onCollision (entity: Entity) {
		if (entity.isA(EntityTypeFlags.PACKAGE)) {
			Game.ME.fx.markerText(this.cx, this.cy, "Thanks!", 2);
			var velocity = entity.body.m_linearVelocity;
			var speed = Math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
			Main.ME.leaderboards.removeFromScore(cast (speed * 100));
			Res.audio.delivered.play(false, 0.1);
			destroy();
		}
	}

	override function dispose() {
		Entity.HOUSES.remove(this);
		super.dispose();
		arrow.dispose();
	}

	override function update() {
		arrow.update();
	}
}
