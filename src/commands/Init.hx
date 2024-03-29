package commands;

import CLI.ask;
import CLI.error;
import Commands.Command;
import Hxml.writeHxmlFile;
import OS.appExt;
import OS.copyTree;
import OS.relativizePath;
import OS.resCliDir;
import Sys.println;
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
  return FileSystem.readDirectory(Path.join([resCliDir(), 'templates']));

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
      defaultValue: (?prev) -> Path.join([Sys.getCwd(), prev != null ? prev['name'] : 'project-name']),
      requred: false,
      interactive: false,
      example: './my_game'
    },
    {
      name: 'platforms',
      type: MULTIPLE(['hl', 'js']),
      desc: 'List of the platforms to initialize. Use a JSON array to list the platforms. Currently available: hl (HashLink), js (JavaScript)',
      defaultValue: (?prev) -> Json.stringify(['hl', 'js']),
      requred: false,
      interactive: false,
      example: '["hl"]',
    },
    {
      name: 'template',
      type: ENUM(templateList()),
      desc: 'The name of a template to use to initialize the project. Available templates: ${templateList().join(', ')}',
      defaultValue: (?prev) -> 'default',
      requred: false,
      interactive: false,
      example: 'default'
    }
  ],
  func: function(args:Map<String, String>) {
    final dir = Path.normalize(Path.isAbsolute(args['dir']) ? args['dir'] : Path.join([Sys.getCwd(), args['dir']]));

    if (!FileSystem.exists(dir)) {
      try {
        FileSystem.createDirectory(dir);
      } catch (error) {
        return CLI.error(error.message);
      }
    }

    if (FileSystem.readDirectory(dir).length > 0) {
      if (ask({
        desc: 'Directory $dir is not empty. Are you sure you want to proceed?',
        type: BOOL,
        requred: true,
        interactive: true,
        defaultValue: (?prev) -> 'false'
      }) == 'false')
        Sys.exit(0);
    }

    final template = args['template'];

    final templatePath = Path.join([resCliDir(), 'templates', template]);

    if (!FileSystem.exists(templatePath))
      return error('Template <$template> not found');

    final currentDir = Path.normalize(Sys.getCwd());
    Sys.setCwd(dir);

    println('Initializing a RES project in: $dir...');

    try {
      copyTree(templatePath, '.');

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

      final runtime_path = Path.join([resCliDir(), 'runtime']);

      final cliConfig:CliConfig = {
        tools: {
          haxe: Path.join([runtime_path, 'haxe', appExt('haxe')]),
          haxelib: Path.join([runtime_path, 'haxe', appExt('haxelib')]),
          hl: Path.join([runtime_path, 'hashlink', appExt('hl')])
        }
      };

      File.saveContent(CLI_CONFIG_FILENAME, Json.stringify(cliConfig, null, '  '));

      commands.Bootstrap.bootstrap.func([]);

      println('Done! Now you can test the newly created project by running:');
      if (currentDir != dir)
        println('  cd ${relativizePath(currentDir, dir)}');
      println('  res run');
    } catch (error) {
      return CLI.error('ERROR: ${error.message}');
    }
  }
};
