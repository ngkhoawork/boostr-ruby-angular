@service.service 'Ealert',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  transformRequest = (original, headers) ->
    original.ealert.ealert_stages_attributes = original.ealert.ealert_stages if original.ealert.ealert_stages
    original.ealert.ealert_custom_fields_attributes = original.ealert.ealert_custom_fields if original.ealert.ealert_custom_fields
    angular.toJson(original)

  resource = $resource '/api/ealerts/:id', { id: '@id' },
    query: 
      isArray: false
    save:
      method: 'POST'
      url: '/api/ealerts'
      transformRequest: transformRequest
    update:
      method: 'PUT'
      url: '/api/ealerts/:id'
      transformRequest: transformRequest
    send_ealert:
      method: 'POST'
      url: '/api/ealerts/:id/send_ealert'

  currentEalert = undefined

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (ealerts) ->
      deferred.resolve(ealerts)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save(
      params,
      (ealert) ->
        deferred.resolve(ealert)
        $rootScope.$broadcast 'updated_ealerts'
        $rootScope.$broadcast 'newEalert', ealert.id
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update(
      params,
      (ealert) ->
        deferred.resolve(ealert)
        $rootScope.$broadcast 'updated_ealerts'
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  @send_ealert = (params) ->
    deferred = $q.defer()
    resource.send_ealert(
      params,
      (ealert) ->
        deferred.resolve(ealert)
        $rootScope.$broadcast 'sent_ealert'
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  @get = (ealert_id) ->
    deferred = $q.defer()
    resource.get id: ealert_id, (ealert) ->
      deferred.resolve(ealert)
    , (error) ->
      deferred.reject(error)
    deferred.promise

  @delete = (deletedEalert) ->
    deferred = $q.defer()
    resource.delete id: deletedEalert.id, (ealert) ->
      deferred.resolve(ealert)
      $rootScope.$broadcast 'updated_ealerts'
    , (error) ->
      deferred.reject(error)
    deferred.promise

  return
]


