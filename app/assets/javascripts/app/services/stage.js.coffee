@service.service 'Stage',
['$resource', '$q'
($resource, $q) ->

  resource = $resource '/api/stages/:id', { id: '@id' },
    update:
      method: 'PUT'
    team_stages:
      method: 'GET'
      url: 'api/stages/team_stages'
      isArray: true

  return resource
]
