package commands;

import CLI.error;
import Commands.Command;
import Sys.print;
import Sys.println;
import Tools.haxelib;
import common.CoreDeps.getCoreDeps;
import common.ProjectConfig.getProjectConfig;

using Reflect;

final bootstrap:Command = {
  desc: 'Install all the dependencies for the project',
  args: [],
  func: function(args:Map<String, String>) {
    final config = getProjectConfig();

    final dependencies = getCoreDeps();

    for (platformId => deps in config.libs) {
      for (item in deps)
        dependencies[cast platformId].push(item);
    }

    if (haxelib.run(['newrepo']) != 0)
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

        final output:Array<String> = [];

        final exitCode = haxelib.run(args, (s) -> output.push(s), (s) -> output.push(s));

        if (exitCode != 0) {
          println(' Error');
          println('  ${output.pop()}');
        } else
          println(' OK');
      }
    }
  }
};
