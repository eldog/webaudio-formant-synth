Package.describe({
  summary: 'Oscilloscope for web audio',
  version: '0.0.0'
});

Package.onUse(function (api) {
  api.use([
    'coffeescript'
  ]);
  api.addFiles('lib/oscilloscope.coffee', 'client');
});

