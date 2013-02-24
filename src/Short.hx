#if !haxe3
#error "This library requires haxe 3"
#end

/**
	Implement this interface to activate syntax shorteners on the implementing
	class. The type parameter must be one of the following:
		
		- "Lambda": enable argument => expr short lambda
**/
@:autoBuild(_short.Transformer.build())
@:remove
interface Short<Const> { }