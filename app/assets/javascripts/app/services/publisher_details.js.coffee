@service.service 'PublisherDetails',
  ['$resource', ( $resource ) ->
    resource = $resource '/api/publisher_details', {id: '@id'},
    getPublisher:
      method: 'GET'
      url: '/api/publisher_details/:id'
    activities:
      method: 'GET'
      url: '/api/publisher_details/:id/activities'
    associations:
      method: 'GET'
      url: '/api/publisher_details/:id/associations'

    this.activities = (params) -> resource.activities(params).$promise
    this.getPublisher = (params) -> resource.getPublisher(params).$promise
    this.associations = (params) -> resource.associations(params).$promise

    return
  ]