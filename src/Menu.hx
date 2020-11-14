import h2d.Text;
import h2d.Flow.FlowAlign;
import dn.Process;

class Menu extends Process {
    public static var ME : Menu;

    var flow: h2d.Flow;
    var ca : dn.heaps.Controller.ControllerAccess;

    var NEW_GAME: Int = 1;
    var HOW_TO_PLAY: Int = 2;
    var LEADERBOARD: Int = 3;
    var CREDITS: Int = 4;

    var options: Array<Int>;

    var selectedOption: Int;

	public function new() {
        #if !skip_menu
        destroy();
        Main.ME.startGame();
        return;
        #end

        super(Main.ME);
        createRoot(Main.ME.root);

        ca = Main.ME.controller.createAccess("menu");

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

        options = [NEW_GAME, HOW_TO_PLAY, LEADERBOARD, CREDITS];
        selectedOption = 0;
        select(0);

		Process.resizeAll();
	}

	function addText(str:String, c=0xFFFFFF) {
		var tf = new h2d.Text(Assets.fontPixel, flow);
		tf.scale(5);
		tf.text = str;
		tf.textColor = c;
    }

    function select(optionToSelect: Int) {
        if (optionToSelect >= options.length) {
            optionToSelect = 0;
        } else if (optionToSelect < 0) {
            optionToSelect = options.length - 1;
        }

        flow.getChildAt(options[selectedOption]).alpha = 1;
        flow.getChildAt(options[optionToSelect]).alpha = 0.5;
        selectedOption = optionToSelect;
    }

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
    }

    override function onDispose() {
        super.onDispose();
        options = null;
        ca.dispose();
	}

	function gc() {
		if( Entity.GC==null || Entity.GC.length==0 )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
    }

    override function update() {
        if (ca.upPressed()) {
            select(selectedOption - 1);
        }
        else if (ca.downPressed()) {
            select(selectedOption + 1);
        } else if (ca.bPressed()) {
            if (options[selectedOption] == CREDITS) {
                destroy();
                Main.ME.showCredits();
            }
            if (options[selectedOption] == NEW_GAME) {
                destroy();
                Main.ME.startGame();
            }
        }
    }
}

