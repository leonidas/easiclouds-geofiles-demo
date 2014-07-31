angular = require 'angular'
require 'angular-leaflet-directive'
require './geofiles/module.coffee'
require './cloud/module.coffee'

L.Icon.Default.imagePath = '/vendor/leaflet/images'

modul = angular.module 'app', ['geofiles', 'cloud', 'leaflet-directive']
modul.config ['$locationProvider', '$routeProvider', ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode true
  #$routeProvider.otherwise
  #  redirectTo: '/cloud'
]
