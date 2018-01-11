@service.service 'Egnyte',
  ['$resource', ( $resource ) ->
    resource = $resource 'api/egnyte', {id: '@id'},
      index:
        method: 'GET'
        url: '/api/egnyte'

    this.index = (params) -> resource.index(params).$promise

    return
  ]