import CLI.TextStyle.bold;
import haxe.Exception;
import haxe.Http;
import sys.io.File;

using haxe.io.Path;

function downloadFile(url:String, to:String) {
  final fileName = url.withoutDirectory();
  Sys.print('${bold('Downloading')} $fileName...');

  final toFile = File.write(to);

  function urlDownload(url:String) {
    final http = new Http(url);

    http.onStatus = function(status) {
      if (status == 302)
        urlDownload(http.responseHeaders['Location']);
    };

    http.onBytes = function(bytes) {
      if (bytes.length > 0)
        toFile.writeBytes(bytes, 0, bytes.length);
    };

    http.onError = function(error) {
      throw new Exception(error);
    };

    http.request(false);
  }

  urlDownload(url);

  Sys.println(' Done.');
}
