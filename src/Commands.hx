import CLI.Argument;
import commands.Bootstrap.bootstrap;
import commands.Init.init;
import commands.Run.run;
import commands.Tools.tools;

typedef Command = {
  desc:String,
  args:Array<Argument>,
  func:Map<String, String>->Void
};

final commands:Map<String, Command> = ['bootstrap' => bootstrap, 'init' => init, 'run' => run, 'tools' => tools];
