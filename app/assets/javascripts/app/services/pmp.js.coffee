@service.service 'PMP',
  ['$resource', '$q', '$rootScope',
    ($resource, $q, $rootScope) ->

      transformRequest = (original, headers) ->
        console.log 'transformRequest orignal:', original
        original.pmp.values_attributes = original.pmp.values
        angular.toJson(original)

      resource = $resource '/api/pmps/:id', { id: '@id' },
        save:
          method: 'POST'
          url: '/api/pmps'
          transformRequest: transformRequest
        update:
          method: 'PUT'
          url: '/api/pmps/:id'
          transformRequest: transformRequest
        pmp_item_daily_actuals:
          method: 'GET'
          url: '/api/pmps/:id/pmp_item_daily_actuals'
          isArray: true

      currentIO = undefined

      @query = resource.query

      @all = (params) ->
        deferred = $q.defer()
        resource.query params, (pmps) ->
          deferred.resolve(pmps)
        deferred.promise

      @create = (params) ->
        deferred = $q.defer()
        resource.save(
          params,
          (pmp) ->
            deferred.resolve(pmp)
            $rootScope.$broadcast 'updated_pmp'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update(
          params,
          (pmp) ->
            deferred.resolve(pmp)
            $rootScope.$broadcast 'updated_pmp'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @pmp_item_daily_actuals = (pmp_id) ->
        deferred = $q.defer()
        resource.pmp_item_daily_actuals id: pmp_id, (data) ->
          deferred.resolve(data)
        deferred.promise

      @get = (io_id) ->
        deferred = $q.defer()
        resource.get id: io_id, (pmp) ->
          deferred.resolve(pmp)
        deferred.promise

      @delete = (deletedIO) ->
        deferred = $q.defer()
        resource.delete id: deletedIO.id, () ->
          deferred.resolve()
          $rootScope.$broadcast 'updated_pmp'
        deferred.promise

      return
  ]
