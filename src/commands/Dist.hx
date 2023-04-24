package commands;

import CLI.error;
import Commands.Command;
import OS.appExt;
import OS.copyTree;
import OS.resCliDir;
import OS.wipeDirectory;
import Sys.println;
import commands.Build.build;
import commands.common.PlatformArg.platformArg;
import common.ProjectConfig.getProjectConfig;
import haxe.io.Path;
import sys.FileSystem.*;

using StringTools;

final dist:Command = {
  desc: 'Prepare a package for distribution',
  args: [platformArg],
  func: function(args:Map<String, String>) {
    build.func(args);

    final projectConfig = getProjectConfig();

    createDirectory('dist');

    switch (args['platform']) {
      case 'hl':
        if (exists('dist/hl'))
          wipeDirectory('dist/hl');

        createDirectory('dist/hl');

        println('Copy runtime files...');
        copyTree(Path.join([resCliDir(), 'runtime', 'hashlink']), 'dist/hl', function(path:String):Bool {
          if (path.endsWith('include') || path.endsWith('.lib'))
            return false;
          return true;
        });

        final exeName = appExt('dist/hl/${projectConfig.dist.exeName}');

        rename(appExt('dist/hl/hl'), exeName);

        if (Sys.systemName().toLowerCase() != 'windows')
          Sys.command('chmod +x $exeName');

        println('Copy bytecode');
        copyTree('build/hl', 'dist/hl');

        println('Done: dist/hl');
      case 'js':
        println('Not implemented yet');
      default:
        return error('Unknown platform ${args['platform']}');
    }
  }
};
