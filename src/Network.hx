import CLI.TextStyle.bold;

using haxe.io.Path;

function downloadFile(url:String, ?to:String) {
  final fileName = url.withoutDirectory();

  if (to == null)
    to = fileName;

  Sys.println('${bold('Downloading')} $url to $fileName...');
  Sys.command('curl', [url, '-L', '-o', to]);
  Sys.println(' Done.');
}
