module.exports = ->
	restrict: 		'E'
	replace:     	true
	scope:
		title:    	'@'
		min:  		'@'
		max:  		'@'
		val:  		'@'
	templateUrl: 	'/partials/cloud/templates/sliderFilter.html'
