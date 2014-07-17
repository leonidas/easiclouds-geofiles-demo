_ = require 'lodash'
$ = require 'jquery'
require 'jquery-ui-draggable'
require 'jquery-ui-droppable'
require 'jquery-ui-resizable'

angular = require 'angular'
ngRoute = require 'angular-route'
require 'angular-leaflet-directive'
require './geofiles/module.coffee'
require './cloud/module.coffee'

L.Icon.Default.imagePath = '/vendor/leaflet/images'

modul = angular.module 'app', ['ngRoute', 'geofiles', 'cloud', 'leaflet-directive']
modul.config ['$locationProvider', '$routeProvider', ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode true
  #$routeProvider.otherwise
  #  redirectTo: '/cloud'
]
