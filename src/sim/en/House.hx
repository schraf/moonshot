package sim.en;

import box2D.dynamics.B2BodyType;
import box2D.dynamics.B2BodyDef;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2FixtureDef;

class House extends Entity {
	static var SIZE = 25;
	
	public function new(b2world, x, y, angle) {
		super(0, 0);

		Entity.HOUSES.push(this);

		spr.set(Assets.background, "house");
		spr.setCenterRatio(0.5, 0.7);
		spr.rotation = angle + Math.PI * 0.5;
		setScale(SIZE / spr.tile.width);
		setPosPixel(x, y);

		var shape = new B2PolygonShape();
		shape.setAsBox(spr.tile.width/200, spr.tile.height/200); // div by 2 for halfwidth, div by 100 for b2 coords

		var fixtureDef = new B2FixtureDef();
		fixtureDef.density = 10;
		fixtureDef.shape = shape;
    	fixtureDef.friction = 0;
    	fixtureDef.userData = ObjTypes.House;

		var bodyDef = new B2BodyDef();
		bodyDef.type = B2BodyType.DYNAMIC_BODY;
		bodyDef.position.set(x/100, y/100);

		this.body = b2world.createBody(bodyDef);
		this.body.createFixture(fixtureDef);
	}

	override function dispose() {
		Entity.HOUSES.remove(this);
		super.dispose();
	}

	override function update() {
	}
}
