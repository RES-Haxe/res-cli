import CLI.getArguments;
import Commands.commands;
import Sys.println;
import Tools.initTools;
import commands.Help.help;

using StringTools;

final VERSION = '0.1.0';

function main() {
  initTools();

  println('RES Command-line tool v$VERSION');

  commands['help'] = help;

  final args = Sys.args();

  if (args.length >= 1) {
    final cmdString = args[0].toLowerCase().trim();

    if (commands.exists(cmdString)) {
      final cmd = commands[cmdString];
      final cmdArgs = getArguments(args.slice(1), cmd.args);
      cmd.func(cmdArgs);
    } else
      println('Unknown command: $cmdString');
  } else
    commands['help'].func([]);
}
