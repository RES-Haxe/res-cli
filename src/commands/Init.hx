package commands;

import CLI.ask;
import CLI.error;
import Commands.Command;
import Hxml.writeHxmlFile;
import OS.appExt;
import OS.copyTree;
import common.CliConfig;
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
      requred: true,
      interactive: true
    },
    {
      name: 'dir',
      type: STRING,
      desc: 'Project directory',
      defaultValue: () -> Sys.getCwd(),
      requred: true,
      interactive: false
    },
    {
      name: 'platforms',
      type: MULTIPLE(['hl', 'js']),
      desc: 'Platforms to initialize',
      defaultValue: () -> Json.stringify(['hl', 'js']),
      requred: true,
      interactive: false
    },
    {
      name: 'template',
      type: ENUM(FileSystem.readDirectory(Path.join([Path.directory(Sys.programPath()), 'templates']))),
      desc: 'Project template',
      defaultValue: () -> 'default',
      requred: true,
      interactive: false
    }
  ],
  func: function(args:Map<String, String>) {
    final dir = Path.normalize(args['dir']);
    final template = args['template'];

    final templatePath = Path.join([Path.directory(Sys.programPath()), 'templates', template]);

    if (!FileSystem.exists(templatePath))
      return error('Template <$template> not found');

    try {
      FileSystem.createDirectory(dir);
    } catch (error) {
      Sys.println('ERROR: Couldn\'t create a directory: ${error.message}');
      return;
    }

    Sys.setCwd(dir);

    try {
      copyTree(templatePath, dir);

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

      final runtime_path = Path.join([Path.directory(Sys.programPath()), 'runtime']);

      final cliConfig:CliConfig = {
        tools: {
          haxe: Path.join([runtime_path, 'haxe', appExt('haxe')]),
          haxelib: Path.join([runtime_path, 'haxe', appExt('haxelib')]),
          hl: Path.join([runtime_path, 'hashlink', appExt('hl')])
        }
      };

      File.saveContent(CLI_CONFIG_FILENAME, Json.stringify(cliConfig, null, '  '));

      commands.Bootstrap.bootstrap.func([]);
    } catch (error) {
      Sys.println('ERROR: ${error.message}');
      return;
    }
  }
};
