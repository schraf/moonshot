package ui;

class Panel extends h2d.Flow {

	public function new (title: String, ?parent: h2d.Object) {
		super(parent);
		layout = h2d.Flow.FlowLayout.Vertical;

		addHeader(title);
	}

	public function addRow (object: h2d.Object) {
		addSpacing(5);

		var row = new h2d.Flow(this);
		new h2d.Bitmap(Assets.ui.getTile("BlockPrimary"), row);
		row.addSpacing(5);
		row.addChild(object);
	}

	private function addHeader (text: String) {
		var header = new h2d.Flow(this);
		header.verticalAlign = h2d.Flow.FlowAlign.Top;

		new h2d.Bitmap(Assets.ui.getTile("ShortCorner"), header);
		header.addSpacing(5);
		var title = new h2d.Text(Assets.fontSmall, header);
		title.text = text;
		header.addSpacing(5);
		var tile = Assets.ui.getTile("SmallEndCap");
		tile.flipX();
		tile.dx = 0.0;
		new h2d.Bitmap(tile, header);
	}

	public function addFooter () {
		addSpacing(5);

		var footer = new h2d.Flow(this);
		footer.verticalAlign = h2d.Flow.FlowAlign.Bottom;

		var tile = Assets.ui.getTile("LongCorner");
		tile.flipY();
		tile.dy = 0.0;
		new h2d.Bitmap(tile, footer);
		footer.addSpacing(5);

		tile = Assets.ui.getTile("SmallEndCap");
		tile.flipX();
		tile.dx = 0.0;
		new h2d.Bitmap(tile, footer);
	}
}
