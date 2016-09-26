@service.service 'ClientContacts',
  ['$http', ($http) ->
    return {
      apiPathPrefics: '/api/clients/',
      apiPathPostfics: '/client_contacts/',

#      GET    /api/clients/:client_id/client_contacts(.:format)                 api/client_contacts#index
      list: (clientId) ->
        return $http.get(this.apiPathPrefics + clientId + this.apiPathPostfics)
      ,
#      GET    /api/clients/:client_id/client_contacts/related_clients(.:format) api/client_contacts#related_clients
      related_clients: (clientId) ->
        return $http.get(this.apiPathPrefics + clientId + this.apiPathPostfics + 'related_clients.json')
      ,
#      POST   /api/clients/:client_id/client_contacts(.:format)                 api/client_contacts#create
      create: (clientId) ->
        return $http.post(this.apiPathPrefics + clientId + this.apiPathPostfics)
      ,
#      PUT    /api/clients/:client_id/client_contacts/:id(.:format)             api/client_contacts#update
      update: (clientId, contactId) ->
        return $http.put(this.apiPathPrefics + clientId + this.apiPathPostfics + contactId)
    }

  ]
