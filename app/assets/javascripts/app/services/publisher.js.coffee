@service.service 'Publisher',
  ['$resource', ( $resource ) ->
    resource = $resource '/api/publishers', {},
      publishersList:
        method: 'GET'
        url: '/api/publishers'
        isArray: true

    this.publishersList = (params) -> resource.publishersList(params).$promise
      
    return
  ]