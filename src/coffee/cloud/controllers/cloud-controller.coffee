_ = require 'lodash'
config = require '../../../../config.json'

#gives indexes for the results
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

  #names of the checkboxselectionGroups
  $scope.checkBoxNames = ["country", "support", "security"]
  $scope.sliderNames = ["memory", "cpucores", "storage", "simultaneousjobs"]

  $scope.filterSelection["serviceSelections"]
  #array for countrynames. Filled dynamically later
  $scope.filterSelection.countrySelections = []

  #array for servicenames. Filled dynamically later
  $scope.filterSelection.serviceSelections = []

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
      #console.log $scope.allMarkers
      filterMarkers()
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
          simultaneousjobs: s.simultaneousjobs
          country: s.location
          services: s.databases
          security: s.security
          support: s.support
          lat: s.coordinates.lat
          lng: s.coordinates.lng
          message: "<h3>" + s.title + "</h3>" + s.memory + 'Gb RAM<br/>' + s.cpucores + ' CPU cores<br/>' + s.storage + 'Gb storage<br/><button id=\'chooseButton\'>CHOOSE</button>'
          icon: icons.inactive
          )
        )
        $scope.markers=$scope.allMarkers
        $scope.filterSelection.countrySelections = collectCountries()
        $scope.filterSelection.serviceSelections = collectServices()
      )

  collectCountries = ->
    countries = []
    for key, marker of $scope.allMarkers
      countries.push({name: marker.country,  selected: true})
    return _.uniq(countries, "name")

  collectServices = ->
    services = []
    for key, marker of $scope.allMarkers
      for key, service of marker.services
        services.push({name: service,  selected: false})
    return _.uniq(services, "name")

  findSelections = (selections) -> _.map(_.where(selections, {selected: true}), "name")

  #filtering markers
  filterMarkers = ->
    $scope.markers = {}
    selectedServices = findSelections($scope.filterSelection.serviceSelections)
    for key, marker of $scope.allMarkers
      if filterBySliders(marker) and filterByCheckBoxes(marker,selectedServices)
        $scope.markers[key] = marker

  #filters based on slidervalues
  filterBySliders = (marker) ->
    _.every($scope.sliderNames, (value, index) ->
      marker[value]>=$scope.filterSelection[value])

  #filters based on checkboxes
  filterByCheckBoxes = (marker,selectedServices) ->
    filterServices(marker.services, selectedServices) and _.every($scope.checkBoxNames, (value, index) ->
      filterOthers(marker[value], value+"Selections"))

  #filter one checkbox (another case :()
  filterServices = (values, selected) ->
    _.difference(selected, values).length==0

  #filter one checkbox
  filterOthers = (value, type) ->
    selecteds = findSelections($scope.filterSelection[type])
    _.contains(selecteds, value)

  $scope.queryServers()
  $scope.getUserLocation()
]
