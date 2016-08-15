@service.service 'Option',
['$resource', '$q',
($resource, $q) ->

  resource = $resource '/api/options/:id', { id: '@id', field_id: '@field_id', option_id: '@option_id' },
    update: {
      method: 'PUT'
      url: '/api/options/:id'
    }

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (option) ->
      deferred.resolve(option)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (option) ->
      deferred.resolve(option)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete params, (deleted_option) ->
      deferred.resolve(deleted_option)
    deferred.promise

  return
]