package en;

class MoonEntity extends Entity {


  public function new(x,y) {
    super(x,y);
    // Some default rendering for our character
    var g = new h2d.Graphics(spr);
    g.beginFill(0xaaaaaa);
    g.drawCircle(0, 0, 100);
  }

}