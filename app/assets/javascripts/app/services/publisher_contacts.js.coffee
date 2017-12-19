@service.service 'PublisherContact',
  ['$resource', ( $resource ) ->
    resource = $resource 'api/publisher_contacts', {id: '@id'},
      addContact:
        method: 'PUT'
        url: 'api/publisher_contacts/:id/add'
      delete:
        method: 'DELETE'
        url: 'api/publisher_contacts/:id'

    this.addContact = (params) -> resource.addContact(params).$promise
    this.delete = (params) -> resource.delete(params).$promise

    return
  ]