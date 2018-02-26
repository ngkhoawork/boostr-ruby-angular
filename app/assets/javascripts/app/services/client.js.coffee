@service.service 'Client',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    send = {}
    original.address = original.address || {}
    address_attributes =
      country: original.address.country
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
      note: original.note
      client_type_id: original.client_type.option_id
      client_category_id: original.client_category_id
      client_subcategory_id: original.client_subcategory_id
      client_region_id: original.client_region_id
      client_segment_id: original.client_segment_id
      parent_client_id: original.parent_client_id || null
      holding_company_id: original.holding_company_id
      address_attributes: address_attributes
      values_attributes: values_attributes
      account_cf_attributes: original.account_cf
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
    },
    sellers: {
      method: "GET"
      url: 'api/clients/:id/sellers'
      isArray: true
    },
    connected_contacts: {
      method: "GET"
      url: 'api/clients/:id/connected_contacts'
      isArray: true
    },
    connected_client_contacts: {
      method: "GET"
      url: 'api/clients/:id/connected_client_contacts'
      isArray: true
    },
    child_clients: {
      method: "GET"
      url: 'api/clients/:id/child_clients'
      isArray: true
    },
    stats: {
      method: "GET"
      url: 'api/clients/:id/stats'
    },
    filter_options: {
      method: "GET"
      url: 'api/clients/filter_options'
    },
    accountDimensions: {
      method: 'GET'
      url: '/api/account_dimensions'
      isArray: true
    },
    search_clients: {
      isArray: true
      method: "GET"
      url: 'api/clients/search_clients'
    },
    fuzzy_search: {
      isArray: true
      method: "GET"
      url: 'api/clients/fuzzy_search'
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

  resource.__sellers = (params) ->
    deferred = $q.defer()
    resource.sellers params, (sellers) ->
      deferred.resolve(sellers)
    deferred.promise

  resource.__connected_contacts = (params) ->
    deferred = $q.defer()
    resource.connected_contacts params, (connected_contacts) ->
      deferred.resolve(connected_contacts)
    deferred.promise
    deferred.promise

  resource.__connected_client_contacts = (params) ->
    deferred = $q.defer()
    resource.connected_client_contacts params, (connected_client_contacts) ->
      deferred.resolve(connected_client_contacts)
    deferred.promise

  resource.__child_clients = (params) ->
    deferred = $q.defer()
    resource.child_clients params, (child_clients) ->
      deferred.resolve(child_clients)
    deferred.promise

  resource.__stats = (params) ->
    deferred = $q.defer()
    resource.stats params, (data) ->
      deferred.resolve(data)
    deferred.promise

  resource.__filter_options = (params) ->
    deferred = $q.defer()
    resource.filter_options params, (response) ->
      deferred.resolve(response)
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
    , (error) ->
      callback?(error)

  resource.__get = () ->
    currentClient

  resource.__set = (client_id) =>
    currentClient = _.find allClients, (client) ->
      return parseInt(client_id) == client.id
    $rootScope.$broadcast 'updated_current_client'

  return resource
]
