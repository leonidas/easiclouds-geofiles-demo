angular = require 'angular'
ngRoute = require 'angular-route'

require './geofiles/module.coffee'

modul = angular.module 'app', ['ngRoute', 'geofiles']
modul.config ['$routeProvider', ($routeProvider) ->
  $routeProvider.otherwise
    redirectTo: '/geodemo'
]
