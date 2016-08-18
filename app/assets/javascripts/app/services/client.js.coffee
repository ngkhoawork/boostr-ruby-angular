@service.service 'Client',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    send = {}
    original.address = original.address || {}
    address_attributes =
      street1: original.address.street1
      street2: original.address.street2
      city: original.address.city
      state: original.address.state
      zip: original.address.zip
      phone: original.address.phone
      email: original.address.email
    values_attributes = original.values
    send.client =
      name: original.name
      website: original.website
      client_type_id: original.client_type_id
      client_category_id: original.client_category_id
      client_subcategory_id: original.client_subcategory_id
      address_attributes: address_attributes
      values_attributes: values_attributes
    angular.toJson(send)

  resource = $resource '/api/clients/:id', { id: '@id' },
    query: {
      isArray: true,
      transformResponse: (data, headers) ->
        resource.totalCount = headers()['x-total-count']
        angular.fromJson(data)
    },
    save: {
      method: "POST"
      transformRequest: transformRequest
    },
    update: {
      method: "PUT"
      transformRequest: transformRequest
    }

  resource.allClients = []
  resource.currentClient = {}
  resource.totalCount = 0

  resource.__all = (params) ->
    deferred = $q.defer()
    resource.query params, (clients) =>
      allClients = clients
      deferred.resolve(clients)
    deferred.promise

  resource.__create = (params) ->
    deferred = $q.defer()
    resource.save params, (client) ->
      allClients.push(client)
      deferred.resolve(client)
    deferred.promise

  resource.__update = (params) ->
    deferred = $q.defer()
    resource.update params, (client) ->
      _.each allClients, (existingClient, i) ->
        if(existingClient.id == client.id)
          allClients[i] = client
      $rootScope.$broadcast 'updated_clients'
      deferred.resolve(client)
    deferred.promise

  resource.__delete = (deletedClient, callback) ->
    resource.delete id: deletedClient.id, () ->
      allClients = _.reject allClients, (client) ->
        client.id == deletedClient.id
      callback?()
      $rootScope.$broadcast 'updated_clients'

  resource.__get = () ->
    currentClient

  resource.__set = (client_id) =>
    currentClient = _.find allClients, (client) ->
      return parseInt(client_id) == client.id
    $rootScope.$broadcast 'updated_current_client'

  return resource
]
