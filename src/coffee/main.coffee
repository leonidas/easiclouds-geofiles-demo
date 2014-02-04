angular = require 'angular'
ngRoute = require 'angular-route'

require 'angular-leaflet-directive'

require './geofiles/module.coffee'

modul = angular.module 'app', ['ngRoute', 'geofiles', 'leaflet-directive']
modul.config ['$locationProvider', '$routeProvider', ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode true
  $routeProvider.otherwise
    redirectTo: '/geodemo'
]
