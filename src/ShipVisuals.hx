import ShipDefinition.ShipPartAttachment;

class ShipVisuals {

	static function createPartVisuals(tileName: String, x: Float, y: Float, width: Float, height: Float, rotation: Int, scale: Float, center: Bool, ?parent: h2d.Object, ?id: String): h2d.Bitmap {
		var part = new h2d.Bitmap(Assets.ship.getTile(tileName), parent);
		part.x = x;
		part.y = y;
		part.width = width;
		part.height = height;

		if (id != null) {
			part.name = id;
		}

		if (center) {
			part.tile.dx = -(width * 0.5);
			part.tile.dy = -(height * 0.5);
		}

		if (rotation != 0) {
			part.rotation = hxd.Math.degToRad(rotation);
		}

		part.setScale(scale);

		return part;
	}

	public static function create(id: String, part: Data.ShipPart, width: Float, height: Float, rotation: Int, attachments: Int, ?parent: h2d.Object): h2d.Bitmap {
		var base = createPartVisuals("base", 0.0, 0.0, width, height, 0, 1.0, false, parent, "base");
		createPartVisuals(part.tile_name, width * 0.5, height * 0.5, width, height, rotation, part.scale != null ? part.scale : 1.0, true, base, id);
		setAttachments(base, attachments);
		return base;
	}

	public static function createFromDefinition(definition: ShipDefinition, width: Float, height: Float, ?parent: h2d.Object): h2d.Object {
		var object = new h2d.Object(parent);
		var offsetX = Const.SHIP_WIDTH * width * 0.5;
		var offsetY = Const.SHIP_HEIGHT * height * 0.5;

		for (shipPartDefinition in definition.parts) {
			var part = create(shipPartDefinition.id, shipPartDefinition.part, width, height, shipPartDefinition.rotation, shipPartDefinition.attachments, object);
			part.x = shipPartDefinition.x * width - offsetX;
			part.y = shipPartDefinition.y * height - offsetY;
		}

		return object;
	}

	public static function addAttachment(partVisual: h2d.Bitmap, attachmentDir: ShipPartAttachment) {
		var rotation: Int = 0;

		switch (attachmentDir) {
			case ShipPartAttachment.Bottom:
				rotation = 0;
			case ShipPartAttachment.Left:
				rotation = 90;
			case ShipPartAttachment.Top:
				rotation = 180;
			case ShipPartAttachment.Right:
				rotation = 270;
		}

		var attachment = createPartVisuals("attachment", partVisual.width * 0.5, partVisual.height * 0.5, partVisual.width, partVisual.height, rotation, 1.0, true, partVisual, "attachment");
	}

	public static function setAttachments(partVisual: h2d.Bitmap, attachments: Int) {
		var i = partVisual.numChildren - 1;

		while (i >= 0) {
			var child = partVisual.getChildAt(i);

			if (child.name == "attachment") {
				child.remove();
			}
			--i;
		}

		if (attachments & ShipPartAttachment.Bottom != 0) {
			addAttachment(partVisual, ShipPartAttachment.Bottom);
		}

		if (attachments & ShipPartAttachment.Top != 0) {
			addAttachment(partVisual, ShipPartAttachment.Top);
		}

		if (attachments & ShipPartAttachment.Left != 0) {
			addAttachment(partVisual, ShipPartAttachment.Left);
		}

		if (attachments & ShipPartAttachment.Right != 0) {
			addAttachment(partVisual, ShipPartAttachment.Right);
		}
	}
}
