genhl:
	haxe -lib webidl --macro "yojimbo.Generator.generateCpp()"
	
genjs:
	haxe -lib webidl --macro "yojimbo.Generator.generateJs()"
