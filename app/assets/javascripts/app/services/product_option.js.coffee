@service.service 'ProductOption',
['$resource', '$q',
($resource, $q) ->
  resource = $resource '/api/product_options/:id', { id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/product_options/:id'
    }

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (options) ->
      deferred.resolve(options)
    deferred.promise

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