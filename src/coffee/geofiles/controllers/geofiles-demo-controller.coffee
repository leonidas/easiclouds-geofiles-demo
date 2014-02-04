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
      iconUrl: '../../images/marker-icon-active.png'
    inactive: 
      iconUrl: '../../images/marker-icon-inactive.png'
  $scope.url = 'http://www.leonidasoy.fi'
  $scope.markers = {}
  $scope.europeCenter =
    lat: 55.0
    lng: 8.0
    zoom: 4

  $scope.queryFile = ->
    $http(method: 'GET', url: FILES_API, config: params: url: $scope.url)
      .success((data, status, headers, config) ->
        $scope.markers = _.assign($scope.markers, indexBy(_.map(data.servers, (s) ->
            lat: s.coordinates.lat
            lng: s.coordinates.lng
            message: s.hostname
            icon: if s.active then icons.active else {}),
        (val) -> val.message.replace(/\./g, '')))
        )
      .error((data, status, headers, config) -> console.log("def"))

  $scope.queryServers = ->
    $http(method: 'GET', url: SERVERS_API)
      .success((data, status, headers, config) ->
        $scope.markers = indexBy(_.map(data.servers, (s) ->
          lat: s.coordinates.lat
          lng: s.coordinates.lng
          message: s.hostname
          icon: icons.inactive
        ), (val) -> val.message.replace(/\./g, '')))
      .error((data, status, headers, config) -> console.log("def"))

  $scope.queryServers()
]
