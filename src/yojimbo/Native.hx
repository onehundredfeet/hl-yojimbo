package yojimbo;

typedef Native = haxe.macro.MacroType<[webidl.Module.build({ idlFile : "generator/yojimbo.idl",  autoGC : true, nativeLib : "yojimbo" })]>;
