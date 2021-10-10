package yojimbo;

typedef Native = haxe.macro.MacroType<[webidl.Module.build({ idlFile : "yojimbo.idl",  autoGC : true, nativeLib : "yojimbo" })]>;
