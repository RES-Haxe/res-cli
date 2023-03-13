import CLI.error;
import TermProcess.run;
import sys.io.Process;

using StringTools;

var gitCmd:String;
var haxeCmd:String;
var haxelibCmd:String;
var hlCmd:String;
var nodeCmd:String;
var npmCmd:String;

function initTools() {
  function check(cmd:String, args:Array<String>) {
    final proc = new Process(cmd, args);
    final output = proc.stdout.readAll().toString().trim();
    final exitCode = proc.exitCode(true);

    if (exitCode != 0)
      error('$cmd command not found');
  }

  gitCmd = 'git';
  haxeCmd = 'haxe';
  haxelibCmd = 'haxelib';
  hlCmd = 'hl';
  nodeCmd = 'node';
  npmCmd = 'npm';

  check(haxeCmd, ['--version']);
  check(haxelibCmd, ['version']);
  check(hlCmd, ['--version']);
  check(gitCmd, ['--version']);
  check(nodeCmd, ['-v']);
  check(npmCmd, ['-v']);
}

function git(args, ?onData, ?onError, ?printCmd)
  return run(gitCmd, args, onData, onError, printCmd);

function haxe(args, ?onData, ?onError, ?printCmd)
  return run(haxeCmd, args, onData, onError, printCmd);

function haxelib(args, ?onData, ?onError, ?printCmd)
  return run(haxelibCmd, args, onData, onError, printCmd);

function hl(args, ?onData, ?onError, ?printCmd)
  return run(hlCmd, args, onData, onError, printCmd);

function node(args, ?onData, ?onError, ?printCmd)
  return run(nodeCmd, args, onData, onError, printCmd);

function npm(args, ?onData, ?onError, ?printCmd)
  return run(npmCmd, args, onData, onError, printCmd);
