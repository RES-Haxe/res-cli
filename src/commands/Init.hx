package commands;

import CLI.error;
import Commands.Command;
import Hxml.writeHxmlFile;
import OS.appExt;
import OS.copyTree;
import common.CliConfig;
import common.ProjectConfig.PROJECT_CONFIG_FILENAME;
import haxe.Exception;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import types.ResProjectConfig;

using StringTools;
using haxe.io.Path;

final RUNTIME_DIR = '.runtime';
final HAXE_DIR = 'haxe';
final HL_DIR = 'hl';

function templateList()
  return FileSystem.readDirectory(Path.join([Sys.programPath().directory(), 'templates']));

final init:Command = {
  desc: 'Initialize a RES project',
  args: [
    {
      name: 'name',
      type: STRING,
      desc: 'Project name',
      defaultValue: null,
      requred: true,
      interactive: true,
      example: 'My Game'
    },
    {
      name: 'dir',
      type: STRING,
      desc: 'Directory to initialize the project in. Use "." to initialize the project in the current directory',
      defaultValue: () -> Sys.getCwd(),
      requred: false,
      interactive: false,
      example: './my_game'
    },
    {
      name: 'platforms',
      type: MULTIPLE(['hl', 'js']),
      desc: 'List of the platforms to initialize. Use a JSON array to list the platforms. Currently available: hl (HashLink), js (JavaScript)',
      defaultValue: () -> Json.stringify(['hl', 'js']),
      requred: false,
      interactive: false,
      example: '["hl"]',
    },
    {
      name: 'template',
      type: ENUM(templateList()),
      desc: 'The name of a template to use to initialize the project. Available templates: ${templateList().join(', ')}',
      defaultValue: () -> 'default',
      requred: false,
      interactive: false,
      example: 'default'
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
