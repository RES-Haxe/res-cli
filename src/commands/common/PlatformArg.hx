package commands.common;

import CLI.Argument;

final platformArg:Argument = {
  name: 'platform',
  desc: 'Platform identificator',
  requred: true,
  defaultValue: (?prev) -> 'hl',
  type: ENUM(['hl', 'js']),
  interactive: false,
  example: 'hl'
};
