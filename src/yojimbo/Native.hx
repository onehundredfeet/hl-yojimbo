package yojimbo;

typedef Native = haxe.macro.MacroType<[
	idl.Module.build({
		idlFile: "yojimbo.idl",
        #if hl
        target : "hl",
#elseif (java || jvm)
        target : "java",
#else
#error "Unsupported target host"
#end
		packageName: "yojimbo",
		autoGC: true,
		nativeLib: "yojimbo"
	})
]>;
