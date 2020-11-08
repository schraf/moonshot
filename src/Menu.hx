import h2d.Flow.FlowAlign;
import dn.Process;

class Menu extends Process {
    public static var ME : Menu;

    var flow: h2d.Flow;

	public function new() {
        super(Main.ME);
		createRoot(Main.ME.root);

        flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.fillWidth = true;
		flow.fillHeight = true;
		flow.horizontalAlign = Middle;
		flow.verticalAlign = Middle;

        addText("MAIN MENU");
        flow.addSpacing(50);
        addText("New Game");
        addText("How To Play");
        addText("Leaderboards");
        addText("Credits");

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
}

