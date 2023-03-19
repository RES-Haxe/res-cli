function getHomeDir() {
  if (Sys.systemName() == "Windows")
    return Sys.getEnv('%USERPROFILE%');

  return Sys.getEnv('HOME');
}
