import Sys.print;
import Sys.println;
import haxe.Json;

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
  MULTIPLE(values:Array<String>);
}

typedef Argument = {
  ?name:String,
  desc:String,
  requred:Bool,
  interactive:Bool,
  ?defaultValue:Void->String,
  type:ArgType,
  ?validator:(value:String) -> {result: Bool, msg: String}
};

inline function wrap(x, w)
  return x < 0 ? w + (x % w) : x >= w ? x % w : x;

function selectionMenu(values:Array<String>, ?preselected:Array<String>, ?multiple:Bool = true) {
  final selected:Array<String> = preselected != null ? preselected : [];
  var itemIndex:Int = 0;

  final BO = multiple ? '[' : '(';
  final BC = multiple ? ']' : ')';
  final BU = multiple ? 'x' : '*';
  final instructions = (() -> {
    final parts = ['[up]/[down]: choose'];
    if (multiple)
      parts.push('[space]: select/deselect');
    parts.push('[enter]: done');
    parts.push('[q]: quit');
    return parts.join(', ');
  })();

  final setSingle = function() {
    if (multiple)
      return;
    final val = values[itemIndex];
    if (selected.length == 0)
      selected.push(val);
    else
      selected[0] = val;
  };

  while (true) {
    for (n in 0...values.length) {
      final val = values[n];
      final isSelected = selected.indexOf(val) != -1;
      final current = n == itemIndex;
      println('${current ? '>' : ' '} ${BO}${isSelected ? BU : current ? '_' : ' '}${BC} $val');
    }

    println(instructions);
    final char = Sys.getChar(false);

    switch (char) {
      case 13:
        break;
      case 32:
        if (multiple) {
          final val = values[itemIndex];
          final idx = selected.indexOf(val);
          if (idx == -1)
            selected.push(val);
          else
            selected.splice(idx, 1);
        }
      case 65 | 66:
        itemIndex = wrap(itemIndex + (char == 65 ? -1 : 1), values.length);
        setSingle();
      case 113:
        return null;
    }

    for (_ in 0...(values.length + 1))
      print('\033[1A');
  }

  // Preserve the order
  selected.sort((a, b) -> values.indexOf(a) - values.indexOf(b));

  return selected;
}

function ask(arg:Argument):String {
  final defaultAnswer = arg.defaultValue != null ? arg.defaultValue() : null;

  final info = switch arg.type {
    case BOOL:
      defaultAnswer == null ? 'y/n' : defaultAnswer.toLowerCase() == 'y' ? 'Y/n' : 'y/N';
    case ENUM(_):
      null;
    case MULTIPLE(_):
      null;
    case _:
      defaultAnswer;
  };

  print('${arg.desc}${info != null ? ' [$info]' : ''}: ');

  while (true) {
    final result:Null<String> = switch (arg.type) {
      case BOOL:
        final ans = String.fromCharCode(Sys.getChar(true)).toLowerCase();
        println('');
        '${ans == 'y'}';
      case ENUM(values):
        println('');
        final preselect:Array<String> = [defaultAnswer];
        final result = selectionMenu(values, preselect, false);
        if (result == null)
          Sys.exit(0);
        result[0];
      case MULTIPLE(values):
        println('');
        final preselect:Array<String> = Json.parse(defaultAnswer);
        final result = selectionMenu(values, preselect);
        if (result == null)
          Sys.exit(0);
        Json.stringify(result);
      case _:
        final input = Sys.stdin().readLine().trim();
        if (input.length == 0) {
          if (defaultAnswer != null)
            defaultAnswer;
          else
            ask(arg);
        } else input;
    }

    var valResult;
    if (arg.validator == null || (valResult = arg.validator(result)).result)
      return result;
    else
      println(valResult.msg);
  }

  return null;
}

function getArguments(args:Array<String>, expect:Array<Argument>):Map<String, String> {
  final result:Map<String, String> = [];

  for (nArg in 0...expect.length) {
    result[expect[nArg].name] = if (nArg >= args.length) {
      final arg = expect[nArg];
      if (arg.requred) {
        if (arg.interactive)
          ask(arg);
        else
          arg.defaultValue();
      } else
        null;
    } else {
      args[nArg];
    }
  }

  return result;
}

function printTable(rows:Array<Array<String>>, gap:Int = 1, separator:String = '', useHeaders:Bool = false) {
  if (rows.length == 0)
    return;

  final col_num = rows[0].length;

  for (row in rows)
    if (row.length != col_num)
      throw "All rows must have the same amount of columns";

  final max_lengths:Array<Int> = [for (_ in 0...col_num) 0];

  for (row in rows) {
    for (n_col => col in row) {
      max_lengths[n_col] = Std.int(Math.max(col.length, max_lengths[n_col]));
    }
  }

  if (useHeaders) {
    rows.insert(1, [for (n in 0...col_num) ''.rpad('-', max_lengths[n])]);
  }

  for (row in rows) {
    for (n_col => col in row) {
      print('${col.rpad(' ', max_lengths[n_col])}${n_col < row.length - 1 ? separator : ''}${''.lpad(' ', gap)}');
    }
    print('\n');
  }
}

function error(message:String) {
  Sys.stderr().writeString('Error: $message\n');
  Sys.exit(1);
}
