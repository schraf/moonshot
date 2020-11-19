package sim.en;

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
  public var body:B2Body;

  var w = 100; // w and h sprite coords
  var h = 200;

  // x and y in sprite coords
  public function new(b2world, x, y) {
    super(x, y);

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

    var texture = hxd.Res.load("rocket.png").toTexture();
    spr.setTexture(texture);
    spr.setCenterRatio();
    sprScaleX = w / texture.width;
    sprScaleY = h / texture.height;

    var tf = new h2d.Text(hxd.Res.fonts.minecraftiaOutline.toFont(), spr);
    tf.text = "Untitled Rocket!";
    tf.scale(20);
    tf.textAlign = Center;

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


    // if (ca.xPressed()) {
    //   //
    // }
  }
}