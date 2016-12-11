
var Module;

if (typeof Module === 'undefined') Module = eval('(function() { try { return Module || {} } catch(e) { return {} } })()');

if (!Module.expectedDataFileDownloads) {
  Module.expectedDataFileDownloads = 0;
  Module.finishedDataFileDownloads = 0;
}
Module.expectedDataFileDownloads++;
(function() {
 var loadPackage = function(metadata) {

    var PACKAGE_PATH;
    if (typeof window === 'object') {
      PACKAGE_PATH = window['encodeURIComponent'](window.location.pathname.toString().substring(0, window.location.pathname.toString().lastIndexOf('/')) + '/');
    } else if (typeof location !== 'undefined') {
      // worker
      PACKAGE_PATH = encodeURIComponent(location.pathname.toString().substring(0, location.pathname.toString().lastIndexOf('/')) + '/');
    } else {
      throw 'using preloaded data can only be done on a web page or in a web worker';
    }
    var PACKAGE_NAME = 'game.data';
    var REMOTE_PACKAGE_BASE = 'game.data';
    if (typeof Module['locateFilePackage'] === 'function' && !Module['locateFile']) {
      Module['locateFile'] = Module['locateFilePackage'];
      Module.printErr('warning: you defined Module.locateFilePackage, that has been renamed to Module.locateFile (using your locateFilePackage for now)');
    }
    var REMOTE_PACKAGE_NAME = typeof Module['locateFile'] === 'function' ?
                              Module['locateFile'](REMOTE_PACKAGE_BASE) :
                              ((Module['filePackagePrefixURL'] || '') + REMOTE_PACKAGE_BASE);
  
    var REMOTE_PACKAGE_SIZE = metadata.remote_package_size;
    var PACKAGE_UUID = metadata.package_uuid;
  
    function fetchRemotePackage(packageName, packageSize, callback, errback) {
      var xhr = new XMLHttpRequest();
      xhr.open('GET', packageName, true);
      xhr.responseType = 'arraybuffer';
      xhr.onprogress = function(event) {
        var url = packageName;
        var size = packageSize;
        if (event.total) size = event.total;
        if (event.loaded) {
          if (!xhr.addedTotal) {
            xhr.addedTotal = true;
            if (!Module.dataFileDownloads) Module.dataFileDownloads = {};
            Module.dataFileDownloads[url] = {
              loaded: event.loaded,
              total: size
            };
          } else {
            Module.dataFileDownloads[url].loaded = event.loaded;
          }
          var total = 0;
          var loaded = 0;
          var num = 0;
          for (var download in Module.dataFileDownloads) {
          var data = Module.dataFileDownloads[download];
            total += data.total;
            loaded += data.loaded;
            num++;
          }
          total = Math.ceil(total * Module.expectedDataFileDownloads/num);
          if (Module['setStatus']) Module['setStatus']('Downloading data... (' + loaded + '/' + total + ')');
        } else if (!Module.dataFileDownloads) {
          if (Module['setStatus']) Module['setStatus']('Downloading data...');
        }
      };
      xhr.onload = function(event) {
        var packageData = xhr.response;
        callback(packageData);
      };
      xhr.send(null);
    };

    function handleError(error) {
      console.error('package error:', error);
    };
  
      var fetched = null, fetchedCallback = null;
      fetchRemotePackage(REMOTE_PACKAGE_NAME, REMOTE_PACKAGE_SIZE, function(data) {
        if (fetchedCallback) {
          fetchedCallback(data);
          fetchedCallback = null;
        } else {
          fetched = data;
        }
      }, handleError);
    
  function runWithFS() {

    function assert(check, msg) {
      if (!check) throw msg + new Error().stack;
    }
Module['FS_createPath']('/', '.git', true, true);
Module['FS_createPath']('/.git', 'co.gitup.mac', true, true);
Module['FS_createPath']('/.git', 'hooks', true, true);
Module['FS_createPath']('/.git', 'info', true, true);
Module['FS_createPath']('/.git', 'logs', true, true);
Module['FS_createPath']('/.git/logs', 'refs', true, true);
Module['FS_createPath']('/.git/logs/refs', 'heads', true, true);
Module['FS_createPath']('/.git', 'objects', true, true);
Module['FS_createPath']('/.git/objects', '05', true, true);
Module['FS_createPath']('/.git/objects', '42', true, true);
Module['FS_createPath']('/.git/objects', '73', true, true);
Module['FS_createPath']('/.git/objects', '7e', true, true);
Module['FS_createPath']('/.git/objects', 'pack', true, true);
Module['FS_createPath']('/.git', 'refs', true, true);
Module['FS_createPath']('/.git/refs', 'heads', true, true);
Module['FS_createPath']('/', 'assets', true, true);
Module['FS_createPath']('/assets', 'fonts', true, true);
Module['FS_createPath']('/assets', 'images', true, true);
Module['FS_createPath']('/assets', 'sounds', true, true);
Module['FS_createPath']('/assets/sounds', 'jumps', true, true);
Module['FS_createPath']('/', 'dist', true, true);
Module['FS_createPath']('/', 'lib', true, true);

    function DataRequest(start, end, crunched, audio) {
      this.start = start;
      this.end = end;
      this.crunched = crunched;
      this.audio = audio;
    }
    DataRequest.prototype = {
      requests: {},
      open: function(mode, name) {
        this.name = name;
        this.requests[name] = this;
        Module['addRunDependency']('fp ' + this.name);
      },
      send: function() {},
      onload: function() {
        var byteArray = this.byteArray.subarray(this.start, this.end);

          this.finish(byteArray);

      },
      finish: function(byteArray) {
        var that = this;

        Module['FS_createDataFile'](this.name, null, byteArray, true, true, true); // canOwn this data in the filesystem, it is a slide into the heap that will never change
        Module['removeRunDependency']('fp ' + that.name);

        this.requests[this.name] = null;
      },
    };

        var files = metadata.files;
        for (i = 0; i < files.length; ++i) {
          new DataRequest(files[i].start, files[i].end, files[i].crunched, files[i].audio).open('GET', files[i].filename);
        }

  
    function processPackageData(arrayBuffer) {
      Module.finishedDataFileDownloads++;
      assert(arrayBuffer, 'Loading data file failed.');
      assert(arrayBuffer instanceof ArrayBuffer, 'bad input to processPackageData');
      var byteArray = new Uint8Array(arrayBuffer);
      var curr;
      
        // copy the entire loaded file into a spot in the heap. Files will refer to slices in that. They cannot be freed though
        // (we may be allocating before malloc is ready, during startup).
        if (Module['SPLIT_MEMORY']) Module.printErr('warning: you should run the file packager with --no-heap-copy when SPLIT_MEMORY is used, otherwise copying into the heap may fail due to the splitting');
        var ptr = Module['getMemory'](byteArray.length);
        Module['HEAPU8'].set(byteArray, ptr);
        DataRequest.prototype.byteArray = Module['HEAPU8'].subarray(ptr, ptr+byteArray.length);
  
          var files = metadata.files;
          for (i = 0; i < files.length; ++i) {
            DataRequest.prototype.requests[files[i].filename].onload();
          }
              Module['removeRunDependency']('datafile_game.data');

    };
    Module['addRunDependency']('datafile_game.data');
  
    if (!Module.preloadResults) Module.preloadResults = {};
  
      Module.preloadResults[PACKAGE_NAME] = {fromCache: false};
      if (fetched) {
        processPackageData(fetched);
        fetched = null;
      } else {
        fetchedCallback = processPackageData;
      }
    
  }
  if (Module['calledRun']) {
    runWithFS();
  } else {
    if (!Module['preRun']) Module['preRun'] = [];
    Module["preRun"].push(runWithFS); // FS is not initialized yet, wait for it
  }

 }
 loadPackage({"files": [{"audio": 0, "start": 0, "crunched": 0, "end": 6148, "filename": "/.DS_Store"}, {"audio": 0, "start": 6148, "crunched": 0, "end": 6159, "filename": "/.gitignore"}, {"audio": 0, "start": 6159, "crunched": 0, "end": 6278, "filename": "/conf.lua"}, {"audio": 0, "start": 6278, "crunched": 0, "end": 6722, "filename": "/corpse.lua"}, {"audio": 0, "start": 6722, "crunched": 0, "end": 24769, "filename": "/LICENSE"}, {"audio": 0, "start": 24769, "crunched": 0, "end": 31101, "filename": "/main.lua"}, {"audio": 0, "start": 31101, "crunched": 0, "end": 33801, "filename": "/player.lua"}, {"audio": 0, "start": 33801, "crunched": 0, "end": 34520, "filename": "/README.md"}, {"audio": 0, "start": 34520, "crunched": 0, "end": 39591, "filename": "/world.lua"}, {"audio": 0, "start": 39591, "crunched": 0, "end": 39827, "filename": "/.git/config"}, {"audio": 0, "start": 39827, "crunched": 0, "end": 39900, "filename": "/.git/description"}, {"audio": 0, "start": 39900, "crunched": 0, "end": 39923, "filename": "/.git/HEAD"}, {"audio": 0, "start": 39923, "crunched": 0, "end": 42582, "filename": "/.git/index"}, {"audio": 0, "start": 42582, "crunched": 0, "end": 42621, "filename": "/.git/packed-refs"}, {"audio": 0, "start": 42621, "crunched": 0, "end": 927357, "filename": "/.git/co.gitup.mac/cache.db"}, {"audio": 0, "start": 927357, "crunched": 0, "end": 960125, "filename": "/.git/co.gitup.mac/cache.db-shm"}, {"audio": 0, "start": 960125, "crunched": 0, "end": 1550413, "filename": "/.git/co.gitup.mac/cache.db-wal"}, {"audio": 0, "start": 1550413, "crunched": 0, "end": 1553650, "filename": "/.git/co.gitup.mac/snapshots.data"}, {"audio": 0, "start": 1553650, "crunched": 0, "end": 1555837, "filename": "/.git/co.gitup.mac/snapshots.data~"}, {"audio": 0, "start": 1555837, "crunched": 0, "end": 1556315, "filename": "/.git/hooks/applypatch-msg.sample"}, {"audio": 0, "start": 1556315, "crunched": 0, "end": 1557211, "filename": "/.git/hooks/commit-msg.sample"}, {"audio": 0, "start": 1557211, "crunched": 0, "end": 1557400, "filename": "/.git/hooks/post-update.sample"}, {"audio": 0, "start": 1557400, "crunched": 0, "end": 1557824, "filename": "/.git/hooks/pre-applypatch.sample"}, {"audio": 0, "start": 1557824, "crunched": 0, "end": 1559466, "filename": "/.git/hooks/pre-commit.sample"}, {"audio": 0, "start": 1559466, "crunched": 0, "end": 1560814, "filename": "/.git/hooks/pre-push.sample"}, {"audio": 0, "start": 1560814, "crunched": 0, "end": 1565765, "filename": "/.git/hooks/pre-rebase.sample"}, {"audio": 0, "start": 1565765, "crunched": 0, "end": 1566309, "filename": "/.git/hooks/pre-receive.sample"}, {"audio": 0, "start": 1566309, "crunched": 0, "end": 1567548, "filename": "/.git/hooks/prepare-commit-msg.sample"}, {"audio": 0, "start": 1567548, "crunched": 0, "end": 1571158, "filename": "/.git/hooks/update.sample"}, {"audio": 0, "start": 1571158, "crunched": 0, "end": 1571398, "filename": "/.git/info/exclude"}, {"audio": 0, "start": 1571398, "crunched": 0, "end": 1571763, "filename": "/.git/logs/HEAD"}, {"audio": 0, "start": 1571763, "crunched": 0, "end": 1572128, "filename": "/.git/logs/refs/heads/master"}, {"audio": 0, "start": 1572128, "crunched": 0, "end": 1572488, "filename": "/.git/objects/05/6e0a74aa5dcd44982fc3844c5a16c8272603a7"}, {"audio": 0, "start": 1572488, "crunched": 0, "end": 1572736, "filename": "/.git/objects/42/3669a9c97c1ca94c1c8a21438df5913d15dd78"}, {"audio": 0, "start": 1572736, "crunched": 0, "end": 1572845, "filename": "/.git/objects/73/96fb2cd2ce1cc4080e798aea2dfebe55a5a8e4"}, {"audio": 0, "start": 1572845, "crunched": 0, "end": 1575096, "filename": "/.git/objects/7e/2553a3cd32cd60251754be84f855e02bf01659"}, {"audio": 0, "start": 1575096, "crunched": 0, "end": 1590196, "filename": "/.git/objects/pack/pack-540b9452a32084995b3493b437d8651927b58aa9.idx"}, {"audio": 0, "start": 1590196, "crunched": 0, "end": 18045048, "filename": "/.git/objects/pack/pack-540b9452a32084995b3493b437d8651927b58aa9.pack"}, {"audio": 0, "start": 18045048, "crunched": 0, "end": 18045089, "filename": "/.git/refs/heads/master"}, {"audio": 0, "start": 18045089, "crunched": 0, "end": 18051237, "filename": "/assets/.DS_Store"}, {"audio": 0, "start": 18051237, "crunched": 0, "end": 18072821, "filename": "/assets/fonts/addstandard.ttf"}, {"audio": 0, "start": 18072821, "crunched": 0, "end": 18074651, "filename": "/assets/images/blood.png"}, {"audio": 0, "start": 18074651, "crunched": 0, "end": 18075336, "filename": "/assets/images/dim.png"}, {"audio": 0, "start": 18075336, "crunched": 0, "end": 18075756, "filename": "/assets/images/dim_queue.png"}, {"audio": 0, "start": 18075756, "crunched": 0, "end": 18086358, "filename": "/assets/images/screenshot.png"}, {"audio": 0, "start": 18086358, "crunched": 0, "end": 18086868, "filename": "/assets/images/title.png"}, {"audio": 1, "start": 18086868, "crunched": 0, "end": 21128931, "filename": "/assets/sounds/invaded_city.mp3"}, {"audio": 1, "start": 21128931, "crunched": 0, "end": 21191951, "filename": "/assets/sounds/splat.wav"}, {"audio": 1, "start": 21191951, "crunched": 0, "end": 21244219, "filename": "/assets/sounds/jumps/jump1.wav"}, {"audio": 1, "start": 21244219, "crunched": 0, "end": 21306471, "filename": "/assets/sounds/jumps/jump2.wav"}, {"audio": 1, "start": 21306471, "crunched": 0, "end": 21372051, "filename": "/assets/sounds/jumps/jump3.wav"}, {"audio": 1, "start": 21372051, "crunched": 0, "end": 21435071, "filename": "/assets/sounds/jumps/jump4.wav"}, {"audio": 1, "start": 21435071, "crunched": 0, "end": 21510635, "filename": "/assets/sounds/jumps/jump5.wav"}, {"audio": 1, "start": 21510635, "crunched": 0, "end": 21602583, "filename": "/assets/sounds/jumps/jump6.wav"}, {"audio": 1, "start": 21602583, "crunched": 0, "end": 21686595, "filename": "/assets/sounds/jumps/jump7.wav"}, {"audio": 0, "start": 21686595, "crunched": 0, "end": 21692743, "filename": "/dist/.DS_Store"}, {"audio": 0, "start": 21692743, "crunched": 0, "end": 29083158, "filename": "/dist/DimJump-macosx-x64_0-1-4.zip"}, {"audio": 0, "start": 29083158, "crunched": 0, "end": 36473404, "filename": "/dist/DimJump-macosx-x64_0-1-5.zip"}, {"audio": 0, "start": 36473404, "crunched": 0, "end": 39989139, "filename": "/dist/DimJump_0-1-4.love"}, {"audio": 0, "start": 39989139, "crunched": 0, "end": 47018356, "filename": "/dist/DimJump_0-1-5.love"}, {"audio": 0, "start": 47018356, "crunched": 0, "end": 47026499, "filename": "/lib/anim8.lua"}, {"audio": 0, "start": 47026499, "crunched": 0, "end": 47054894, "filename": "/lib/fun.lua"}], "remote_package_size": 47054894, "package_uuid": "a723257c-c8ed-45d7-a83d-60d5f4a79607"});

})();
