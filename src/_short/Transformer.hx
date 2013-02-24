package _short;

import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;

class Transformer{
	macro static public function build():Array<Field> {
		var c = Context.getLocalClass();
		if (c == null)
			Context.error("Short can only be used on classes", Context.currentPos());
		var c = c.get();
		if (c.meta.has(":shortDone"))
			return null;
		c.meta.add(":shortDone", [], c.pos);
		var l = [for (i in c.interfaces) if (i.t.toString() == "Short") i.params[0].toString().substr(1)];
		var tmap = [
			"Lambda" => false
		];
		for (t in l) {
			if (!tmap.exists(t))
				Context.error('Unknown Short option: $t', c.pos);
			tmap.set(t, true);
		}
		var fields = Context.getBuildFields();
		for (field in fields) {
			switch(field.kind) {
				case FVar(t,e) if (e != null):
					field.kind = FVar(t,transform(tmap,e));
				case FProp(get, set, t, e) if (e != null):
					field.kind = FProp(get, set, t, transform(tmap, e));
				case FFun(f) if (f.expr != null):
					f.expr = transform(tmap, f.expr);
				case _:
			}
		}
		return fields;
	}
	
	static function transform(tmap:TMap, e:Expr) {
		return switch(e.expr) {
			case EBinop(OpArrow, e1, e2) if (tmap.exists("Lambda")):
				function makeArg(e) {
					return switch(e.expr) {
						case EBinop(OpAssign, { expr: EConst(CIdent(s)) }, e2):
							{ name: s, opt: true, type: null, value: e2 }
						case EConst(CIdent(s)) if (s != "_"):
							{ name: s, opt: false, type: null, value: null };
						case _: Context.error("Identifier expected", e.pos);
					}
				}
				var args = switch(e1.expr) {
					case EArrayDecl(el): el.map(makeArg);
					case EConst(CIdent("_")): [];
					case EConst(CIdent(s)): [{ name: s, opt: false, type: null, value: null }];
					case _: [makeArg(e1)];
				}
				var func = {
					args: args,
					ret: null,
					params: [],
					expr: macro return ${transform(tmap, e2)}
				};
				{
					expr: EFunction(null, func),
					pos: e.pos
				}
			case EArrayDecl([]):
				e;
			case EArrayDecl([{expr: EFor(_) | EWhile(_)}]):
				// skip map comprehension
				e;
			case EArrayDecl(el) if (tmap.exists("Lambda") && switch (el[0].expr) { case EBinop(OpArrow, _, _): true; case _: false; }):
				// manual mapping to not break map syntax
				var el = [for (e in el) {
					switch(e.expr) {
						case EBinop(OpArrow, e1, e2): {
							expr: EBinop(OpArrow, e1, transform(tmap, e2)),
							pos: e.pos
						}
						case _: Context.error("Expected a => b", e.pos);
					}
				}];
				macro $a{el};
			case _:
				e.map(transform.bind(tmap));
		}
	}
}

private typedef TMap = Map<String, Bool>;