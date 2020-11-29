package sim.en;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Vec2;
import h2d.Bitmap;

class HouseArrow extends Entity {
  var bitmap: Bitmap;
  var x: Float;
  var y: Float;
  var t = 0.0;
  var house: House;

  var SIZE = 60;

  public function new(x, y, house) {
    super(x, y);
    setPosPixel(x, y);
    this.house = house;

    spr.set(Assets.ship, "laser");
    this.x = x;
    this.y = y;
    
    
    // this.x = 0 - spr.tile.width / 2;
    setScale(SIZE / spr.tile.width);
    spr.setPosition(this.x, this.y);
    spr.setCenterRatio();
  }

  override public function update() {
    t += .1;
    
    if (Game.ME.trackingCamera.nearCenter(house.centerX, house.centerY, .8)) {
      var offset = new B2Vec2(Math.cos(house.angle), Math.sin(house.angle));
      offset.multiply(100 + 5*Math.sin(t));
      this.x = house.centerX + offset.x;
      this.y = house.centerY + offset.y;
      setPosPixel(this.x, this.y);
      spr.rotation = house.angle + Math.PI / 2;
      return;
    }

    var ship = Game.ME.ship;
    var dx = house.centerX - ship.centerX;
    var dy = house.centerY - ship.centerY;

    spr.rotation = Math.atan2(dy, dx) + Math.PI/2;
    
    var offset = new B2Vec2(dx, dy);
    offset.normalize();
    offset.multiply(200 + 5*Math.sin(t));
    setPosPixel(ship.centerX + offset.x, ship.centerY + offset.y);

  }
}