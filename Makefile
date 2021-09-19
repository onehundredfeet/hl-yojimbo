genhl:
	haxe -cp src  -lib hl-idl --macro "yojimbo.Generator.generateCpp()"
	
genjs:
	haxe -cp src -lib hl-idl --macro "yojimbo.Generator.generateJs()"
