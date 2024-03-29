import Sys.command;
import haxe.io.Path;
import sys.io.File;

using sys.FileSystem;

/**
  Get home directory
**/
function getHomeDir() {
  if (Sys.systemName() == "Windows")
    return Sys.getEnv('USERPROFILE');

  return Sys.getEnv('HOME');
}

/**
  Copy file tree
**/
function copyTree(from:String, to:String, verbose:Bool = false, ?shouldCopy:String->Bool) {
  if (from.isDirectory()) {
    if (verbose)
      Sys.println('D $from -> $to');
    to.createDirectory();

    for (item in from.readDirectory()) {
      final itemPath = Path.join([from, item]);
      if (shouldCopy != null && !shouldCopy(itemPath))
        continue;
      copyTree(itemPath, Path.join([to, item]));
    }
  } else {
    if (verbose)
      Sys.println('F $from -> $to');
    File.copy(from, to);
  }
}

/**
  Delete a non-empty directory
**/
function wipeDirectory(dirPath:String) {
  if (!FileSystem.exists(dirPath))
    return;

  if (!FileSystem.isDirectory(dirPath))
    return;

  if (Sys.systemName() == 'Windows') {
    for (item in dirPath.readDirectory()) {
      final path = Path.join([dirPath, item]);

      if (FileSystem.isDirectory(path)) {
        wipeDirectory(path);
        FileSystem.deleteDirectory(path);
      } else
        FileSystem.deleteFile(path);
    }
  } else
    command('rm', ['-rf', dirPath]);
}

/**
  Extract archive
**/
function extractArchive(archive:String, dest:String)
  command('tar', ['-xf', archive, '-C', dest]);

function appExt(name:String)
  return Sys.systemName().toLowerCase() == 'windows' ? '$name.exe' : name;

function relativizePath(basePath:String, path:String):String {
  final baseParts = Path.normalize(basePath).split('/');
  final pathParts = Path.normalize(path).split('/');

  final result:Array<String> = [];

  while (baseParts[0] == pathParts[0]) {
    baseParts.shift();
    pathParts.shift();
  }

  for (_ in baseParts)
    result.push('..');

  for (part in pathParts)
    result.push(part);

  return result.join('/');
}

function resCliDir()
  #if interp
  return Path.normalize('${Path.directory(Sys.programPath())}/..');
  #else
  return Path.directory(Sys.programPath());
  #end
