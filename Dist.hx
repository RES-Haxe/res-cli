import sys.FileSystem;
import sys.io.Process;
import Network.downloadFile;
import OS.appExt;
import OS.copyTree;
import OS.extractArchive;
import OS.wipeDirectory;
import Sys.command;
import Sys.println;
import sys.FileSystem.*;
import sys.io.File.copy;

using StringTools;
using haxe.io.Path;

function main() {
  final sys_name = Sys.systemName().toLowerCase();

  final commit_id = new Process('git', ['rev-parse', 'HEAD']).stdout.readAll().toString().trim();

  println('Wipe ./dist');
  wipeDirectory('dist');

  println('Create ./dist');
  createDirectory('dist');

  println('Copy executable');

  final built_exe = appExt('out/cpp/Main');
  final res_exe = appExt('./dist/res');

  if (FileSystem.exists(built_exe)) {
    copy(built_exe, res_exe);
  } else {
    println('WARNING: File not found <$built_exe>. Creating a Interp package');
    copyTree('./src', './dist/src');
    copy('./res', './dist/res');
  }

  if (sys_name != 'windows')
    Sys.command('chmod', ['+x', res_exe]);

  println('Copy templates');
  createDirectory('dist/templates');
  copyTree('./templates', 'dist/templates');

  println('Copy coreDeps.json');
  copy('./coreDeps.json', 'dist/coreDeps.json');

  final platform:{haxe:String, hl:String, neko:String} = switch sys_name {
    case 'windows':
      {haxe: 'win64.zip', hl: 'win64.zip', neko: 'win64.zip'};
    case 'linux':
      {haxe: 'linux64.tar.gz', hl: 'linux-amd64.tar.gz', neko: 'linux64.tar.gz'};
    case 'mac':
      {haxe: 'osx.tar.gz', hl: 'darwin.tar.gz', neko: 'osx64.tar.gz'};
    default: throw 'Unsuppored platform';
  }

  final neko_url = 'https://github.com/HaxeFoundation/neko/releases/download/v2-3-0/neko-2.3.0-${platform.neko}';
  final neko_archive = neko_url.withoutDirectory();

  if (!exists(neko_archive))
    downloadFile(neko_url, neko_archive);

  final haxe_url = 'https://github.com/HaxeFoundation/haxe/releases/download/4.2.5/haxe-4.2.5-${platform.haxe}';
  final haxe_archive = haxe_url.withoutDirectory();

  if (!exists(haxe_archive))
    downloadFile(haxe_url, haxe_archive);

  final hl_url = 'https://github.com/HaxeFoundation/hashlink/releases/download/latest/hashlink-2206f8c-${platform.hl}';
  final hl_archive = hl_url.withoutDirectory();

  if (!exists(hl_archive))
    downloadFile(hl_url, hl_archive);

  createDirectory('dist/runtime');

  extractArchive(neko_archive, './dist/runtime');
  extractArchive(haxe_archive, './dist/runtime');
  extractArchive(hl_archive, './dist/runtime');

  for (dir in readDirectory('./dist/runtime')) {
    if (dir.startsWith('neko'))
      rename('./dist/runtime/$dir', './dist/runtime/neko');
    else if (dir.startsWith('haxe'))
      rename('./dist/runtime/$dir', './dist/runtime/haxe');
    else if (dir.startsWith('hashlink'))
      rename('./dist/runtime/$dir', './dist/runtime/hashlink');
  }

  final archive_name = 'res-cli-${commit_id.substr(0, 7)}-${sys_name}.${sys_name == 'windows' ? 'zip' : 'tar.gz'}'.toLowerCase();

  println('Create archive: $archive_name');

  if (sys_name == 'windows') {
    command('powershell', [
      'Compress-Archive',
      '-Path',
      './dist/*',
      '-DestinationPath',
      archive_name,
      '-CompressionLevel',
      'Optimal'
    ]);
  } else {
    Sys.setCwd('dist');
    command('tar', ['-czf', '../$archive_name', '.']);
  }
}
