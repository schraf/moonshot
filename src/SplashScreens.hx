import h2d.Flow.FlowAlign;
import dn.Process;

class SplashScreens extends Process {
    var flow: h2d.Flow;
	var cinematic = new dn.Cinematic(Const.FPS);

	public function new() {
        super(Main.ME);
		createRoot(Main.ME.root);

        flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.fillWidth = true;
		flow.fillHeight = true;
		flow.horizontalAlign = Middle;
		flow.verticalAlign = Middle;

        cinematic.create({
            tw.createMs(root.alpha, 0>1, 500);
            1000;
            tw.createMs(root.alpha, 0, 1000);
            1000;
            destroy();
            Main.ME.startGame();
        });
        addText("Untitled Game Studio presents");

		Process.resizeAll();
	}

	function addText(str:String, c=0xFFFFFF) {
		var tf = new h2d.Text(Assets.fontPixel, flow);
		tf.scale(5);
		tf.text = str;
		tf.textColor = c;
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}


	function gc() {
		if( Entity.GC==null || Entity.GC.length==0 )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	override function preUpdate() {
		super.preUpdate();

		cinematic.update(tmod);
	}
}

