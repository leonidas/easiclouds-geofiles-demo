module.exports = ->
  restrict:  'E'
  replace: true
  scope:
    selections: '='
  templateUrl: '/partials/cloud/templates/selectionsDiv.html'

  link: (scope) ->
    scope.fixHeight = ->         
      console.log "fixing"
      max_height =  $( "#map" ).height() * 0.9
      current_height = $( "#draggablechild" )[0].scrollHeight
      console.log "current :" + current_height + " max :" + max_height
      if current_height>max_height then $( "#draggable" ).css({"height":max_height+"px"}) else $( "#draggable" ).css({"height":""})

    scope.$watch 'selections', (val) ->
      #makes div height smaller if it happens to be over 100%
      scope.$evalAsync ->     
        scope.fixHeight()