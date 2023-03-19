package commands;

import CLI.TextStyle.*;
import CLI.error;
import Commands.Command;
import Commands.commands;
import Sys.println;

using Lambda;
using StringTools;

final help:Command = {
  desc: 'RES CLI help',
  args: [
    {
      name: 'command',
      type: STRING,
      defaultValue: null,
      requred: false,
      desc: 'Command to show help about. If not specified help for all the commands will be showed'
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

    println(bold('RES CLI Help:'));
    println('');
    println('  Usage: res [command] [arguments]');
    println('');
    println('COMMANDS:');

    var longest_param_name:Int = 0;
    for (cmd => command in commands)
      for (arg in command.args)
        if (show_only == null || show_only == cmd)
          longest_param_name = Std.int(Math.max(longest_param_name, arg.name.length));

    for (cmd => command in commands) {
      if (show_only != null && cmd != show_only)
        continue;
      println('${bold(cmd)}:');
      println('  ${command.desc}');

      if (command.args.length > 0) {
        println('');
        println('  ARGUMENTS:');

        if (command.args.length > 0) {
          for (arg in command.args) {
            println('    ${bold(arg.name.rpad(' ', longest_param_name))} : ${arg.desc}');
          }
        }
      }
    }
  }
}
