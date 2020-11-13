package ship_building;

import h2d.Graphics;
import hxd.Window;

class ShipPart {
    public static var ALL : Array<ShipPart> = [];
    public static var GC : Array<ShipPart> = [];

	public var shipBuilding(get,never) : ShipBuilding; inline function get_shipBuilding() return ShipBuilding.ME;
	public var destroyed(default,null) = false;
	public var ftime(get,never) : Float; inline function get_ftime() return ShipBuilding.ME.ftime;
	public var tmod(get,never) : Float; inline function get_tmod() return ShipBuilding.ME.tmod;

	public var cd : dn.Cooldown;

	public var uid : Int;
    public var cx = 0;
    public var cy = 0;
    public var xr = 0.5;
    public var yr = 1.0;

    public var dx = 0.;
    public var dy = 0.;
    public var bdx = 0.;
    public var bdy = 0.;
	public var dxTotal(get,never) : Float; inline function get_dxTotal() return dx+bdx;
	public var dyTotal(get,never) : Float; inline function get_dyTotal() return dy+bdy;
	public var frict = 0.82;
	public var bumpFrict = 0.93;
	public var hei : Float = Const.GRID;
	public var radius = Const.GRID*0.5;

	public var dir(default,set) = 1;
	public var sprScaleX = 3.5 * Const.SHIP_PART_SCALE;
	public var sprScaleY = 3.5 * Const.SHIP_PART_SCALE;
	public var ShipPartVisible = true;

    public var spr : HSprite;
    public var g : Graphics;
	public var colorAdd : h3d.Vector;
	var debugLabel : Null<h2d.Text>;

	public var footX(get,never) : Float; inline function get_footX() return (cx+xr)*Const.GRID;
	public var footY(get,never) : Float; inline function get_footY() return (cy+yr)*Const.GRID;
	public var headX(get,never) : Float; inline function get_headX() return footX;
	public var headY(get,never) : Float; inline function get_headY() return footY-hei;
	public var centerX(get,never) : Float; inline function get_centerX() return footX;
	public var centerY(get,never) : Float; inline function get_centerY() return footY-hei*0.5;

	var actions : Array<{ id:String, cb:Void->Void, t:Float }> = [];

    public function new(x:Int, y:Int, type: ShipPartType = Empty) {
        uid = Const.NEXT_UNIQ;
        ALL.push(this);

		cd = new dn.Cooldown(Const.FPS);
		setPosCase(x,y);

        spr = new HSprite(Assets.tiles);
        ShipBuilding.ME.root.add(spr, Const.DP_MAIN);
		// spr.colorAdd = colorAdd = new h3d.Vector();
		// spr.setCenterRatio(0.5,1);

		g = new h2d.Graphics(spr);
		switch type {
			case Empty: 
				ShipPartVisible = false;
			case Block:
				g.beginFill(0x37B9D0);
			case Booster:
				g.beginFill(0xE72020);
			case Package:
				g.beginFill(0xA16F62);
			default:
				g.beginFill(0xbbbbbb);
		}
        g.beginFill(0x042b62);
        g.drawRect(0,0,Const.SHIP_PART_SCALE * .9,Const.SHIP_PART_SCALE * .9);
	}

	public function setType(type: ShipPartType) {
		ShipPartVisible = true;
		switch type {
			case Empty: 
				ShipPartVisible = false;
			case Block:
				g.beginFill(0x042b62);
			default:
				g.beginFill(0xffffff);
		}
        g.beginFill(0x042b62);
		g.drawRect(0,0,Const.SHIP_PART_SCALE * .9,Const.SHIP_PART_SCALE * .9);
	}

	inline function set_dir(v) {
		return dir = v>0 ? 1 : v<0 ? -1 : dir;
	}

	public inline function isAlive() {
		return !destroyed;
	}

	public function kill(by:Null<ShipPart>) {
		destroy();
	}

