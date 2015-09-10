@service.service 'DealMember',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/deals/:deal_id/deal_members/:id', { deal_id: '@deal_id', id: '@id' },
    update: {
      method: 'PUT'
      url: '/api/deals/:deal_id/deal_members/:id'
    }

  @all = (params, callback) ->
    resource.query params, (deal_member) ->
      callback(deal_member)

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (deal_member) ->
      deferred.resolve(deal_member)
      $rootScope.$broadcast 'updated_deal_members'
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (deal_member) ->
      deferred.resolve(deal_member)
      $rootScope.$broadcast 'updated_deal_members'
    deferred.promise

  @roles = () ->
    [
      'Member'
      'Leader'
    ]

  @access = () ->
    [
      'Can Edit'
      'Can View'
      'Owner'
    ]
  return
]
