import Bios.bios;
import res.RES;
import res.rom.Rom;

using Std;

function main() {
  RES.boot(bios, {
    resolution: [128, 128],
    rom: Rom.embed(),
    main: (res) -> {
      return {
        update: function(dt) {},
        render: function(fb) {
          fb.clear();
        }
      }
    }
  });
}
