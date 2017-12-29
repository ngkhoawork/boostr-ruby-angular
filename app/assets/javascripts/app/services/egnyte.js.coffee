@service.service 'Egnyte',
  ['$resource', ( $resource ) ->
    resource = $resource 'api/egnyte', {id: '@id'}

    return
  ]