@service.service 'InfluencerContentFee',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  transformRequest = (original, headers) ->
    original.influencer_content_fee.values_attributes = original.influencer_content_fee.values if original.influencer_content_fee.values
    original.influencer_content_fee.agreement_attributes = original.influencer_content_fee.agreement if original.influencer_content_fee.agreement
    angular.toJson(original)

  resource = $resource '/api/ios/:io_id/influencer_content_fees/:id', { io_id: '@io_id', id: '@id' },
    query:
      isArray: true,
      method: 'GET'
      url: '/api/ios/:io_id/influencer_content_fees'
      transformResponse: (data, headers) ->
        resource.totalCount = headers()['x-total-count']
        angular.fromJson(data)
    save:
      method: 'POST'
      url: '/api/ios/:io_id/influencer_content_fees'
      transformRequest: transformRequest
    update:
      method: 'PUT'
      url: '/api/ios/:io_id/influencer_content_fees/:id'
      transformRequest: transformRequest

  currentInfluencerContentFee = undefined

  resource.totalCount = 0

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (influencer_content_fees) ->
      deferred.resolve(influencer_content_fees)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save(
      params,
      (influencer_content_fee) ->
        deferred.resolve(influencer_content_fee)
        $rootScope.$broadcast 'updated_influencer_content_fees'
        $rootScope.$broadcast 'newInfluencerContentFee', influencer_content_fee.id
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update(
      params,
      (influencer_content_fee) ->
        deferred.resolve(influencer_content_fee)
        $rootScope.$broadcast 'updated_influencer_content_fees'
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  @get = (influencer_content_fee_id) ->
    deferred = $q.defer()
    resource.get id: influencer_content_fee_id, (influencer_content_fee) ->
      deferred.resolve(influencer_content_fee)
    , (error) ->
      deferred.reject(error)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete params, (influencer_content_fee) ->
      deferred.resolve(influencer_content_fee)
      $rootScope.$broadcast 'updated_influencer_content_fees'
    , (error) ->
      deferred.reject(error)
    deferred.promise
  @resource = resource
  return
]


