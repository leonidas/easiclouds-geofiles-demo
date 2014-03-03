module.exports = ->
	restrict:  'E'
	replace: true
	scope:
    title: '@'
    selections: '='
	templateUrl: '/partials/cloud/templates/checkBoxFilter2.html'

link: (scope) ->
  scope.$watch 'selections', (val) ->
    console.log val
