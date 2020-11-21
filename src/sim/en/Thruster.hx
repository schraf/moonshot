package sim.en;

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

class Thruster extends Entity {
  var ca: dn.heaps.Controller.ControllerAccess;
  var key: PadKey;
  var time: Float = 0.;

  var w = 50;
  var h = 100;

  var force = 1;

  public function new(b2world, x, y, angle, key) {
    super(x, y);
    this.key = key;
    ignoreGravity = true;

    var shape = new B2PolygonShape();
    shape.setAsBox(w/200, h/200); // div by 2 for halfwidth, div by 100 for b2 coords

    var fixtureDef = new B2FixtureDef();
    fixtureDef.density = 1;
    fixtureDef.shape = shape;
    fixtureDef.friction = 0;

    var bodyDef = new B2BodyDef();
    bodyDef.type = B2BodyType.DYNAMIC_BODY;
    bodyDef.position.set(x/100, y/100);
    bodyDef.angle = angle;

    this.body = b2world.createBody(bodyDef);
    this.body.createFixture(fixtureDef);

    var texture = hxd.Res.load("thruster.png").toTexture();

    spr.setTexture(texture);
    spr.setCenterRatio();
    sprScaleX = w / texture.width;
    sprScaleY = h / texture.height;

    ca = ca = Main.ME.controller.createAccess("hero");
  }

  override function update() {
    var theta = body.getAngle();
    var p = body.getPosition();
    setPosPixel(p.x * 100, p.y * 100);
    spr.rotation = body.getAngle();
    if (ca.isDown(key)) {
      var up = this.body.getWorldVector(new B2Vec2(0, -1));
      var sprayOrigin = this.body.getPosition().copy();
      sprayOrigin.multiply(100);
      var offset = up.copy();
      offset.multiply(-h/2);
      sprayOrigin.add(offset);
      Game.ME.fx.spray(sprayOrigin.x, sprayOrigin.y, theta + Math.PI/2);
      var forceVec = up.copy();
      forceVec.multiply(this.force);
      sprayOrigin.multiply(1/100);
      this.body.applyForce(forceVec, sprayOrigin);
    }
  }


}