@service.service 'PMPItem',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    original.pmp_item.values_attributes = original.pmp_item.values
    angular.toJson(original)

  resource = $resource '/api/pmps/:pmp_id/pmp_items/:id', { pmp_id: '@pmp_id', id: '@id' },
    save: {
      method: 'POST'
      url: '/api/pmps/:pmp_id/pmp_items'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/pmps/:pmp_id/pmp_items/:id'
      transformRequest: transformRequest
    }

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (pmp_items) ->
      deferred.resolve(pmp_items)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (pmp_item) ->
      deferred.resolve(pmp_item)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (pmp_item) ->
      deferred.resolve(pmp_item)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete { pmp_id: params.pmp_id, id: params.id }, () ->
      deferred.resolve()
    deferred.promise

  return
]
