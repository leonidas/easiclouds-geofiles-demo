_ = require 'lodash'
config = require '../../../../config.json'

indexBy = (coll, keyFn) ->
  result = {}
  i = 0
  for val in coll
    result[i] = val
    i++
  result

module.exports = ['$scope', '$routeParams', '$http', ($scope, $routeParams, $http) ->
  $scope.filterSelection = {}
  $scope.filterSelection.memory = 0.5
  $scope.filterSelection.cpucores = 1
  $scope.filterSelection.storage = 0.25
  $scope.filterSelection.simultaneousjobs = 1
  $scope.filterSelection.countrySelections = [
    {name: 'Belgium', selected: true},
    {name: 'England', selected: true},
    {name: 'Finland', selected: true},
    {name: 'France', selected: true},
    {name: 'Germany', selected: true},
    {name: 'Netherlands', selected: true}
  ]
  $scope.filterSelection.servicesSelections = [
    {name: 'MySQL', selected: false},
    {name: 'postgreSQL', selected: false},
    {name: 'MongoDB', selected: false},
    {name: 'Cassandra',  selected: false}
  ]
  $scope.filterSelection.supportSelections = [
    {name: 'Yes', selected: true},
    {name: 'No',  selected: true}
  ]
  $scope.filterSelection.securitySelections = [
    {name: 'Yes', selected: true},
    {name: 'No',  selected: true}
  ]

  $scope.filterSelection.security = "Yes"

  $scope.$watch 'filterSelection', ((val) ->
    console.log $scope.allMarkers
    $scope.filterMarkers()
    ), true

  FILES_API = config.apiUrl + '/files'
  SERVERS_API = config.apiUrl + '/servers'
  $scope.legendWithUser =
    position: 'bottomleft'
    colors: ['#2981ca', '#00cb73', '#646464']
    labels: ['Your location', 'Servers with the file', 'Servers without the file']
  $scope.legendWithoutUser =
    position: 'bottomleft'
    colors: ['#00cb73', '#2981ca', '#646464']
    labels: ['The server serving you the file', 'Servers with the file', 'Servers without the file']

  # TODO: legend is wrong if user denies geolocation, it doesn't update
  # after the map has been loaded
  $scope.legend = if navigator.geolocation then $scope.legendWithUser else $scope.legendWithoutUser

  icons =
    active:
      iconUrl: 'images/marker-icon-active.png'
    inactive:
      iconUrl: 'images/marker-icon-inactive.png'
  $scope.url = 'https://www.leonidasoy.fi'
  $scope.allMarkers = {}
  $scope.markers = {}
  $scope.paths = {}
  $scope.europeCenter =
    lat: 55.0
    lng: 8.0
    zoom: 5
  $scope.userPosition = {}

  transformMarkers = (m) ->
    indexBy(m, (val) -> val.title.replace(/[. ]/g, ''))

  isSelectedCountry = (countryName) ->
    value = false
    for index of $scope.filterSelection.countrySelections
      if ($scope.filterSelection.countrySelections[index].name == countryName) and ($scope.filterSelection.countrySelections[index].selected == true)
        value = true
    value

  transformUserPosition = ->
    $scope.allMarkers = _.assign($scope.allMarkers,
      userlocation:
        lat: $scope.userPosition.coords.latitude
        lng: $scope.userPosition.coords.longitude
        message: 'User location'
        icon: {}) if !_.isEmpty($scope.userPosition)

  $scope.getUserLocation = ->
    navigator.geolocation.getCurrentPosition((pos) ->
      $scope.userPosition = pos
      $scope.legend = $scope.legendWithUser
      transformUserPosition()) if navigator.geolocation

  $scope.queryServers = ->
    $http(method: 'GET', url: SERVERS_API)
      .success((data, status, headers, config) ->
        $scope.allMarkers = transformMarkers(_.map(data.servers, (s) ->
          title: s.title
          memory: s.memory
          cpucores: s.cpucores
          storage: s.storage
          storage: s.storage
          simultaneousjobs: s.simultaneousjobs
          country: s.location
          lat: s.coordinates.lat
          lng: s.coordinates.lng
          message: "<h3>" + s.title + "</h3>" + s.memory + 'Gb RAM<br/>' + s.cpucores + ' CPU cores<br/>' + s.storage + 'Gb storage<br/><button id=\'chooseButton\'>CHOOSE</button>'
          icon: icons.inactive))
        $scope.markers=$scope.allMarkers
        )

  $scope.filterMarkers = ->
    $scope.markers = {}
    for key, value of $scope.allMarkers
      #if isSelectedCountry(value.country)
        if (value.memory >= $scope.filterSelection.memory) and (value.cpucores >= $scope.filterSelection.cpucores) and (value.storage >= $scope.filterSelection.storage)
          $scope.markers[key] = value

  $scope.queryServers()
  $scope.getUserLocation()
]
