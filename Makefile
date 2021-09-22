genhl:
	haxe -cp generator  -lib hl-idl --macro "yojimbo.Generator.generateCpp()"
	
genjs:
	haxe -cp generator -lib hl-idl --macro "yojimbo.Generator.generateJs()"
