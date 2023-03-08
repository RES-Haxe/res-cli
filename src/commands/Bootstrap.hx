package commands;

import CLI.error;
import Commands.Command;
import Sys.print;
import Sys.println;
import Tools.haxelib;
import common.Config.getConfig;
import common.CoreDeps.getCoreDeps;

using Reflect;

final bootstrap:Command = {
  desc: 'Install all the dependencies',
  args: [],
  func: function(args:Map<String, String>) {
    final config = getConfig();

    final dependencies = getCoreDeps();

    for (platformId => deps in config.libs) {
      for (item in deps)
        dependencies[cast platformId].push(item);
    }

    if (haxelib(['newrepo']) != 0)
      error('Filed to create a local repo');

    for (platformId => deps in dependencies) {
      for (dep in deps) {
        var args = ['install', dep[0]];
        var src = 'haxelib';

        if (dep.length == 3) {
          args = [dep[1], dep[0], dep[2]];
          src = dep[1];
        }

        print('install [$platformId]: ${dep[0]} (${src})');
        if (haxelib(args, (s) -> {}) != 0)
          error(' Failed');
        println(' OK');
      }
    }
  }
};
