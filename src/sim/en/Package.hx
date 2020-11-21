package sim.en;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2FixtureDef;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2Body;

class Package extends Entity {
	public static var PACKAGE: Package = null;

	var w = 10; // w and h sprite coords
	var h = 10;

	var time:Float = 0.;
	public var body:B2Body;

	// x and y in sprite coords
	public function new(b2world, x, y) {
		super(x, y);
		PACKAGE = this;

		var shape = new B2PolygonShape();
		shape.setAsBox(w/200, h/200); // div by 2 for halfwidth, div by 100 for b2 coords

		var fixtureDef = new B2FixtureDef();
		fixtureDef.density = 1;
		fixtureDef.shape = shape;
		fixtureDef.friction = 0;

		var bodyDef = new B2BodyDef();
		bodyDef.type = B2BodyType.DYNAMIC_BODY;
		bodyDef.position.set(x/100, y/100); // div by 100 for b2 coords

		this.body = b2world.createBody(bodyDef);
		this.body.createFixture(fixtureDef);

		var texture = hxd.Res.load("ball.png").toTexture();

		spr.setTexture(texture);
		spr.setCenterRatio();
		sprScaleX = 40/ texture.width;
		sprScaleY = 40 / texture.height;
	}

	override function update() {
		var p = body.getPosition();
		setPosPixel(p.x * 100, p.y * 100);
		spr.rotation = body.getAngle();
	  }
}