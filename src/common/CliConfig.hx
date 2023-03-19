package common;

import CLI.error;
import OS.getHomeDir;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using haxe.io.Path;

typedef CliConfig = {
  tools:{
    ?git:String, ?haxe:String, ?haxelib:String, ?hl:String, ?node:String, ?npm:String
  }
};

final CLI_CONFIG_FILENAME:String = '.res-cli.json';

function getCliConfig():CliConfig {
  final cfg_file_path:Array<String> = [];

  cfg_file_path.push(Sys.getCwd());

  cfg_file_path.push(Path.join([getHomeDir(), '.config', 'res']));
  cfg_file_path.push(Path.join([getHomeDir(), '.config']));

  if (Sys.systemName() != "Windows")
    cfg_file_path.push('/etc/res-cli');

  cfg_file_path.push(Sys.programPath().directory());

  for (path in cfg_file_path) {
    final cfg_filename = Path.join([path, CLI_CONFIG_FILENAME]);

    if (FileSystem.exists(cfg_filename)) {
      try {
        final config:CliConfig = Json.parse(File.getContent(cfg_filename));

        Sys.println('Config loaded: ${cfg_filename}');

        return config;
      } catch (err) {
        error('Failed to parse config file ($cfg_filename): ${err.message}');
      }
      break;
    }
  }

  return {tools: {}};
}
