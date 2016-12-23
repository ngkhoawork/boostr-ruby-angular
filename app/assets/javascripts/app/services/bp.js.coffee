@service.service 'BP',
  ['$resource', '$q', '$rootScope',
    ($resource, $q, $rootScope) ->

      transformRequest = (original, headers) ->
        console.log(original)
        original.bp.values_attributes = original.bp.values
        angular.toJson(original)

      transformAddContactRequest = (original, headers) ->
        # original.bp.values_attributes = original.bp.values
        console.log 'original:', original
        angular.toJson(original.params)

      resource = $resource '/api/bps/:id', { id: '@id' },
        save:
          method: 'POST'
          url: '/api/bps'
          transformRequest: transformRequest
        update:
          method: 'PUT'
          url: '/api/bps/:id'
          transformRequest: transformRequest
        updateContacts:
          method: 'PUT'
          url: 'api/bps/:id'
          transformRequest: transformAddContactRequest
        sellerTotalEstimates:
          method: 'GET'
          isArray: true
          url: 'api/bps/:id/seller_total_estimates'
        accountTotalEstimates:
          method: 'GET'
          isArray: true
          url: 'api/bps/:id/account_total_estimates'

      currentBP = undefined

      @all = (params) ->
        deferred = $q.defer()
        resource.query params, (bps) ->
          deferred.resolve(bps)
        deferred.promise

      @sellerTotalEstimates = (params) ->
        deferred = $q.defer()
        resource.sellerTotalEstimates params, (data) ->
          deferred.resolve(data)
        deferred.promise
      @accountTotalEstimates = (params) ->
        deferred = $q.defer()
        resource.accountTotalEstimates params, (data) ->
          deferred.resolve(data)
        deferred.promise

      @create = (params) ->
        deferred = $q.defer()
        resource.save(
          params,
          (bp) ->
            deferred.resolve(bp)
            $rootScope.$broadcast 'updated_bps'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update(
          params,
          (bp) ->
            deferred.resolve(bp)
            $rootScope.$broadcast 'updated_bps'
          (resp) ->
            deferred.reject(resp)
        )
        deferred.promise


      @get = (bp_id) ->
        deferred = $q.defer()
        resource.get id: bp_id, (bp) ->
          deferred.resolve(bp)
        deferred.promise

      @delete = (deletedBP) ->
        deferred = $q.defer()
        resource.delete id: deletedBP.id, () ->
          deferred.resolve()
          $rootScope.$broadcast 'updated_bps'
        deferred.promise

      return
  ]
