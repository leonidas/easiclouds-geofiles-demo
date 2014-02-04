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
  $scope.url = ''
  $scope.markers =
    'amsterdam.swift.example.com':
      lat: 52.373056
      lng: 4.892222
      message: 'amsterdam.swift.example.com'
  $scope.europeCenter =
    lat: 55.0
    lng: 8.0
    zoom: 4

  $scope.queryFile = ->
    $http(method: 'GET', url: FILES_API, config: params: url: $scope.url)
      .success((data, status, headers, config) ->
                        
      )
      .error((data, status, headers, config) -> console.log("def"))

  $scope.queryServers = ->
    $http(method: 'GET', url: SERVERS_API)
      .success((data, status, headers, config) ->
        $scope.markers = indexBy(_.map(data.servers, (s) ->
          lat: s.coordinates.lat
          lng: s.coordinates.lng
          message: s.hostname
        ), (val) -> val.message)
        console.log($scope.markers)
      )
      .error((data, status, headers, config) -> console.log("def"))


]
