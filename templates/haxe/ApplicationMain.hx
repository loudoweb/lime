package;


@:access(lime.app.Application)
@:access(lime.utils.AssetLibrary)


@:dox(hide) class ApplicationMain {
	
	
	public static var config:lime.app.Config;
	public static var preloader:lime.app.Preloader;
	
	private static var app:lime.app.Application;
	private static var rootPath:String;
	
	
	public static function main () {
		
		config = {
			
			build: "::meta.buildNumber::",
			company: "::meta.company::",
			file: "::APP_FILE::",
			fps: ::WIN_FPS::,
			name: "::meta.title::",
			orientation: "::WIN_ORIENTATION::",
			packageName: "::meta.packageName::",
import lime.utils.AssetLibrary;
			version: "::meta.version::",
			windows: [
				::foreach windows::
				{
					allowHighDPI: ::allowHighDPI::,
					antialiasing: ::antialiasing::,
					background: ::background::,
					borderless: ::borderless::,
					depthBuffer: ::depthBuffer::,
					display: ::display::,
					fullscreen: ::fullscreen::,
					hardware: ::hardware::,
					height: ::height::,
					hidden: #if munit true #else ::hidden:: #end,
					maximized: ::maximized::,
					minimized: ::minimized::,
					parameters: "::parameters::",
					resizable: ::resizable::,
					stencilBuffer: ::stencilBuffer::,
					title: "::title::",
					vsync: ::vsync::,
					width: ::width::,
					x: ::x::,
					y: ::y::
				},::end::
			]
			
		};
		
		#if (!html5 || munit)
		create ();
		#end
		
	}
	
	
	public static function create ():Void {
		
		ManifestResources.init ();
		
		preloader = new ::if (PRELOADER_NAME != "")::::PRELOADER_NAME::::else::lime.app.Preloader::end:: ();
		
		#if !munit
		app = new ::APP_MAIN:: ();
		app.setPreloader (preloader);
		app.create (config);
		#end
		
		preloader.create (config);
		
		for (library in ManifestResources.preloadLibraries) {
			
			preloader.addLibrary (library);
			
		}
		
		for (name in ManifestResources.preloadLibraryNames) {
			
			preloader.addLibraryName (name);
			
		}
		
		preloader.load ();
		
		start ();
		
	}
	
	
	#if (js && html5)
	@:keep @:expose("::APP_FILE::.embed")
	public static function embed (element:Dynamic, width:Null<Int> = null, height:Null<Int> = null, background:String = null, assetsPrefix:String = null) {
		
		var htmlElement:js.html.Element = null;
		
		if (Std.is (element, String)) {
			
			htmlElement = cast js.Browser.document.getElementById (cast (element, String));
			
		} else if (element == null) {
			
			htmlElement = cast js.Browser.document.createElement ("div");
			
		} else {
			
			htmlElement = cast element;
			
		}
		
		var color = null;
		
		if (background != null && background != "") {
			
			background = StringTools.replace (background, "#", "");
			
			if (background.indexOf ("0x") > -1) {
				
				color = Std.parseInt (background);
				
			} else {
				
				color = Std.parseInt ("0x" + background);
				
			}
			
		}
		
		if (width == null) {
			
			width = 0;
			
		}
		
		if (height == null) {
			
			height = 0;
			
		}
		
		config.windows[0].background = color;
		config.windows[0].element = htmlElement;
		config.windows[0].width = width;
		config.windows[0].height = height;
		config.assetsPrefix = assetsPrefix;
		
		create ();
		
	}
	
	
	@:keep @:expose("lime.embed")
	public static function _embed (element:Dynamic, width:Null<Int> = null, height:Null<Int> = null, background:String = null, assetsPrefix:String = null) {
		
		embed (element, width, height, background, assetsPrefix);
		
	}
	#end
	
	
	public static function start ():Void {
		
		#if !munit
		
		var result = app.exec ();
		
		#if (sys && !ios && !nodejs && !emscripten)
		lime.system.System.exit (result);
		#end
		
		#else
		
		new ::APP_MAIN:: ();
		
		#end
		
	}
	
	
	#if neko
	@:noCompletion @:dox(hide) public static function __init__ () {
		
		// Copy from https://github.com/HaxeFoundation/haxe/blob/development/std/neko/_std/Sys.hx#L164
		// since Sys.programPath () isn't available in __init__
		var sys_program_path = {
			var m = neko.vm.Module.local().name;
			try {
				sys.FileSystem.fullPath(m);
			} catch (e:Dynamic) {
				// maybe the neko module name was supplied without .n extension...
				if (!StringTools.endsWith(m, ".n")) {
					try {
						sys.FileSystem.fullPath(m + ".n");
					} catch (e:Dynamic) {
						m;
					}
				} else {
					m;
				}
			}
		};
		
		var loader = new neko.vm.Loader (untyped $loader);
		loader.addPath (haxe.io.Path.directory (#if (haxe_ver >= 3.3) sys_program_path #else Sys.executablePath () #end));
		loader.addPath ("./");
		loader.addPath ("@executable_path/");
		
	}
	#end
	
	
}