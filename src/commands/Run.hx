package commands;

import commands.Build.build;
import CLI.error;
import Commands.Command;
import Hxml.writeHxmlFile;
import Sys.print;
import Sys.println;
import Tools.haxe;
import Tools.npm;
import common.ProjectConfig.getProjectConfig;
import haxe.zip.Tools;
import types.ResProjectConfig.PlatformId;

final run:Command = {
  desc: "Run the project",
  args: [
    {
      name: 'platform',
      desc: 'Platform to run the programm',
      requred: true,
      defaultValue: (?prev) -> 'hl',
      type: ENUM(['hl', 'js']),
      interactive: false,
      example: 'hl'
    }
  ],
  func: function(args:Map<String, String>) {
    build.func(args);

    final platform:PlatformId = cast args['platform'];
    final config = getProjectConfig();

    print('Run: ');

    switch (platform) {
      case hl:
        if (!Tools.hl.available)
          return error('${Tools.hl.name} is not available');

        Tools.hl.run(['${config.build.path}/hl/hlboot.dat'], true);
      case js:
        if (!Tools.node.available)
          return error('${Tools.node.name} is not available');
        npm.run(['start'], (s) -> println(s), (s) -> println(s), true);
      case _:
    }

    println('');
  }
}
