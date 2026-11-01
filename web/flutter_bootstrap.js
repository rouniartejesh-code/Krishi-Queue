{{flutter_js}}
{{flutter_build_config}}

// Serve the renderer from our own build, avoiding a second CDN connection.
// The light version remains available while the larger app starts.
_flutter.loader.load({
  config: {canvasKitBaseUrl: 'canvaskit/'},
  onEntrypointLoaded: async function(engineInitializer) {
    try {
      const runner = await engineInitializer.initializeEngine({canvasKitBaseUrl: 'canvaskit/'});
      await runner.runApp();
      document.getElementById('welcome')?.setAttribute('hidden', '');
    } catch (error) {
      const status = document.getElementById('load-status');
      if (status) status.textContent = 'ऐप नहीं खुल सका। ऊपर हल्का संस्करण खोलें। / Could not open the app. Use the light version above.';
    }
  }
});
