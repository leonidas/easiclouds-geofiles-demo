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

module.exports = ['$scope', '$compile','$routeParams', '$http', ($scope, $compile, $routeParams, $http) ->
  #parameters can easily be printed by:
  #?field1=value1&field2=value2&field3=value3
  console.log($routeParams)
  $scope.filterSelection = {}
  $scope.filterSelection.memory = 0.5
  $scope.filterSelection.cpucores = 1
  $scope.filterSelection.storage = 0.25
  $scope.filterSelection.simultaneousjobs = 1

  #names of the checkboxselectionGroups
  $scope.checkBoxNamesShowSelecteds = ["country"]
  $scope.checkBoxNamesFilterSelecteds = ["services", "support", "security"]

  $scope.sliderNames = ["memory", "cpucores", "storage", "simultaneousjobs"]

  $scope.filterSelection["servicesSelections"]

  $scope.filterSelection.security = "Yes"

  $scope.$watch 'filterSelection', ((val) ->
      filterMarkers()
    ), true

  FILES_API = config.apiUrl + '/files'
  SERVERS_API = config.apiUrl + '/servers'
  MESSAGE_TEMPLATE_API = config.apiUrl + '/partials/cloud/templates/markerTemplate.html'

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

          #slider-filter(title='Maximum simultaneous jobs', min=1, step=1, max=64, val='filterSelection.simultaneousjobs', unit='', class='maximum-sim-jobs')

  $scope.queryServers = ->
    $http(method: 'GET', url: '/partials/cloud/templates/markerTemplate.html')
      .success((data, status, headers, config) ->
        $scope.markerHtml = data
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
              message: createMessage(s)
              icon: icons.inactive
              hostname: s.hostname
              )
            )
            $scope.markers=$scope.allMarkers
            $scope.filterSelection.servicesSelections = collectArrays("services",false)
            $scope.filterSelection.countrySelections = collectValues("country",true)
            $scope.filterSelection.securitySelections = collectArrays("security",false)
            $scope.filterSelection.supportSelections = collectArrays("support",false)
          )
        )

  pattern = (text) -> "Text: #{text}"

  createMessage = (s) ->
    compiled = _.template $scope.markerHtml
    compiled(s)

  collectValues = (filter,makeSelected) ->
    values = []
    for index, marker of $scope.allMarkers
      if marker[filter].length>0
        values.push({name: marker[filter],  selected: makeSelected})
    return _.uniq(values, "name")

  collectArrays = (filter,makeSelected) ->
    values = []
    for key, marker of $scope.allMarkers
      for key, name of marker[filter]
        values.push({name: name,  selected: makeSelected})
    return _.uniq(values, "name")

  #filtering markers
  filterMarkers = ->
    $scope.markers = {}
    selectedServices = findSelections($scope.filterSelection.servicesSelections)
    for key, marker of $scope.allMarkers
      if filterBySliders(marker) and filterByCheckBoxes(marker,selectedServices)
        $scope.markers[key] = marker

  #filters based on slidervalues
  filterBySliders = (marker) ->
    _.every($scope.sliderNames, (value, index) ->
      marker[value]>=$scope.filterSelection[value])

  #filters based on checkboxes
  filterByCheckBoxes = (marker,selectedServices) ->
    checkBoxFilterSelecteds(marker) and checkBoxShowSelecteds(marker)

  #filters markers pased on selections (like if service is selected, it has to be found from marker)
  checkBoxFilterSelecteds= (marker) ->
    _.every($scope.checkBoxNamesFilterSelecteds, (value) ->
      selectedServices = findSelections($scope.filterSelection[value+"Selections"])
      console.log("")
      console.log(value)
      console.log(marker[value])
      console.log(selectedServices)
      _.difference(selectedServices,marker[value]).length==0
    )
  #shows markers based on selections (like if country is selected, then it is shown)
  checkBoxShowSelecteds= (marker) ->
    _.every($scope.checkBoxNamesShowSelecteds, (value, index) ->
      selecteds = findSelections($scope.filterSelection[value+"Selections"])
      _.contains(selecteds, marker[value]))

  #returns selections that are set as true
  findSelections = (selections) -> _.map(_.where(selections, {selected: true}), "name")

  $scope.queryServers()
  $scope.getUserLocation()
]
