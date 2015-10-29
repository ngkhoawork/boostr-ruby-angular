@service.service 'Client',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    send = {}
    address_attributes =
      street1: original.client.address.street1
      street2: original.client.address.street2
      city: original.client.address.city
      state: original.client.address.state
      zip: original.client.address.zip
      phone: original.client.address.phone
      email: original.client.address.email
    values_attributes = original.client.values
    send.client =
      name: original.client.name
      website: original.client.website
      client_type_id: original.client.client_type_id
      address_attributes: address_attributes
      values_attributes: values_attributes
    angular.toJson(send)

  resource = $resource '/api/clients/:id', { id: '@id' },
    save: {
      method: 'POST'
      url: '/api/clients'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/clients/:id'
      transformRequest: transformRequest
    }

  allClients = []
  currentClient = {}

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (clients) =>
      allClients = clients
      deferred.resolve(clients)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (client) ->
      allClients.push(client)
      deferred.resolve(client)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (client) ->
      _.each allClients, (existingClient, i) ->
        if(existingClient.id == client.id)
          allClients[i] = client
      $rootScope.$broadcast 'updated_clients'
      deferred.resolve(client)
    deferred.promise

  @delete = (deletedClient, callback) ->
    resource.delete id: deletedClient.id, () ->
      allClients = _.reject allClients, (client) ->
        client.id == deletedClient.id
      callback?()
      $rootScope.$broadcast 'updated_clients'

  @get = () ->
    currentClient

  @set = (client_id) =>
    currentClient = _.find allClients, (client) ->
      return parseInt(client_id) == client.id
    $rootScope.$broadcast 'updated_current_client'

  return
]
