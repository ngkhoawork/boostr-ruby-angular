@service.service 'Contact',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    send = {}
    address_attributes =
      street1: original.contact.address.street1
      street2: original.contact.address.street2
      city: original.contact.address.city
      state: original.contact.address.state
      zip: original.contact.address.zip
      phone: original.contact.address.phone
      email: original.contact.address.email
    send.contact =
      name: original.contact.name
      position: original.contact.position
      address_attributes: address_attributes
      client_id: original.contact.client_id
    angular.toJson(send)

  resource = $resource '/api/contacts/:id', { id: '@id' },
    save: {
      method: 'POST'
      url: '/api/contacts'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/contacts/:id'
      transformRequest: transformRequest
    }

  allContacts = []
  currentContact = undefined

  @all = (callback) ->
    if allContacts.length == 0
      resource.query {}, (contacts) =>
        allContacts = contacts
        callback(contacts)
    else
      callback(allContacts)

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (contact) ->
      allContacts.push(contact)
      deferred.resolve(contact)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (contact) ->
      _.each allContacts, (existingContact, i) ->
        if(existingContact.id == contact.id)
          allContacts[i] = contact
      $rootScope.$broadcast 'updated_contacts'
      deferred.resolve(contact)
    deferred.promise

  @delete = (deletedContact, callback) ->
    resource.delete id: deletedContact.id, () ->
      _.each allContacts, (contact, i) ->
        if(contact.id == deletedContact.id)
          allContacts.splice(i, 1)
      callback?()
      $rootScope.$broadcast 'updated_contacts'

  @get = () ->
    currentContact

  @set = (contact_id) =>
    currentContact = _.find allContacts, (contact) ->
      return parseInt(contact_id) == contact.id
    $rootScope.$broadcast 'updated_current_contact'
  return
]
