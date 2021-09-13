genhl:
	haxe -cp src  -lib webidl --macro "yojimbo.Generator.generateCpp()"
	
genjs:
	haxe -cp src -lib webidl --macro "yojimbo.Generator.generateJs()"
