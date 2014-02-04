angular = require 'angular'
ngRoute = require 'angular-route'

require './geofiles/module.coffee'

modul = angular.module 'app', ['ngRoute', 'geofiles']
modul.config ['$locationProvider', '$routeProvider', ($locationProvider, $routeProvider) ->
  $locationProvider.html5Mode true

  $routeProvider.otherwise
    redirectTo: '/geodemo'
]
