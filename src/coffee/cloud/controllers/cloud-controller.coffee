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
  $scope.checkBoxSelectionGroups = ["countrySelections", "serviceSelections", "supportSelections", "securitySelections"]
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
        addCountries()
        addServices()
      )

  #first version for filtering markers
  filterMarkers = ->
    $scope.markers = {}
    for key, value of $scope.allMarkers
      if filterBySliders(value) and filterByCheckBoxes(value)
        $scope.markers[key] = value

  #filters based on slidervalues
  filterBySliders = (value) ->
    return (value.memory >= $scope.filterSelection.memory) and (value.cpucores >= $scope.filterSelection.cpucores) and (value.storage >= $scope.filterSelection.storage)

  #filters based on checkboxes
  filterByCheckBoxes = (value) ->
    return filterByType(value.country, "countrySelections") and filterByType(value.security, "securitySelections") and filterByType(value.support, "supportSelections") and filterByServices(value.services)

  #filter one checkbox
  filterByType = (value, type) ->
    for index of $scope.filterSelection[type]
      if ($scope.filterSelection[type][index]["name"] == value) and ($scope.filterSelection[type][index].selected == true)
        return true
    return false

  #filter one checkbox (another case :()
  filterByServices = (values) ->
    #incoming values is an array
    for value in values
      #services that are selected from ui
      selectedServices = $scope.filterSelection["serviceSelections"]
      for service of selectedServices
        if (service == value)
          return true
    return false

  addCountries = ->
    for key, value of $scope.allMarkers
      if not filterByType(value.country,"countrySelections")
        newSelection = {name: value.country,  selected: true}
        $scope.filterSelection["countrySelections"].push(newSelection)

  #adds all availlable services to servicelist
  addServices = ->
    for key, marker of $scope.allMarkers
      newservices = marker.services
      oldservices = _.flatten($scope.filterSelection.serviceSelections, "name")
      addservices = _.difference(newservices,oldservices)
      for key, service of addservices
        console.log(addservices)
        newServiceSelection = {name: service,  selected: false}
        $scope.filterSelection.serviceSelections.push(newServiceSelection)

  $scope.queryServers()
  $scope.getUserLocation()
]
