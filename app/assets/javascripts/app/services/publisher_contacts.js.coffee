@service.service 'PublisherContact',
  ['$resource', ( $resource ) ->
    resource = $resource 'api/publisher_contacts', {id: '@id'},
      addContact:
        method: 'PUT'
        url: 'api/publisher_contacts/:id/add'
      create:
        method: 'POST'
        url: 'api/publisher_contacts'
      update:
        method: 'PUT'
        url: 'api/publisher_contacts/:id'
      delete:
        method: 'DELETE'
        url: 'api/publisher_contacts/:id'

    this.addContact = (params) -> resource.addContact(params).$promise
    this.delete = (params) -> resource.delete(params).$promise
    this.create = (params) -> resource.create(params).$promise
    this.update = (params) -> resource.update(params).$promise

    return
  ]