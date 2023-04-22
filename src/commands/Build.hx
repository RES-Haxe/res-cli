package commands;

import Tools.haxe;
import Hxml.writeHxmlFile;
import types.ResProjectConfig.PlatformId;
import CLI.error;
import common.ProjectConfig.getProjectConfig;
import Commands.Command;
import Sys.print;
import Sys.println;

final build:Command = {
  desc: "Build the project",
  args: [
    {
      name: 'platform',
      desc: 'Platform to build the project',
      requred: true,
      defaultValue: (?prev) -> 'hl',
      type: ENUM(['hl', 'js']),
      interactive: true,
      example: 'hl'
    }
  ],
  func: function(args:Map<String, String>) {
    if (['hl', 'js'].indexOf(args['platform']) == -1)
      error('Unsupported platform: "${args['platform']}" (available: hl, js)');
    final platform:PlatformId = cast args['platform'];
    final config = getProjectConfig();

    final hxmlFile = writeHxmlFile(config, platform);

    print('Build: ');
    final exitCode = haxe.run([hxmlFile], (s) -> {}, (err) -> {
      Sys.stderr().writeString('$err\n');
    }, true);
    println('');

    if (exitCode != 0)
      return error('Build failed');
  }
};
