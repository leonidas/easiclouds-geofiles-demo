_ = require 'lodash'

module.exports = ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
  API_URL = 'http://localhost:9001/api/v1/'
  FILES_API = API_URL + 'files'
  SERVERS_API = API_URL + 'servers'
  $scope.url = ''
  $scope.markers = {}
  $scope.europeCenter =
    lat: 55.0
    lng: 8.0
    zoom: 4

  $scope.queryFile = ->
    $http({method: 'GET', url: FILES_API + '?url=' + $scope.url})
      .success((data, status, headers, config) ->
                
      )
      .error((data, status, headers, config) -> console.log("def"))

  $scope.queryServers = ->
    $http({method: 'GET', url: SERVERS_API + '?url=' + $scope.url})
      .success((data, status, headers, config) -> console.log(data))
      .error((data, status, headers, config) -> console.log("def"))


]
