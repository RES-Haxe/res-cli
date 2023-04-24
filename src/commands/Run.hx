package commands;

import CLI.error;
import Commands.Command;
import Sys.print;
import Sys.println;
import Tools.npm;
import commands.Build.build;
import commands.common.PlatformArg.platformArg;
import common.ProjectConfig.getProjectConfig;
import haxe.zip.Tools;
import types.ResProjectConfig.PlatformId;

final run:Command = {
  desc: "Run the project",
  args: [
    platformArg
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
