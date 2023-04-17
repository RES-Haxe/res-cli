package commands;

import CLI.error;
import CLI.printWrapped;
import Commands.Command;
import Commands.commands;
import Sys.print;
import Sys.println;
import haxe.SysTools;

using Lambda;
using StringTools;

final help:Command = {
  desc: 'RES CLI help',
  args: [
    {
      name: 'command',
      type: STRING,
      defaultValue: (?prev) -> null,
      requred: false,
      interactive: false,
      desc: 'Command to show help about. If not specified help for all the commands will be shown',
      example: 'help'
    }
  ],
  func: function(args:Map<String, String>) {
    final arg_command = args['command'];
    final show_only:String = if (arg_command != null) {
        if (!commands.exists(arg_command)) {
          error('Unknown command <${arg_command}>');
          null;
        }

        arg_command;
      } else null;

    println('RES CLI Help:');
    println('');
    println('  Usage: res [command] [arguments]');
    println('');
    println('COMMANDS:');
    println('');

    var longest_param_name:Int = 0;
    for (cmd => command in commands)
      for (arg in command.args)
        if (show_only == null || show_only == cmd)
          longest_param_name = Std.int(Math.max(longest_param_name, arg.name.length));
    final arg_desc_pad = longest_param_name + 7;

    for (cmd => command in commands) {
      if (show_only != null && cmd != show_only)
        continue;
      println('$cmd:');
      printWrapped(command.desc, 2);
      println('');

      if (command.args.length > 0) {
        println('  ARGUMENTS:');

        if (command.args.length > 0) {
          for (arg in command.args) {
            print('    ${arg.name.rpad(' ', longest_param_name)} : ');
            printWrapped('${arg.requred || arg.defaultValue == null ? '' : '[optional] '}${arg.desc}', arg_desc_pad, true);
            if (arg.defaultValue != null && arg.defaultValue() != null)
              printWrapped('Default: ${arg.defaultValue()}', arg_desc_pad);
          }
        }
      }

      println('  EXAMPLE:');
      println('    res $cmd ${command.args.filter(a -> a.example != null).map(a -> a.example).map(a -> Sys.systemName() == 'Windows' ? SysTools.quoteWinArg(a, false) : SysTools.quoteUnixArg(a)).join(' ')}'.rtrim());
      println('');
    }
  }
}
