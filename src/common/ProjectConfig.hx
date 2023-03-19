package common;

import CLI.error;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import types.ResProjectConfig;

using Reflect;

final PROJECT_CONFIG_FILENAME = 'res.json';

function getProjectConfig():ResProjectConfig {
  if (!FileSystem.exists(PROJECT_CONFIG_FILENAME))
    error('${PROJECT_CONFIG_FILENAME} is missing in ${Sys.getCwd()}');

  try {
    final parsedData:Dynamic<String> = Json.parse(File.getContent(PROJECT_CONFIG_FILENAME));
    final result:ResProjectConfig = {
      name: parsedData.field('name'),
      version: parsedData.field('version'),
      src: {
        path: parsedData.field('src').field('path'),
        main: parsedData.field('src').field('main')
      },
      build: {
        path: parsedData.field('build').field('path')
      },
      dist: {
        path: parsedData.field('dist').field('path'),
        exeName: parsedData.field('dist').field('exeName'),
      },
      libs: [_all => [], js => [], hl => []]
    };

    for (platform in parsedData.field('libs').fields())
      result.libs[cast platform] = parsedData.field('libs').field(platform);

    return result;
  } catch (err) {
    error('Config file parsing error: ${err}');
    return null;
  }
}
