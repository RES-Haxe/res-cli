package commands;

import CLI.printTable;
import Commands.Command;
import Tools.git;
import Tools.haxe;
import Tools.haxelib;
import Tools.hl;
import Tools.node;
import Tools.npm;

final tools:Command = {
  desc: "Tools Information",
  args: [],
  func: function(args) {
    final allTools = [git, haxe, haxelib, hl, node, npm];

    printTable([['Tool', 'Command', 'Version']].concat([
      for (tl in allTools) {
        [tl.name, tl.cmdPath, tl.available ? tl.version : 'N/A'];
      }
    ]), 1, ' |', true);
  }
};
