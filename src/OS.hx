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
function copyTree(from:String, to:String, verbose:Bool = false) {
  if (from.isDirectory()) {
    if (verbose)
      Sys.println('D $from -> $to');
    to.createDirectory();

    for (item in from.readDirectory()) {
      copyTree(Path.join([from, item]), Path.join([to, item]));
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

  if (Sys.systemName() == 'Windows')
    command('rmdir', ['/Q', '/S', dirPath]);
  else
    command('rm', ['-rf', dirPath]);
}

/**
  Extract archive
**/
function extractArchive(archive:String, dest:String)
  command('tar', ['-xf', archive, '-C', dest]);

function appExt(name:String)
  return Sys.systemName().toLowerCase() == 'windows' ? '$name.exe' : name;
