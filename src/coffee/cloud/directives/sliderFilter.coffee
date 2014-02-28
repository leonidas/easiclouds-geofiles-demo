module.exports = ->
  restrict: 		'E'
  replace:     	true
  scope:
    title:  '@'
    min:  '@'
    step: '@'
    max:  '@'
    val:  '='
    unit: '@'
  templateUrl: '/partials/cloud/templates/sliderFilter.html'

