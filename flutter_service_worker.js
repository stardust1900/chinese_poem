'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "067942986d1ad27c023586df749d1f25",
".git/config": "802130a9399ae6edacea3734b4801b0a",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "cf7dd3ce51958c5f13fece957cc417fb",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "ea587b0fae70333bce92257152996e70",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "b4e77f1dde91e52f1af4ea9efbbc8500",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "91fe75fcdc5742a0343a203e81494da7",
".git/logs/refs/heads/main": "91fe75fcdc5742a0343a203e81494da7",
".git/logs/refs/remotes/origin/main": "c2b6a3cdf145c2cb937b21f66786896b",
".git/objects/04/e5efc15dc0c60ea2ffcc37c5bf25e96689f44d": "978222f47488835b92838c74cb5c684c",
".git/objects/07/eb89fcbebe75c01066c7b66c928598fe9f75e1": "e44795adbad7bba75d6e48ae0f01089c",
".git/objects/08/84b3f605f884b760f7a2d69e5d0522bcbf6a51": "e441e5bf4d38d5dccb3c41ecf9999425",
".git/objects/0d/846c8d4e47a645a373889c8b2c499152924140": "7f8f3bbf2e35701a64b33210abfe6443",
".git/objects/0d/aa3882eff14477bea8c899fe13ab62baebcbc3": "4012ef49edf093a6a38ecba91e27fb5e",
".git/objects/0e/e3590f4d74c3a4e4621a8d048d01f13436ec7a": "25939fd9f3cb53628d90cf3f4f9a026a",
".git/objects/13/2f439644eb8f1657c04089c6b43ccff013cd1a": "0d175c6fa65952d72dd54404389c1916",
".git/objects/20/1afe538261bd7f9a38bed0524669398070d046": "82a4d6c731c1d8cdc48bce3ab3c11172",
".git/objects/2b/e39c7fd3da441ddac9bea54fd12621dd39960a": "24031b20667d22ca8dba4debe8b9eab5",
".git/objects/3a/7795ce82e55d8f9c99e7beaa0c85141f8d2835": "8a5558c663d87709cb2353c1b35642f0",
".git/objects/42/d8dca5d6b557a7c59bce7aab9009d2abdf06c0": "511ff21596046bf9cce356ec5d88296b",
".git/objects/43/e946e398d96aee466fa0aabb625f0889c3a4bd": "ac34520dee747f675e6e0a15c0bbd2be",
".git/objects/43/edf722b9af3b73562b095b2c105113e343a357": "88fb2eb5b2bee7d05461ec208687fe6d",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/46/6c73e5864693c01158addf25568bc72955915e": "e21fec32763dfc7ba24c243d667af7aa",
".git/objects/48/33fcf9ba677d3df448c90e63368e50f8bfc8d6": "a5b926fccf641f8e2a09e52478c0d37a",
".git/objects/4f/d0e51f345ee398d4c56c9a2a36514cfdc54f3e": "d8e976b7b97437231f01681fc40815a3",
".git/objects/53/7807567919e88db2866b7825339c57e94c24d8": "970aec5149a3dbe9370a9dc982cdd022",
".git/objects/54/4eae74c81718c6ef214e5ac5f85fc91b12e950": "36e7c2505cfdd416c37b8fc724ca5f23",
".git/objects/5b/924e9469144e53fcc438165229908941586799": "3ec463aae3ea8b5e1c937932c12eb621",
".git/objects/5e/a1408b7ad860e2650aee807a0801e7ba947fe1": "234a40bc6e8d25851d5b6d0828d1d93c",
".git/objects/5f/086bdd63644473248758e60e47af0a2b9f6859": "79ad50158998d271513ac5d5e87927a3",
".git/objects/6b/0d47720a30dee9a34eb16e62ab9fa0c50a9abf": "b31f2fd8a0979f9061621ba31ea7b1c3",
".git/objects/6c/fd9b2e71ac1be7fdfbc34c52ce570bd9105310": "0cb99cad55f55363fb0f8582234b491b",
".git/objects/94/b52e13bf7919ae4ea7235d78019b592dde8611": "b79fa5ca1cdbf72f253763797850f314",
".git/objects/a4/fe3100b6591864e998148f75376668a1bd0f43": "77d41e69d8b8e47c2b3197e8166a39ad",
".git/objects/a5/a1480bde243bd8f92f9f9ca9352c475e3625e8": "b9e7c3014a9f4d1a4e2f505b98736885",
".git/objects/ac/78f5950b68e560cf1e299fdd6c9d32e9f140d1": "0fabcc9f6b37584815d4b227e6d456df",
".git/objects/b3/948c71cca1ffe00d6a2fe3315a9a3f3facdb3f": "60b4a87a56fbee28569323d6f0745e09",
".git/objects/ba/8cb00dd5231f1a55de0205c16445926a696526": "be8592f9341c9b01b70890c8614c6cf7",
".git/objects/bb/3085876799532613a08c7ebe43f24f0cc46864": "1b6aa21800d948d5513c15e54d131215",
".git/objects/bc/140510b96151b2cb8e543f60a2fa99d77cd336": "e8ba414d1985837bfb2fd19f72df4abf",
".git/objects/bd/5d45930eb47758657f610cd3b32145baf46b08": "056bdff635e59f44d8cab8cdb0ab9d0e",
".git/objects/d7/2c11112c7cb4e2ce754bc41470f9b829a2d00a": "d7280a766a5d6033f187d874a92b5ad6",
".git/objects/d8/169fbd4f743c87bdf07f9bf48190718b7e78dd": "52802e4fe20f2f415f5b7c46a4b4525a",
".git/objects/df/7d2dcb89ab89da87467c0e1059b38c8d8f9296": "a44162ff357b024e4638ab18a9bb01c7",
".git/objects/df/c6169b3363b754d434dd401a6f80c2897585ae": "f3ec8e7b59cbb34ea9a5061a9b544ccb",
".git/objects/e6/b745f90f2a4d1ee873fc396496c110db8ff0f3": "2933b2b2ca80c66b96cf80cd73d4cd16",
".git/objects/e9/c1936dc85c98f30a4f84f2974f73a11f7b1d77": "b2d68cff3072842acaa9b83764fc2c13",
".git/objects/f2/c4546a986437462fff3d92acb6c80bcaf9a3df": "5323dc0e716c23980cd39d53557c50ce",
".git/refs/heads/main": "9f04dd09d2bf8d58acb89f7b957495b9",
".git/refs/remotes/origin/main": "9f04dd09d2bf8d58acb89f7b957495b9",
"assets/asset/datas/chinese_poems.json": "972f379f2b63314c9f4979057fed8c80",
"assets/asset/images/poem.png": "45088c736c5149ee8d8ea1291b03aa8b",
"assets/AssetManifest.bin": "8893e8d51cf257b0bf0220bc034241c6",
"assets/AssetManifest.bin.json": "da0f8ecb5427ee40d88336b36eb3f17f",
"assets/AssetManifest.json": "9ca828c3bc27b07abd7a3c953ecbc9cc",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "748ec37f3f8adf8549037809d341de39",
"assets/NOTICES": "3feef1eefb6d2fee002093f06a627a86",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "bdfbb7ca0c437a5ef54464d769dcff62",
"flutter.js": "59a12ab9d00ae8f8096fffc417b6e84f",
"icons/Icon-192.png": "45088c736c5149ee8d8ea1291b03aa8b",
"icons/Icon-512.png": "a75a4e19a1a62d71c0fd4012c0eab74c",
"icons/Icon-maskable-192.png": "45088c736c5149ee8d8ea1291b03aa8b",
"icons/Icon-maskable-512.png": "a75a4e19a1a62d71c0fd4012c0eab74c",
"index.html": "c6e4d0f53aee494098e97ca0de0680ed",
"/": "c6e4d0f53aee494098e97ca0de0680ed",
"main.dart.js": "d4a87fd763f83fd5ece1769abd17c5c1",
"manifest.json": "2198c26dd383ccc86a7c3a52051c9710",
"version.json": "8eccac49efa0a927a2886ec5627874d5"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
