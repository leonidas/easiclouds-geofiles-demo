_ = require 'lodash'
config = require '../../../../config.json'

module.exports = ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
  FILES_API = config.apiUrl + '/files'
  SERVERS_API = config.apiUrl + '/servers'
  $scope.url = ''
  $scope.markers = {}
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
      .success((data, status, headers, config) -> console.log(data))
      .error((data, status, headers, config) -> console.log("def"))


]
