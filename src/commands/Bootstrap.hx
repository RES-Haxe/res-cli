package commands;

import sys.io.File;
import haxe.Json;
import Tools.npm;
import Tools.node;
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
        var retries = 1;
        while (true) {
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
            final errorMessage = output.pop();

            if (errorMessage.toLowerCase().indexOf('certificate verification failed') != -1) {
              if (retries == 0)
                return error('Certificate error detected again. Apperently the fix did not work...');

              println('Certificate error detected. Attempting to fix it...');
              Sys.command('curl https://lib.haxe.org/p/haxelib/4.0.3/download/ -o -');
              println('Done. Try again...');
              retries--;
            } else {
              println(' Error');
              println('  ${output.pop()}');
              break;
            }
          } else {
            println(' OK');
            break;
          }
        }
      }
    }

    if (npm.available) {
      npm.run(['init', '-y', '--name=${config.name}', '--yes'], (s) -> {}, (s) -> {}, true);
      npm.run(['install', '-D', 'http-server', 'nodemon', 'concurrently'], (s) -> {}, (s) -> {}, true);

      final pkg = Json.parse(File.getContent('./package.json'));

      Reflect.setField(pkg, 'scripts', {
        serve: 'http-server build/js -o',
        start: 'concurrently "npm run watch" "npm run serve"',
        watch: 'nodemon --watch src/**/*.* --exec res build js'
      });

      File.saveContent('./package.json', Json.stringify(pkg, null, '  '));
    }
  }
};
