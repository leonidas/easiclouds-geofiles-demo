_ = require 'lodash'
config = require '../../../../config.json'

indexBy = (coll, keyFn) ->
  result = {}
  for val in coll
    bound = _.bind keyFn, val
    key = bound val
    result[key] = val
  result

module.exports = ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
  FILES_API = config.apiUrl + '/files'
  SERVERS_API = config.apiUrl + '/servers'
  icons =
    active:
      iconUrl: 'images/marker-icon-active.png'
    inactive: 
      iconUrl: 'images/marker-icon-inactive.png'
  $scope.url = 'http://www.leonidasoy.fi'
  $scope.markers = {}
  $scope.europeCenter =
    lat: 55.0
    lng: 8.0
    zoom: 4

  transformMarkers = (m) ->
    indexBy(m, (val) -> val.message.replace(/\./g, ''))

  $scope.queryFile = ->
    $scope.markers = transformMarkers(_.map($scope.markers,
      (m) -> _.assign(m, icon: icons.inactive)))
    $http(method: 'GET', url: FILES_API, params: url: $scope.url)
      .success((data, status, headers, config) ->
        $scope.markers = _.assign($scope.markers,
          transformMarkers(_.map(data.servers, (s) ->
            lat: s.coordinates.lat
            lng: s.coordinates.lng
            message: s.hostname
            icon: if s.active then icons.active else {}))))
      .error((data, status, headers, config) -> console.log("def"))

  $scope.queryServers = ->
    $http(method: 'GET', url: SERVERS_API)
      .success((data, status, headers, config) ->
        $scope.markers = transformMarkers(_.map(data.servers, (s) ->
          lat: s.coordinates.lat
          lng: s.coordinates.lng
          message: s.hostname
          icon: icons.inactive)))
      .error((data, status, headers, config) -> console.log("def"))

  $scope.queryServers()
]
