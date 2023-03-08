package common;

import CLI.error;
import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import types.ResProjectConfig.PlatformId;

using Reflect;

function getCoreDeps() {
  final coreDepsFile = Path.join([Path.directory(Sys.programPath()), 'coreDeps.json']);

  if (!FileSystem.exists(coreDepsFile))
    error('coreDeps.json file not found ($coreDepsFile)');

  final jsonData:Dynamic<String> = Json.parse(File.getContent(coreDepsFile));

  final dependencies:Map<PlatformId, Array<Array<String>>> = [];
  for (platformId in jsonData.fields()) {
    if (['*', 'js', 'hl'].indexOf(platformId) == -1)
      continue;

    dependencies[cast platformId] = jsonData.field(platformId);
  }

  return dependencies;
}
