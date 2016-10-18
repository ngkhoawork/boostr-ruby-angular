@service.service 'Contact',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->
  currentContact = {}
  @totalCount = 0
  self = @

  transformRequest = (original, headers) ->
    send = {}
    address_attributes = {}
    if original.contact.address
      address_attributes =
        street1: original.contact.address.street1
        street2: original.contact.address.street2
        city: original.contact.address.city
        state: original.contact.address.state
        zip: original.contact.address.zip
        phone: original.contact.address.phone
        mobile: original.contact.address.mobile
        email: original.contact.address.email
        id: original.contact.address.id
    send.contact =
      name: original.contact.name
      position: original.contact.position
      note: original.contact.note
      address_attributes: address_attributes
      client_id: original.contact.client_id
      set_primary_client: !!(original.contact.set_primary_client)
    angular.toJson(send)

  resource = $resource '/api/contacts/:id', { id: '@id' },
    query:
      isArray: true,
      transformResponse: (data, headers) ->
        resource.totalCount = headers()['x-total-count']
        angular.fromJson(data)
    save:
      method: 'POST'
      url: '/api/contacts'
      transformRequest: transformRequest
    update:
      method: 'PUT'
      url: '/api/contacts/:id'
      transformRequest: transformRequest
    delete:
      method: 'DELETE'
      url: '/api/contacts/:id'

  # @TODO: Replace all of this with just returning resource
  allContacts = []
  currentContact = undefined

  # @$resource = resource

  resource.all = (callback) ->
    resource.query {}, (contacts) =>
      allContacts = contacts
      callback(contacts)

  resource.all1 = (params) ->
    deferred = $q.defer()
    resource.query params, (contacts) =>
      allContacts = contacts
      deferred.resolve(contacts)
    deferred.promise

  resource.allForClient = (client_id, callback) ->
    resource.query client_id: client_id, (contacts) ->
      callback(contacts)

  resource.create = (params) ->
    deferred = $q.defer()
    resource.save(
      params,
      (contact) ->
        allContacts.push(contact)
        deferred.resolve(contact)
      (resp) ->
        deferred.reject(resp)
    )

    deferred.promise

  resource._update = (params) ->
    deferred = $q.defer()
    console.log 'UPDATE'
    resource.update(
      params
      (contact) ->
        _.each allContacts, (existingContact, i) ->
          if(existingContact.id == contact.id)
            allContacts[i] = contact
        $rootScope.$broadcast 'updated_contacts'
        deferred.resolve(contact)
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  resource.get = () ->
    currentContact

  resource.set = (contact_id) =>
    currentContact = _.find allContacts, (contact) ->
      return parseInt(contact_id) == contact.id
    $rootScope.$broadcast 'updated_current_contact'

  return resource
]
