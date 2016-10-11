@service.service 'Deal',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  transformRequest = (original, headers) ->
    original.deal.values_attributes = original.deal.values
    angular.toJson(original)

  transformAddContactRequest = (original, headers) ->
    # original.deal.values_attributes = original.deal.values
    console.log 'original:', original
    angular.toJson(original.params)

  resource = $resource '/api/deals/:id', { id: '@id' },
    save:
      method: 'POST'
      url: '/api/deals'
      transformRequest: transformRequest
    update:
      method: 'PUT'
      url: '/api/deals/:id'
      transformRequest: transformRequest
    dealContacts:
      method: 'GET',
      isArray: true
      url: 'api/deals/:id/deal_contacts'
    deleteDealContact:
      method: 'DELETE'
      url: 'api/deals/:id/deal_contacts/:contact_id'
    updateContacts:
      method: 'PUT'
      url: 'api/deals/:id'
      transformRequest: transformAddContactRequest

  pipeline_report_resource = $resource '/api/deals/pipeline_report'
  pipeline_summary_report_resource = $resource '/api/deals/pipeline_summary_report'

  currentDeal = undefined

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (deals) ->
      deferred.resolve(deals)
    deferred.promise

  @pipeline_report = (params) ->
    deferred = $q.defer()
    pipeline_report_resource.query params, (response) ->
      deferred.resolve(response)
    deferred.promise

  @pipeline_summary_report = (params) ->
    deferred = $q.defer()
    pipeline_summary_report_resource.query params, (response) ->
      deferred.resolve(response)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save params, (deal) ->
      deferred.resolve(deal)
      $rootScope.$broadcast 'updated_deals'
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (deal) ->
      deferred.resolve(deal)
      $rootScope.$broadcast 'updated_deals'
    deferred.promise

  @updateContacts = (id, params) ->
    deferred = do $q.defer
    resource.updateContacts id: id, params: params, (deal) ->
      deferred.resolve deal
      $rootScope.$broadcast 'updated_deals'
    deferred.promise

  @get = (deal_id) ->
    deferred = $q.defer()
    resource.get id: deal_id, (deal) ->
      deferred.resolve(deal)
    , (error) ->
      deferred.reject(error)
    deferred.promise

  @delete = (deletedDeal) ->
    deferred = $q.defer()
    resource.delete id: deletedDeal.id, () ->
      deferred.resolve()
      $rootScope.$broadcast 'updated_deals'
    deferred.promise

  @dealContacts = (id, params) ->
    deferred = $q.defer()
    resource.dealContacts id: id, params: params, (contacts) ->
      deferred.resolve(contacts)
    deferred.promise

  @deleteDealContact = (params) ->
    deferred = $q.defer()
    resource.deleteDealContact params, (response) ->
      deferred.resolve(contacts)
    deferred.promise

  return
]


@service.service 'DealResource',
['$resource',
($resource) ->

  transformRequest = (original, headers) ->
    original.deal.values_attributes = original.deal.values
    angular.toJson(original)

  resource = $resource '/api/deals/:id', { id: '@id' },
    save: {
      method: 'POST'
      url: '/api/deals'
      transformRequest: transformRequest
    },
    update: {
      method: 'PUT'
      url: '/api/deals/:id'
      transformRequest: transformRequest
    }

  resource
]
