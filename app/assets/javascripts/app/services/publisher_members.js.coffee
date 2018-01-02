@service.service 'PublisherMembers',
  ['$resource', ( $resource ) ->
    resource = $resource '/api/publisher_members', {id: '@id'},
      update:
        method: 'PUT'
        url: '/api/publisher_members/:id'
      create:
        method: 'POST'
        url: '/api/publisher_members'
      delete:
        method: 'DELETE'
        url: '/api/publisher_members/:id'

    this.update = (params) -> resource.update(params).$promise
    this.create = (params) -> resource.create(params).$promise
    this.delete = (params) -> resource.delete(params).$promise

    return
  ]