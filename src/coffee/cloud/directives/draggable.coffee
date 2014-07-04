module.exports = ->
  restrict:  'AE'
  scope:
    title:  '@'
    dragging: '@'
    x: '@'
    y: '@'
    startX: '@'
    startY: '@'
  transclude : true
  replace : true
  templateUrl: '/partials/cloud/templates/selectionsDiv.html'

  link: (scope, element, attr) ->
    scope.x = 0
    scope.y = 0
    scope.dragging = false

    scope.mousemove = (event) =>
      if scope.dragging
        console.log "move"
        scope.y = event.pageY - scope.startY
        scope.x = event.pageX - scope.startX
        css = "top: " + scope.y + 'px' + "left: " + scope.x + 'px'
        console.log css
        element.css css

    scope.mouseup = (event) =>
      console.log scope.x
      scope.dragging = false

    scope.mousedown = (event) =>
      console.log "link"
      console.log scope.x
      scope.x = 0
      scope.y = 0
      console.log scope.dragging
      scope.dragging = true
      scope.startX = event.pageX - scope.x
      scope.startY = event.pageY - scope.y
      console.log scope.startX
      event.preventDefault()

    element.on 'mousedown', scope.mousedown
    element.on 'mousemove', scope.mousemove
    element.on 'mouseup', scope.mouseup
