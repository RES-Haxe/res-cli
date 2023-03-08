package commands;

import CLI.error;
import Commands.Command;
import Hxml.writeHxmlFile;
import Sys.print;
import Sys.println;
import Tools.haxe;
import common.Config.getConfig;
import types.ResProjectConfig.PlatformId;

final run:Command = {
  desc: "Run the project",
  args: [
    {
      name: 'platform',
      desc: 'Platform to run the programm',
      requred: true,
      defaultValue: () -> 'hl',
      type: ENUM(['hl', 'js'])
    }
  ],
  func: function(args:Map<String, String>) {
    final config = getConfig();

    if (['hl', 'js'].indexOf(args['platform']) == -1)
      error('Unsupported platform: "${args['platform']}"');

    final platform:PlatformId = cast args['platform'];

    final hxmlFile = writeHxmlFile(config, platform);

    print('Build: ');
    final exitCode = haxe([hxmlFile], (s) -> {}, (err) -> {
      Sys.stderr().writeString('$err\n');
    }, true);
    println('');

    if (exitCode != 0)
      return error('Build failed');

    print('Run: ');

    switch (platform) {
      case hl:
        Tools.hl(['${config.build.path}/hl/hlboot.dat'], true);
      case js:
        Sys.println('TBD');
      case _:
    }

    println('');
  }
}
