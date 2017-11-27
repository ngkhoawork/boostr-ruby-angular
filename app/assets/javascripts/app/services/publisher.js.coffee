@service.service 'Publisher',
  ['$resource', ( $resource ) ->
    resource = $resource '/api/publishers', {id: '@id'},
      publishersList:
        method: 'GET'
        url: '/api/publishers'
        isArray: true
      publisherSettings:
        method: 'GET'
        url: '/api/publishers/settings'
      create:
        method: 'POST'
        url: '/api/publishers'
      update:
        method: 'PUT'
        url: '/api/publishers/:id'
        
    this.publishersList = (params) -> resource.publishersList(params).$promise
    this.publisherSettings = (params) -> resource.publisherSettings(params).$promise
    this.create = (params) -> resource.create(params).$promise
    this.update = (params) -> resource.update(params).$promise
      
    return
  ]