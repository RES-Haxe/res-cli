import CLI.error;
import OS.appExt;
import common.CliConfig.getCliConfig;
import haxe.io.Path;
import sys.io.Process;

using StringTools;

class Tool {
  public final available:Bool;

  public final name:String;
  public final version:Null<String>;

  public final cmdPath:String;

  final versionArgs:Array<String>;

  public function getVersion():Null<String> {
    try {
      final proc = new Process(cmdPath, versionArgs);
      final output = proc.stdout.readAll().toString().trim();
      final exitCode = proc.exitCode(true);

      if (exitCode != 0)
        return null;

      return output;
    } catch (error) {
      return null;
    }
  }

  public function run(args:Array<String>, ?onData:String->Void, ?onError:String->Void, ?printCmd:Bool) {
    if (!available)
      error('$name is not available!');
    return TermProcess.run(cmdPath, args, onData, onError, printCmd);
  }

  public function new(name:String, cmdPath:String, versionArgs:Array<String>, ?parseVersion:String->String) {
    this.name = name;
    this.cmdPath = cmdPath;
    this.versionArgs = versionArgs;
    this.version = parseVersion != null ? parseVersion(getVersion()) : getVersion();
    this.available = version != null;
  }
}

var git:Tool;
var haxe:Tool;
var haxelib:Tool;
var hl:Tool;
var node:Tool;
var npm:Tool;

function initTools() {
  final cliConfig = getCliConfig();

  function cfgPath(toolName:String, defaultPath:String):String {
    final cfg_path:String = Reflect.field(cliConfig.tools, toolName);

    if (cfg_path != null)
      return cfg_path;

    return defaultPath;
  }

  final runtimePath = Path.join([Path.directory(Sys.programPath()), 'runtime']);

  haxe = new Tool('Haxe Compiler', cfgPath('haxe', '$runtimePath/haxe/${appExt('haxe')}'), ['--version']);
  haxelib = new Tool('Haxelib', cfgPath('haxelib', '$runtimePath/haxe/${appExt('haxelib')}'), ['version']);
  hl = new Tool('HashLink VM', cfgPath('hl', '$runtimePath/hashlink/${appExt('hl')}'), ['--version']);

  if (!(haxe.available && haxelib.available && hl.available)) {
    error('Haxe, Haxelib or HashLink is missing\nPaths used:\n${[haxe.cmdPath, haxelib.cmdPath, hl.cmdPath].join('\n')}');
  }

  git = new Tool('Git', cfgPath('git', 'git'), ['-v'], (v) -> v.replace('git version', '').trim());
  node = new Tool('Node.Js', cfgPath('node', 'node'), ['-v'], (v) -> v.substr(1));
  npm = new Tool('NPM', cfgPath('npm', 'npm'), ['-v']);
}
