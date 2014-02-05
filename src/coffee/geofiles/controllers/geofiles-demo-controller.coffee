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
  $scope.paths = {}
  $scope.europeCenter =
    lat: 55.0
    lng: 8.0
    zoom: 4
  $scope.userPosition = {}

  transformMarkers = (m) ->
    indexBy(m, (val) -> val.message.replace(/[. ]/g, ''))

  transformUserPosition = ->
    $scope.markers = _.assign($scope.markers,
      userlocation:
        lat: $scope.userPosition.coords.latitude
        lng: $scope.userPosition.coords.longitude
        message: 'User location'
        icon: {}) if !_.isEmpty($scope.userPosition)

  $scope.getUserLocation = ->
    navigator.geolocation.getCurrentPosition((pos) ->
      $scope.userPosition = pos
      transformUserPosition()) if navigator.geolocation

  $scope.queryFile = ->
    $scope.markers = transformMarkers(_.map(_.omit($scope.markers, 'userlocation'),
      (m) -> _.assign(m, icon: icons.inactive)))
    transformUserPosition()
    $scope.paths = {}
    $http(method: 'GET', url: FILES_API, params: url: $scope.url)
      .success((data, status, headers, config) ->
        $scope.markers = _.assign($scope.markers,
          transformMarkers(_.map(data.servers, (s) ->
            lat: s.coordinates.lat
            lng: s.coordinates.lng
            message: s.hostname
            icon: if _.isEmpty($scope.userPosition) then (if s.active then icons.active else {}) else icons.active)))
        $scope.paths =
          indexBy(_.map(_.filter(data.servers, (s) -> _.identity(s.active)),
            (s) ->
              color: '#008000'
              weiht: 8
              latlngs:
                [
                  lat: s.coordinates.lat
                  lng: s.coordinates.lng
                ,
                  lat: $scope.userPosition.coords.latitude
                  lng: $scope.userPosition.coords.longitude
                ]),
            (p) ->
              "path" + (Math.random() * 1000).toFixed(0).toString()) if !_.isEmpty($scope.userPosition))
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
  $scope.getUserLocation()
]
