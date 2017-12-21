@service.service 'BpEstimate',
  ['$resource', '$q', '$rootScope',
    ($resource, $q, $rootScope) ->
      transformRequest = (original, headers) ->
        send = {}
        send.bp_estimate =
          bp_id: original.bp_estimate.bp_id
          client_id: original.bp_estimate.client_id
          user_id: original.bp_estimate.user_id
          estimate_seller: original.bp_estimate.estimate_seller
          estimate_mgr: original.bp_estimate.estimate_mgr
          objectives: original.bp_estimate.objectives
          assumptions: original.bp_estimate.assumptions
          bp_estimate_products_attributes: original.bp_estimate.bp_estimate_products

        angular.toJson(send)

      resource = $resource '/api/bps/:bp_id/bp_estimates/:id', { bp_id: '@bp_id', id: '@id' },
        get:
          method: 'GET'
          url: '/api/bps/:bp_id/bp_estimates'

        update:
          method: 'PUT'
          url: '/api/bps/:bp_id/bp_estimates/:id'
          transformRequest: transformRequest
        save:
          method: 'POST'
          transformRequest: transformRequest

        get_status:
          method: 'GET'
          url: '/api/bps/:bp_id/bp_estimates/status'

      resource.totalCount = 0

      @all = (params) ->
        deferred = $q.defer()
        resource.get params, (bp_estimates) ->
          deferred.resolve(bp_estimates)
        deferred.promise
      @create = (params) ->
        deferred = $q.defer()
        resource.save params, (bp_estimate) ->
          deferred.resolve(bp_estimate)
        deferred.promise

      @get_status = (params) ->
        deferred = $q.defer()
        resource.get_status params, (response) ->
          deferred.resolve(response)
        deferred.promise

      @update = (params) ->
        deferred = $q.defer()
        resource.update params, (bp_estimate) ->
          deferred.resolve(bp_estimate)
        deferred.promise

      @delete = (params) ->
        deferred = $q.defer()
        resource.delete params, (bp_estimate) ->
          deferred.resolve(bp_estimate)
        deferred.promise

      @resource = resource

      return 
  ]
