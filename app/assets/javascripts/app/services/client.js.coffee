@service.service 'Client',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/clients/:id', { id: '@id' }
  allClients = []
  currentClient = undefined

  @all = (callback) ->
    if allClients.length == 0
      resource.query {}, (clients) =>
        allClients = clients
        callback(clients)
    else
      callback(allClients)

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
      _.each allClients, (client, i) ->
        if(client.id == deletedClient.id)
          allClients.splice(i, 1)
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