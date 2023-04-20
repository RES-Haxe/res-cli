import CLI.error;
import OS.appExt;
import OS.resCliDir;
import Sys.println;
import common.CliConfig.getCliConfig;
import haxe.io.Path;
import sys.io.Process;

using StringTools;

class Tool {
  public final available:Bool;

  public final name:String;
  public final version:Null<String>;

  public final cmdPath:String;

  final verboseVersionCheck:Bool;
  final versionArgs:Array<String>;

  public function getVersion():Null<String> {
    try {
      final proc = new Process(cmdPath, versionArgs);
      final output = proc.stdout.readAll().toString().trim();
      final errorOutput = proc.stderr.readAll().toString().trim();
      final exitCode = proc.exitCode(true);

      if (exitCode != 0) {
        if (verboseVersionCheck) {
          println('$name version check failed');
          println('Command: $cmdPath ${versionArgs.join(' ')}');
          println('stdout: $output');
          println('stderr: $errorOutput');
        }
        return null;
      }

      return output;
    } catch (error) {
      if (verboseVersionCheck) {
        println('$name version check failed with an exception:');
        println(error.message);
      }
      return null;
    }
  }

  public function run(args:Array<String>, ?onData:String->Void, ?onError:String->Void, ?printCmd:Bool) {
    if (!available)
      error('$name is not available!');
    return TermProcess.run(cmdPath, args, onData, onError, printCmd);
  }

  public function new(name:String, cmdPath:String, versionArgs:Array<String>, ?parseVersion:String->String, ?verboseVersionCheck:Bool = false) {
    this.name = name;
    this.cmdPath = cmdPath;
    this.versionArgs = versionArgs;
    this.verboseVersionCheck = verboseVersionCheck;
    final versionCheckResult = getVersion();
    this.version = versionCheckResult != null ? parseVersion != null ? parseVersion(versionCheckResult) : versionCheckResult : null;
    this.available = version != null;
  }
}

var git:Tool;
var neko:Tool;
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

  final runtimePath = Path.join([resCliDir(), 'runtime']);

  final PATH = Sys.getEnv('PATH');
  final paths = [PATH, '$runtimePath/neko', '$runtimePath/haxe', '$runtimePath/hashlink'];

  if (Sys.systemName() == 'Windows') {
    Sys.putEnv('PATH', paths.join(';'));
  } else {
    Sys.putEnv('PATH', paths.join(':'));
  }

  git = new Tool('Git', cfgPath('git', 'git'), ['-v'], (v) -> v.replace('git version', '').trim());

  if (!git.available)
    error('Git is required to run this tool. Please make sure Git is present in the system and available in your PATH\nOfficial Git download page: https://git-scm.com/download');

  neko = new Tool('Neko VM', cfgPath('neko', '$runtimePath/neko/${appExt('neko')}'), ['-version'], true);
  haxe = new Tool('Haxe Compiler', cfgPath('haxe', '$runtimePath/haxe/${appExt('haxe')}'), ['--version'], true);
  haxelib = new Tool('Haxelib', cfgPath('haxelib', '$runtimePath/haxe/${appExt('haxelib')}'), ['version'], true);
  hl = new Tool('HashLink VM', cfgPath('hl', '$runtimePath/hashlink/${appExt('hl')}'), ['--version']);

  if (!(haxe.available && haxelib.available))
    error('Haxe, Haxelib or HashLink is missing');

  node = new Tool('Node.Js', cfgPath('node', 'node'), ['-v'], (v) -> v.substr(1));
  npm = new Tool('NPM', cfgPath('npm', 'npm'), ['-v']);
}
