import CLI.error;
import CLI.getArguments;
import Commands.commands;
import Sys.println;
import Tools.initTools;
import commands.Help.help;

using StringTools;

final VERSION = '0.1.0';

function main() {
  println('RES Command-line tool v$VERSION (${Sys.systemName()})');

  initTools();

  commands['help'] = help;

  final args = Sys.args();

  if (args.length >= 1) {
    final cmdString = args[0].toLowerCase().trim();

    if (commands.exists(cmdString)) {
      final cmd = commands[cmdString];
      final cmdArgs = getArguments(args.slice(1), cmd.args);
      cmd.func(cmdArgs);
    } else
      error('Unknown command: $cmdString');
  } else
    commands['help'].func([]);
}
