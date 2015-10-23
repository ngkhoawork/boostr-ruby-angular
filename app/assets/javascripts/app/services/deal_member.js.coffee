@service.service 'DealMember',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    original.deal_member.values_attributes = original.deal_member.values
    angular.toJson(original)

  resource = $resource '/api/deals/:deal_id/deal_members/:id', { deal_id: '@deal_id', id: '@id' },
    save: {
      method: 'POST'
      url: '/api/deals/:deal_id/deal_members'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/deals/:deal_id/deal_members/:id'
      transformRequest: transformRequest
    }

  @all = (params) ->
    resource.query params, (deal_member) ->
      deferred = $q.defer()
      deferred.resolve(deal_member)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (deal_member) ->
      deferred.resolve(deal_member)
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (deal_member) ->
      deferred.resolve(deal_member)
    deferred.promise

  @delete = (params) ->
    deferred = $q.defer()
    resource.delete { deal_id: params.deal_id, id: params.id }, (deal) ->
      deferred.resolve(deal)
    deferred.promise

  return
]
