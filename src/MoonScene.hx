
import h3d.Engine;
import h2d.Tile;
import h2d.TileGroup;
import h3d.mat.*;
import h3d.scene.*;

class MoonScene {
  static var PW = 200;
  static var PH = 200;
  var scene: Scene;
  public var root: Object;
  var renderTarget : Texture;

  public function new() {
    scene = new Scene();
    root = new Object(scene);
    var prim = new h3d.prim.Sphere(1, 128, 128);
    prim.translate( 0, 0, 0);
    prim.addNormals();
    prim.addUVs();
    var tex = hxd.Res.img.moon_nasa.toTexture();
    var obj = new Mesh(prim, h3d.mat.Material.create(tex), root);
    obj.material.shadows = false;
    var light = new h3d.scene.fwd.DirLight(new h3d.Vector(0, 1, 0), scene);
    scene.lightSystem.ambientLight.set(0.3, 0.3, 0.3);
    // scene.camera.pos.set(x, y, 0);

    renderTarget = new Texture(PW, PH, [ Target ]);
    renderTarget.depthBuffer = new DepthBuffer(PW, PH);

  }

  public function getTexture(x, y) {
    scene.camera.pos.set(x, y, 0);
    var engine = Game.ME.engine;
    engine.pushTarget(renderTarget);
    engine.clear(0, 1); // Clears the render target texture and depth buffer
    scene.render(engine);
    engine.popTarget();
    
    return renderTarget;
  }
}
