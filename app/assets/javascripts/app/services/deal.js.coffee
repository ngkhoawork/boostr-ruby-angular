@service.service 'Deal',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  transformRequest = (original, headers) ->
    original.deal.values_attributes = original.deal.values if original.deal.values
    original.deal.deal_custom_field_attributes = original.deal.deal_custom_field if original.deal.deal_custom_field
    angular.toJson(original)

  resource = $resource '/api/deals/:id', { id: '@id' },
    save:
      method: 'POST'
      url: '/api/deals'
      transformRequest: transformRequest
    update:
      method: 'PUT'
      url: '/api/deals/:id'
      transformRequest: transformRequest
    send_to_operative:
      method: 'POST'
      url: '/api/deals/:id/send_to_operative'
    get_latest_operative_log:
      method: 'GET'
      url: 'api/deals/:id/latest_log'

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

  @send_to_operative = (params) ->
    deferred = $q.defer()
    resource.send_to_operative params,
      (resp) ->
        deferred.resolve(resp)
      (err) ->
        deferred.reject(err)
    deferred.promise

  @latest_log = (params) ->
    deferred = $q.defer()
    resource.get_latest_operative_log params,
      (resp) ->
        deferred.resolve(resp)
      (err) ->
        deferred.reject(err)
    deferred.promise

  @pipeline_summary_report = (params) ->
    deferred = $q.defer()
    pipeline_summary_report_resource.query params, (response) ->
      deferred.resolve(response)
    deferred.promise

  @create = (params) ->
    deferred = $q.defer()
    resource.save(
      params,
      (deal) ->
        deferred.resolve(deal)
        $rootScope.$broadcast 'updated_deals'
      (resp) ->
        deferred.reject(resp)
    )
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update(
      params,
      (deal) ->
        deferred.resolve(deal)
        $rootScope.$broadcast 'updated_deals'
      (resp) ->
        deferred.reject(resp)
    )
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
