package commands;

import CLI.TextStyle.*;
import Commands.Command;
import Commands.commands;
import Sys.println;

using Lambda;

final help:Command = {
  desc: 'RES CLI help',
  args: [
    {
      name: 'cmd',
      type: STRING,
      defaultValue: null,
      requred: false,
      desc: 'Command'
    }
  ],
  func: function(args:Map<String, String>) {
    println('Usage: res [command] [arguments]');
    println('');

    for (cmd => command in commands) {
      function fmtRequired(arg:String, req:Bool):String
        return req ? arg : '[$arg]';

      println('  $cmd${command.args.length > 0 ? ' ' + command.args.map(a -> fmtRequired(italic(a.name), a.requred)).join(' ') : ''}: ${command.desc}'); // This is TOO messy

      if (command.args.length > 0) {
        for (arg in command.args) {
          println('    ${arg.name} - ${arg.desc}');
        }
      }
    }
  }
}
