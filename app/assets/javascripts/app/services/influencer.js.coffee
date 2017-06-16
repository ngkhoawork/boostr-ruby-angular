@service.service 'Influencer',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  transformRequest = (original, headers) ->
    original.influencer.values_attributes = original.influencer.values if original.influencer.values
    original.influencer.agreement_attributes = original.influencer.agreement if original.influencer.agreement
    angular.toJson(original)

  resource = $resource '/api/influencers/:id', { id: '@id' },
    query:
      isArray: true,
      method: 'GET'
      url: '/api/influencers'
      transformResponse: (data, headers) ->
        resource.totalCount = headers()['x-total-count']
        angular.fromJson(data)
    save:
      method: 'POST'
      url: '/api/influencers'
      transformRequest: transformRequest
    update:
      method: 'PUT'
      url: '/api/influencers/:id'
      transformRequest: transformRequest

  currentInfluencer = undefined

  resource.totalCount = 0

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (influencers) ->
      deferred.resolve(influencers)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save(
      params,
      (influencer) ->
        deferred.resolve(influencer)
        $rootScope.$broadcast 'updated_influencers'
        $rootScope.$broadcast 'newInfluencer', influencer.id
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update(
      params,
      (influencer) ->
        deferred.resolve(influencer)
        $rootScope.$broadcast 'updated_influencers'
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  @get = (influencer_id) ->
    deferred = $q.defer()
    resource.get id: influencer_id, (influencer) ->
      deferred.resolve(influencer)
    , (error) ->
      deferred.reject(error)
    deferred.promise

  @delete = (deletedInfluencer) ->
    deferred = $q.defer()
    resource.delete id: deletedInfluencer.id, (influencer) ->
      deferred.resolve(influencer)
      $rootScope.$broadcast 'updated_influencers'
    , (error) ->
      deferred.reject(error)
    deferred.promise
  @resource = resource
  return
]


