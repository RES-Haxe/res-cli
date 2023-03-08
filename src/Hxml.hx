import common.CoreDeps.getCoreDeps;
import sys.io.File;
import types.ResProjectConfig;

function createHaxeArgs(cfg:ResProjectConfig, platform:PlatformId) {
  final result:Array<Array<String>> = [["# This file is generated automatically by the RES CLI tool"]];

  result.push(['-cp', cfg.src.path]);
  result.push(['-main', cfg.src.main]);

  for (dep in cfg.libs[platform]) {
    result.push(['-lib', dep.join(':')]);
  }

  final coreDeps = getCoreDeps();

  for (pl => deps in coreDeps) {
    if ([_all, platform].indexOf(pl) != -1) {
      for (dep in deps)
        result.push(['-lib', dep[0]]);
    }
  }

  result.push(switch (platform) {
    case _all:
      [];
    case hl:
      ['--hl', '${cfg.build.path}/hl/hlboot.dat'];
    case js:
      ['--js', '${cfg.build.path}/js/${cfg.dist.exeName}.js'];
  });

  return result;
}

function writeHxmlFile(cfg:ResProjectConfig, platform:PlatformId) {
  final fileName = 'res.$platform.hxml';
  final fileContent = createHaxeArgs(cfg, platform).map(p -> p.join(' ')).join('\n');
  File.saveContent(fileName, fileContent);
  return fileName;
}
