import hxd.Res;
import h2d.Interactive;
import h2d.Flow;
import h2d.Text;
import dn.Process;

class Difficulty {
    public var title: String;
    public var gameModeKind: Data.GameModeKind;
    public var color: Int;
    public var id: Int;

    public function new(gameModeKind: Data.GameModeKind, id: Int, color: Int, title: String) {
        this.gameModeKind = gameModeKind;
        this.title = title;
        this.color = color;
        this.id = id;
    }

    public function playSound() {
        switch (gameModeKind) {
            case (ClassA):
                // Res.audio.duct_tape.play(false,.5);
            case (ClassB):
                Res.audio.horse.play(false,.5);
            case (ClassC):
                Res.audio.wilhelm.play(false,.5);
        }
    }

    public function description() {
        var desc = ['Budget: ' + gameMode().maxCost];
        switch (gameModeKind) {
            case (ClassA):
                desc.push("This one is easy. In fact, the customer doesn't");
                desc.push("remember that they ordered anything. They'll forget");
                desc.push("after 11 hours and you'll win.");
                desc.push(" ");
            case (ClassB):
                desc.push("Cyber Monday has come and gone. Deliver 5");
                desc.push("quintuplet space zebras, winners of the latest");
                desc.push("Interstellar derbathon. Don't take too long,");
                desc.push("would you kindly?");
            case (ClassC):
                desc.push("It is DEFCON 1 and supplies are dwindling.");
                desc.push("You have basically no budget to fabricate your craft and");
                desc.push("deliver vital supplies to 10 forward moon outposts.");
                desc.push(" ");
        }
        return desc;
    }
    public function gameMode(): Data.GameMode {
        return Data.gameMode.get(gameModeKind);
    }
    public static var EASY = new Difficulty(
        Data.GameModeKind.ClassA,
        1,
        0x1CE019,
        "Delapidated Deliverer"
    );
    public static var MEDIUM = new Difficulty(
        Data.GameModeKind.ClassB,
        2,
        0xBA914A,
        "Capable Courier"
    );
    public static var HARD = new Difficulty(
        Data.GameModeKind.ClassC,
        3,
        0xAD0909,
        "FTL Freighter"
    );
}

class SelectDifficulty extends Process {
    public static var ME : SelectDifficulty;

    var flow: h2d.Flow;
    var ca : dn.heaps.Controller.ControllerAccess;

    var options: Array<Difficulty>;

    var selectedOption: Int;
    var gameMode: Data.GameMode;
    var descriptionLines: Array<Text> = [];

    public function new() {
        super(Main.ME);
        createRoot(Main.ME.root);

        ca = Main.ME.controller.createAccess("menu");

		var bounds = new h2d.col.Bounds();
		bounds.set(0.0, 0.0, Const.VIEWPORT_WIDTH, Const.VIEWPORT_HEIGHT);
		var center = bounds.getCenter();
		var camera = Boot.ME.s2d.camera;
		camera.setAnchor(0.5, 0.5);
		camera.setPosition(center.x, center.y);

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.fillWidth = true;
		flow.fillHeight = true;
		flow.maxHeight = Const.VIEWPORT_HEIGHT;
		flow.multiline = true;
		flow.horizontalAlign = Middle;
		flow.verticalAlign = Middle;
		flow.paddingLeft = 40;

		var background = new Background(root);
		background.addStars(bounds);
        background.addMoon(Const.VIEWPORT_WIDTH * 0.8, Const.VIEWPORT_HEIGHT * 0.1, 0.3);

        flow = new h2d.Flow(root);
        flow.layout = Vertical;
        flow.fillWidth = true;
        flow.fillHeight = true;
        flow.horizontalAlign = Middle;
        flow.verticalAlign = Middle;

        options = [Difficulty.EASY, Difficulty.MEDIUM, Difficulty.HARD];

        addText("Difficulty");
        flow.addSpacing(50);
        addButton(Difficulty.EASY.title, 0);
        addButton(Difficulty.MEDIUM.title, 1);
        addButton(Difficulty.HARD.title, 2);
        flow.addSpacing(50);

        selectedOption = 0;

        for (i in 0...5) {
            var tf = new h2d.Text(Assets.fontMedium, flow);
            tf.text = "";
            tf.textColor = 0xFFFFFF;
            descriptionLines.push(new h2d.Text(Assets.fontMedium, flow));
        }

        setDescription(options[selectedOption]);
        select(0, false);

        Process.resizeAll();
    }

    function addText(str:String, c=0xFFFFFF) {
        var tf = new h2d.Text(Assets.fontLarge, flow);
        tf.text = str;
        tf.textColor = c;
        return tf;
    }

    function addButton(str:String, option: Int) {
		var tf = addText(str);
		var interactive = new Interactive(tf.calcTextWidth(str), tf.textHeight, tf);
		interactive.enableRightButton = true;

		interactive.onPush = function (event: hxd.Event) {
			if (event.button == 0) {
				selectedOption = option;
				buttonPressed();
			}
		}

		interactive.onOver = function (event: hxd.Event) {
			select(option);
		}
    }

    function setDescription(diff: Difficulty) {
        for (i in 0...5) {
            if (i < diff.description().length) {
                descriptionLines[i].text = diff.description()[i];
                descriptionLines[i].textColor = diff.color;
            } else {
                descriptionLines[i].text = "";
            }
        }
    }

    function select(optionToSelect: Int, play: Bool = true) {
        if(play) {
			Res.audio.select.play(false, 0.1);
		}

        if (optionToSelect >= options.length) {
            optionToSelect = 0;
        } else if (optionToSelect < 0) {
            optionToSelect = options.length - 1;
        }

        flow.getChildAt(options[selectedOption].id).alpha = 1;
        flow.getChildAt(options[optionToSelect].id).alpha = 0.5;
        setDescription(options[optionToSelect]);
        // updateHouses(options[selectedOption]);

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
            var x = Main.ME.scene.mouseX;
            var y = Main.ME.scene.mouseY;
            select(selectedOption - 1);
        }
        else if (ca.downPressed()) {
            select(selectedOption + 1);
        } else if (ca.bPressed()) {
            buttonPressed();
        }
    }

    function buttonPressed() {
        destroy();
        options[selectedOption].playSound();
        Main.ME.startShipBuilding(options[selectedOption].gameMode());
    }
}



