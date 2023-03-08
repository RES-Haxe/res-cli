import CLI.error;
import TermProcess.run;
import sys.io.Process;

var gitCmd:String;
var haxeCmd:String;
var haxelibCmd:String;
var hlCmd:String;

function initTools() {
  function check(cmd:String, args:Array<String>) {
    final proc = new Process(cmd, args);
    final exitCode = proc.exitCode(true);

    if (exitCode != 0)
      error('$cmd command not found');
  }

  gitCmd = 'git';
  haxeCmd = 'haxe';
  haxelibCmd = 'haxelib';
  hlCmd = 'hl';

  check(haxeCmd, ['--version']);
  check(haxelibCmd, ['version']);
  check(hlCmd, ['--version']);
  check(gitCmd, ['--version']);
}

function git(args, ?onData, ?onError, ?printCmd)
  return run(gitCmd, args, onData, onError, printCmd);

function haxe(args, ?onData, ?onError, ?printCmd)
  return run(haxeCmd, args, onData, onError, printCmd);

function haxelib(args, ?onData, ?onError, ?printCmd)
  return run(haxelibCmd, args, onData, onError, printCmd);

function hl(args, ?onData, ?onError, ?printCmd)
  return run(hlCmd, args, onData, onError, printCmd);
