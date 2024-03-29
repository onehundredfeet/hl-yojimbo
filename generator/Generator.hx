package;

#if eval
class Generator {
	// Put any necessary includes in this string and they will be added to the generated files
	static var HL_INCLUDE = "
#ifdef _WIN32
#pragma warning(disable:4305)
#pragma warning(disable:4244)
#pragma warning(disable:4316)
#endif

#include <yojimbo/yojimbo.h>
#include \"HashlinkAdapter.h\"
#include \"YojimboHelpers.h\"
#include \"hl_string_helpers.h\"
";

	static var JVM_INCLUDE = "
#include <yojimbo/yojimbo.h>
#include \"YojimboHelpers.h\"
using namespace yojimbo;
";
	static var options = {
		idlFile: "src/yojimbo.idl",
		target: null,
		packageName: "yojimbo",
		nativeLib: "yojimbo",
		outputDir: "src",
		includeCode: null,
		autoGC: true
	};

	public static function generateCpp(target = idl.Options.Target.TargetHL) {
		options.target = target;
		options.includeCode = switch (target) {
			case idl.Options.Target.TargetHL: HL_INCLUDE;
			case idl.Options.Target.TargetJVM: JVM_INCLUDE;
			default: "";
		};
		idl.generator.Generate.generateCpp(options);
	}

	public static function getFiles() {
		var prj = new haxe.xml.Access(Xml.parse(sys.io.File.getContent("yojimbo.vcxproj.filters")).firstElement());
		var sources = [];
		for (i in prj.elements)
			if (i.name == "ItemGroup")
				for (f in i.elements) {
					if (f.name != "ClCompile")
						continue;
					var fname = f.att.Include.split("\\").join("/");
					sources.push(fname);
				}
		return sources;
	}
	/*
		public static function generateJs() {
			// ammo.js params
			var debug = false;
			var defines = debug ? [] : ["NO_EXIT_RUNTIME=1", "NO_FILESYSTEM=1", "AGGRESSIVE_VARIABLE_ELIMINATION=1", "ELIMINATE_DUPLICATE_FUNCTIONS=1", "NO_DYNAMIC_EXECUTION=1"];
			var params = ["-O"+(debug?0:3), "--llvm-lto", "1", "-I", "../../include/yojimbo/src"];
			for( d in defines ) {
				params.push("-s");
				params.push(d);
			}
			idl.Generate.generateJs(options, getFiles(), params);
		}
	 */
}
#end