	public function setPosCase(x:Int, y:Int) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 1;
	}

	public function setPosPixel(x:Float, y:Float) {
		cx = Std.int(x/Const.GRID);
		cy = Std.int(y/Const.GRID);
		xr = (x-cx*Const.GRID)/Const.GRID;
		yr = (y-cy*Const.GRID)/Const.GRID;
	}

	public function bump(x:Float,y:Float) {
		bdx+=x;
		bdy+=y;
	}

	public function select() {
	}

	public function cancelVelocities() {
		dx = bdx = 0;
		dy = bdy = 0;
	}

	public function is<T:ShipPart>(c:Class<T>) return Std.is(this, c);
	public function as<T:ShipPart>(c:Class<T>) : T return Std.downcast(this, c);

	public inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	public inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);
	public inline function pretty(v,?p=1) return M.pretty(v,p);

	public inline function dirTo(e:ShipPart) return e.centerX<centerX ? -1 : 1;
	public inline function dirToAng() return dir==1 ? 0. : M.PI;
	public inline function getMoveAng() return Math.atan2(dyTotal,dxTotal);

	public inline function distCase(e:ShipPart) return M.dist(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr);
	public inline function distCaseFree(tcx:Int, tcy:Int, ?txr=0.5, ?tyr=0.5) return M.dist(cx+xr, cy+yr, tcx+txr, tcy+tyr);

	public inline function distPx(e:ShipPart) return M.dist(footX, footY, e.footX, e.footY);
	public inline function distPxFree(x:Float, y:Float) return M.dist(footX, footY, x, y);

	public function makePoint() return new CPoint(cx,cy, xr,yr);

    public inline function destroy() {
        if( !destroyed ) {
            destroyed = true;
            GC.push(this);
        }
    }

    public function dispose() {
        ALL.remove(this);

		colorAdd = null;

		spr.remove();
		spr = null;

		if( debugLabel!=null ) {
			debugLabel.remove();
			debugLabel = null;
		}

		cd.destroy();
		cd = null;
    }

	public inline function debugFloat(v:Float, ?c=0xffffff) {
		debug( pretty(v), c );
	}
	public inline function debug(?v:Dynamic, ?c=0xffffff) {
		#if debug
		if( v==null && debugLabel!=null ) {
			debugLabel.remove();
			debugLabel = null;
		}
		if( v!=null ) {
			if( debugLabel==null )
				debugLabel = new h2d.Text(Assets.fontTiny, ShipBuilding.ME.root);
			debugLabel.text = Std.string(v);
			debugLabel.textColor = c;
		}
		#end
	}

	function chargeAction(id:String, sec:Float, cb:Void->Void) {
		if( isChargingAction(id) )
			cancelAction(id);
		if( sec<=0 )
			cb();
		else
			actions.push({ id:id, cb:cb, t:sec});
	}

	public function isChargingAction(?id:String) {
		if( id==null )
			return actions.length>0;

		for(a in actions)
			if( a.id==id )
				return true;

		return false;
	}

	public function cancelAction(?id:String) {
		if( id==null )
			actions = [];
		else {
			var i = 0;
			while( i<actions.length ) {
				if( actions[i].id==id )
					actions.splice(i,1);
				else
					i++;
			}
		}
	}

	function updateActions() {
		var i = 0;
		while( i<actions.length ) {
			var a = actions[i];
			a.t -= tmod/Const.FPS;
			if( a.t<=0 ) {
				actions.splice(i,1);
				if( isAlive() )
					a.cb();
			}
			else
				i++;
		}
	}


    public function preUpdate() {
		cd.update(tmod);
		updateActions();
    }

    public function postUpdate() {
        spr.x = (cx+xr)*Const.GRID;
        spr.y = (cy+yr)*Const.GRID;
        spr.scaleX = dir*sprScaleX;
        spr.scaleY = sprScaleY;
		spr.visible = ShipPartVisible;

		if( debugLabel!=null ) {
			debugLabel.x = Std.int(footX - debugLabel.textWidth*0.5);
			debugLabel.y = Std.int(footY+1);
		}
	}

	public function fixedUpdate() {} // runs at a "guaranteed" 30 fps

    public function update() { // runs at an unknown fps
		// X
		var steps = M.ceil( M.fabs(dxTotal*tmod) );
		var step = dxTotal*tmod / steps;
		while( steps>0 ) {
			xr+=step;

			// [ add X collisions checks here ]

			while( xr>1 ) { xr--; cx++; }
			while( xr<0 ) { xr++; cx--; }
			steps--;
		}
		dx*=Math.pow(frict,tmod);
		bdx*=Math.pow(bumpFrict,tmod);
		if( M.fabs(dx)<=0.0005*tmod ) dx = 0;
		if( M.fabs(bdx)<=0.0005*tmod ) bdx = 0;

		// Y
		var steps = M.ceil( M.fabs(dyTotal*tmod) );
		var step = dyTotal*tmod / steps;
		while( steps>0 ) {
			yr+=step;

			// [ add Y collisions checks here ]

			while( yr>1 ) { yr--; cy++; }
			while( yr<0 ) { yr++; cy--; }
			steps--;
		}
		dy*=Math.pow(frict,tmod);
		bdy*=Math.pow(bumpFrict,tmod);
		if( M.fabs(dy)<=0.0005*tmod ) dy = 0;
		if( M.fabs(bdy)<=0.0005*tmod ) bdy = 0;
    }
}