module.exports = ->
  restrict:     'E'
  replace:      true
  scope:
    title:  '@'
    memory:  '@'
    cpucores: '@'
    storage:  '@'
    simultaneousjobs:  '@'
    databases: '@'
    support: '@'
    security: '@'
    hostname: '@'
  templateUrl: '/partials/cloud/templates/markerTemplate.html'
