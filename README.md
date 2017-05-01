# gnavi.io

Restaurant search command using [Gnavi API](http://api.gnavi.co.jp/api/manual/restsearch/).

## Usage

```sh
$ io gnavi.io --help
restaurant search command.

options:

  -a --area      area S code. See http://api.gnavi.co.jp/api/manual/areasmaster/. (default: AREAS3102)
  -h --help      show help
  -l --location  your location. latitude:longitude (default: 0:0)
  -r --range     search range. 1:300m, 2:500m, 3:1000m, 4:2000m, 5:3000m. (default: 0)
```
