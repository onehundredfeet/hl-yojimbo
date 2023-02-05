package yojimbo;

typedef Native = haxe.macro.MacroType<[idl.ModuleHL.build({ idlFile : "yojimbo.idl", packageName: "yojimbo", autoGC : true, nativeLib : "yojimbo" })]>;
#elseif (java || jvm)
typedef Native = haxe.macro.MacroType<[idl.ModuleJVM.build({ idlFile : "yojimbo.idl",  packageName: "yojimbo", autoGC : true, nativeLib : "yojimbo" })]>;
#else
#error "Unsupported target host"
#end
