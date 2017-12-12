@service.service 'PublisherContact',
  ['$resource', ( $resource ) ->
    resource = $resource 'api/publisher_contacts', {id: '@id'},
      addContact:
        method: 'PUT'
        url: 'api/publisher_contacts/:id/add'

    this.addContact = (params) -> resource.addContact(params).$promise

    return
  ]