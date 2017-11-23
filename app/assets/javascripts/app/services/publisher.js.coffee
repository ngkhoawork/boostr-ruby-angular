@service.service 'Publisher',
  ['$resource', ( $resource ) ->
    resource = $resource '/api/publishers', {},
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
        
    this.publishersList = (params) -> resource.publishersList(params).$promise
    this.publisherSettings = (params) -> resource.publisherSettings(params).$promise
    this.create = (params) -> resource.create(params).$promise
      
    return
  ]