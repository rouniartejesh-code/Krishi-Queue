'use strict';
const CACHE = 'krishi-lite-v1';
const FILES = ['lite.html', 'lite.js', 'offline.css'];
self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(FILES.map(file => new URL(file, self.registration.scope).href))));
});
self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key.startsWith('krishi-lite-') && key !== CACHE).map(key => caches.delete(key)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  // Only the public light shell; credentials and API responses never enter it.
  if (event.request.method !== 'GET' || url.origin !== self.location.origin) return;
  const relative = url.href.slice(self.registration.scope.length).split('?')[0];
  if (!FILES.includes(relative)) return;
  event.respondWith(caches.open(CACHE).then(async cache => (await cache.match(new URL(relative, self.registration.scope).href)) || fetch(event.request)));
});
