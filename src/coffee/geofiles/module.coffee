# name it "modul" instead of "module" because of commonjs
modul = angular.module 'geofiles', []
modul.config ['$routeProvider', ($routeProvider) ->
  $routeProvider
    .when '/geodemo',
      # XXX get rid of /templates/
      templateUrl: '/partials/geofiles/templates/demo.html'
      controller:  require './controllers/geofiles-demo-controller.coffee'      
]
