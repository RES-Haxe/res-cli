package commands;

import CLI.TextStyle.*;
import CLI.ask;
import CLI.error;
import Commands.Command;
import Hxml.writeHxmlFile;
import common.ProjectConfig.PROJECT_CONFIG_FILENAME;
import haxe.Exception;
import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import types.ResProjectConfig;

using StringTools;

final RUNTIME_DIR = '.runtime';
final HAXE_DIR = 'haxe';
final HL_DIR = 'hl';

final init:Command = {
  desc: 'Initialize a RES project',
  args: [
    {
      name: 'name',
      type: STRING,
      desc: 'Project name',
      defaultValue: null,
      requred: true
    },
    {
      name: 'dir',
      type: STRING,
      desc: 'Project directory',
      defaultValue: () -> Sys.getCwd(),
      requred: true
    },
    {
      name: 'platforms',
      type: MULTIPLE(['hl', 'js']),
      desc: 'Platforms to initialize',
      defaultValue: () -> Json.stringify(['hl', 'js']),
      requred: true
    },
    {
      name: 'template',
      type: ENUM(FileSystem.readDirectory(Path.join([Path.directory(Sys.programPath()), 'templates']))),
      desc: 'Project template',
      defaultValue: () -> 'default',
      requred: true
    }
  ],
  func: function(args:Map<String, String>) {
    final dir = Path.normalize(args['dir']);
    final template = args['template'];

    final templatePath = Path.join([Path.directory(Sys.programPath()), 'templates', template]);

    if (!FileSystem.exists(templatePath))
      return error('Template <$template> not found');

    final confirm = ask({
      desc: 'Initialize a project in $dir',
      defaultValue: () -> 'n',
      type: BOOL,
      requred: true,
    });

    if (confirm != 'true')
      return;

    try {
      FileSystem.createDirectory(dir);
    } catch (error) {
      Sys.println('${bold('ERROR')}: Couldn\'t create a directory: ${error.message}');
      return;
    }

    Sys.setCwd(dir);

    try {
      if (Sys.command('cp', ['-a', '$templatePath/.', '.']) != 0)
        return error('Failed to copy the template');

      final projectConfig:ResProjectConfig = {
        name: args['name'],
        version: '0.1.0',
        src: {
          path: './src',
          main: 'Main'
        },
        build: {
          path: './build'
        },
        dist: {
          path: './dist',
          exeName: 'game'
        },
        libs: [_all => [], hl => [], js => []]
      };

      for (platform in [hl, js])
        writeHxmlFile(projectConfig, platform);

      File.saveContent(PROJECT_CONFIG_FILENAME, Json.stringify(projectConfig, null, '  '));

      commands.Bootstrap.bootstrap.func([]);
    } catch (error) {
      Sys.println('${bold('ERROR:')} ${error.message}');
      return;
    }
  }
};
