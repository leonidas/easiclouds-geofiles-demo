module.exports = ->
  restrict:  'E'
  replace: true
  scope:
    selections: '='
  templateUrl: '/partials/cloud/templates/selectionsDiv.html'

  link: (scope) ->
    scope.fixHeight = ->         
      max_height =  $( "#map" ).height() * 0.9
      current_height = $( "#draggable" ).height()
      if current_height>max_height then $( "#draggable" ).css({"height":"61%"}) else $( "#draggable" ).css({"height":""})

    scope.$watch 'selections', (val) ->
      #makes div height smaller if it happens to be over 100%
      scope.$evalAsync ->     
        scope.fixHeight()