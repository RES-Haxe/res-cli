import CLI.TextStyle.*;
import Sys.print;
import Sys.println;

using StringTools;

class TextStyle {
  public static function bold(s:String):String
    return '\033[1m$s\033[0m';

  public static function italic(s:String):String
    return '\033[3m$s\033[0m';
}

enum ArgType {
  STRING;
  INT;
  FLOAT;
  BOOL;
  ENUM(values:Array<String>);
}

typedef Argument = {
  name:String,
  desc:String,
  requred:Bool,
  defaultValue:Void->String,
  type:ArgType
};

function ask(prompt:String, ?defaultAnswer:String, argType:ArgType = STRING):String {
  final info = switch argType {
    case BOOL:
      defaultAnswer == null ? 'y/n' : defaultAnswer.toLowerCase() == 'y' ? 'Y/n' : 'y/N';
    case _:
      defaultAnswer;
  };

  print('${bold(prompt)}${info != null ? ' [$info]' : ''}: ');
  switch (argType) {
    case BOOL:
      final ans = String.fromCharCode(Sys.getChar(true)).toLowerCase();
      println('');
      return '${ans == 'y'}';
    case _:
      final input = Sys.stdin().readLine().trim();
      if (input.length == 0)
        if (defaultAnswer != null)
          return defaultAnswer;
        else
          return ask(prompt, defaultAnswer, argType);
      else
        return input;
  }
}

function getArguments(args:Array<String>, expect:Array<Argument>):Map<String, String> {
  final result:Map<String, String> = [];

  for (nArg in 0...expect.length) {
    result[expect[nArg].name] = if (nArg >= args.length) {
      final arg = expect[nArg];
      if (arg.requred) {
        ask(arg.desc, arg.defaultValue != null ? arg.defaultValue() : null, arg.type);
      } else
        null;
    } else {
      args[nArg];
    }
  }

  return result;
}

function error(message:String) {
  Sys.stderr().writeString('Error: $message\n');
  Sys.exit(1);
}
