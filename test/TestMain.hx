using Lambda;

class TestMain implements Short<"Lambda"> {
	static public function main() {
		testShortLambda();
	}
	
	static function testShortLambda() {
		// single argument
		var a = [1, 2, 3].map(x => x * 2);
		trace(a); // [2,4,6]
		
		// multiple arguments
		var b = [1, 2, 3].fold([x, r] => r + x, 0);
		trace(b); // 6
		
		// nested
		var c = [1, 2, 3].map(x => (k => x * k));
		trace(c); // [function, function, function]
		var d = c.map(x => x(3));
		trace(d); // [3,6,9]
		
		// no arguments
		var e = _ => 99;
		trace(e()); // 9
		
		// default values
		var f = [x, y = 2] => x + y;
		trace(f(1)); // 3
		trace(f(1, 4)); // 5
		
		// map comprehension still works
		var map = [1 => "foo", 2 => "bar"];
		trace(map); // IntMap
		
		// but we can work around that
		var nomap = [(x => x * 2), x => x * 3, x => x * 4];
		var g = nomap.map(f => f(2));
		trace(g); // [4,6,8]
		var h = [1, 2, 3].map(i => nomap.map(f => f(i)));
		trace(h); // [[2,3,4],[4,6,8],[6,9,12]]
		
		// and it works inside the values
		var map2 = [1 => x => x * 2, 2 => x => x * 3];
		trace(map2.get(1)(6)); // 12
		trace(map2.get(2)(6)); // 18
		
		// no lambda inside map comprehension
		var compr = [for (x in 1...10) x => x * 2];
		trace(compr); // IntMap
	}
}