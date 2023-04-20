#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
"$DIR/runtime/haxe/haxe" -cp "$DIR/src" --run Main $@