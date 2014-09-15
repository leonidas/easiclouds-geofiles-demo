_ = require 'lodash'
$ = require 'jquery'

require 'jquery-ui-draggable'
require 'jquery-ui-droppable'
require 'jquery-ui-resizable'
assert = require 'assert'

config = require '../../../../config.json'

#gives indexes for the results
indexBy = (coll, keyFn) ->
  result = {}
  i = 0
  for val in coll
    result[i] = val
    i++
  result

module.exports = ['$scope','$compile','$routeParams', '$http', '$window', ($scope, $compile, $routeParams, $http, $window) ->
  #parameters can easily be printed by:
  #?field1=value1&field2=value2&field3=value3
  $scope.callbackUri = $routeParams["callbackUri"] or "/"
  $scope.filterSelection = {}
  $scope.filterSelection.memory = 0.5
  $scope.filterSelection.cpucores = 1
  $scope.filterSelection.storage = 0.25
  $scope.filterSelection.simultaneousjobs = 1

  #two alternatives if true then all the filtered items are shown in table.
  #Otherwise table is empty at the beginning and items are added there by clicking markers
  #if true then it is a version that Otto Hylli wanted
  #if false then it is a version for Mario
  $scope.showFilteredInTable = true

  #names of the checkboxselectionGroups
  $scope.checkBoxNamesShowSelecteds = ["country"]
  $scope.checkBoxNamesFilterSelecteds = ["databases", "services"]

  $scope.sliderNames = ["memory", "cpucores", "storage", "simultaneousjobs"]

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
  $scope.tableItems = []
  $scope.paths = {}
  $scope.europeCenter =
    lat: 55.0
    lng: 8.0
    zoom: 3
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

  #collects all servers from servers.json file
  $scope.queryServers = ->
    $http(method: 'GET', url: '/partials/cloud/templates/markerTemplate.html')
      .success((data, status, headers, config) ->
        $scope.markerHtml = data
        $http(method: 'GET', url: SERVERS_API)
          .success((data, status, headers, config) ->
            data.servers = _.sortBy data.servers, (o) -> o.title
            $scope.allMarkers = transformMarkers(_.map(data.servers, (s) ->
              id: s.id
              title: s.title
              logourl: s.logourl
              memory: s.memory
              cpucores: s.cpucores
              storage: s.storage
              simultaneousjobs: s.simultaneousjobs
              country: s.location
              databases: s.databases
              services: s.services
              lat: s.coordinates.lat
              lng: s.coordinates.lng
              message: $scope.createMessage(s)
              icon: icons.inactive
              hostname: s.hostname
              callbackParams: s.callbackParams
              )
            )
            $scope.markers=$scope.allMarkers
            if $scope.showFilteredInTable
              $scope.tableItems=$scope.allMarkers
            $scope.filterSelection.countrySelections = collectValues("country",true)
            $scope.filterSelection.databasesSelections = collectArrays("databases",false)
            $scope.filterSelection.servicesSelections = collectArrays("services",false)
          )
        )

  #when any of the markers is clicked then we may want to add clickhandler to it
  $scope.$on 'leafletDirectiveMarker.click', (e, args) ->
    index = args.markerName
    $scope.addButtonHandlers(index)

  #adds buttonhandlers for map markers
  $scope.addButtonHandlers = (index) ->
    console.log index
    console.log $scope.markers[index].id
    indexToNested = index
    button = $( "#button" + $scope.markers[index].id )
    if $scope.showFilteredInTable
      button.hide()
    else
      button.on "click", ->
        #buttons should be hidden if showFilteredInTable = true and this code shoud not be accessed
        #console.log assert
        #test = not $scope.showFilteredInTable
        #console.log test
        #assert.ok test, "should be false in here"
        marker = $scope.markers[indexToNested]
        if ($.inArray(marker, $scope.tableItems) < 0)
          $scope.tableItems.push marker
          $scope.$apply()

  $scope.createMessage = (s) ->
    s.callbackParams = $scope.callbackUri + "?selectedPaas=" + s.hostname + "&PaasName=" + s.title
    compiled = _.template $scope.markerHtml
    return compiled(s)

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
    $scope.markers = []
    if $scope.showFilteredInTable
      $scope.tableItems = []
    for key, marker of $scope.allMarkers
      if filterBySliders(marker) and filterByCheckBoxes(marker)
        $scope.markers.push marker
        if $scope.showFilteredInTable
          $scope.tableItems.push marker

  #filters based on slidervalues
  filterBySliders = (marker) ->
    _.every($scope.sliderNames, (value, index) ->
      marker[value]>=$scope.filterSelection[value])

  #filters based on checkboxes
  filterByCheckBoxes = (marker) ->
    checkBoxFilterSelecteds(marker) and checkBoxShowSelecteds(marker)

  #filters markers pased on selections (like if service is selected, it has to be found from marker)
  checkBoxFilterSelecteds= (marker) ->
    _.every($scope.checkBoxNamesFilterSelecteds, (value) ->
      selected = findSelections($scope.filterSelection[value+"Selections"])
      _.difference(selected,marker[value]).length==0
    )
  #shows markers based on selections (like if country is selected, then it is shown)
  checkBoxShowSelecteds= (marker) ->
    _.every($scope.checkBoxNamesShowSelecteds, (value, index) ->
      selecteds = findSelections($scope.filterSelection[value+"Selections"])
      _.contains(selecteds, marker[value]))

  #returns selections that are set as true
  findSelections = (selections) -> _.map(_.where(selections, {selected: true}), "name")

  $scope.queryServers()
  #$scope.getUserLocation()
  $( "#draggable" ).draggable()
  $( "#draggable" ).resizable()

  $("#checkoutbutton").on 'click', (event) ->
    alert $scope.callbackUri
    alert $scope.tableItems[0].callbackParams
    $window.location.href = $scope.tableItems[0].callbackParams
]
