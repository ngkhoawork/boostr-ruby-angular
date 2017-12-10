@service.service 'PublisherMembers',
  ['$resource', ( $resource ) ->
    resource = $resource '/api/publisher_members', {id: '@id'},
      update:
        method: 'PUT'
        url: '/api/publisher_members/:id'
      create:
        method: 'POST'
        url: '/api/publisher_members'

    this.update = (params) -> resource.update(params).$promise
    this.create = (params) -> resource.create(params).$promise

    return
  ]