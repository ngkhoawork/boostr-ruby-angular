@service.service 'Deal',
['$resource', '$q', '$rootScope',
($resource, $q, $rootScope) ->

  transformRequest = (original, headers) ->
    original.deal.values_attributes = []
    original.deal.values_attributes = original.deal.values if original.deal.values
    original.deal.values_attributes << original.deal.deal_type if original.deal.deal_type
    original.deal.values_attributes << original.deal.source_type if original.deal.source_type
    original.deal.type_id = original.deal.deal_type.option_id if original.deal.deal_type
    original.deal.source_id = original.deal.source_type.option_id if original.deal.source_type

    original.deal.deal_custom_field_attributes = original.deal.deal_custom_field if original.deal.deal_custom_field
    angular.toJson(original)

  resource = $resource '/api/deals/:id', { id: '@id' },
    list:
      method: 'GET'
      url: '/api/deals/all'
      isArray: true
    deals_info_by_stage:
      method: 'GET'
      url: '/api/deals/all_deals_header'
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
    forecast_detail:
      method: 'GET'
      url: 'api/deals.json'
      isArray: true
    won_deals:
      method: 'GET'
      url: '/api/deals/won_deals'
      isArray: true
    filter_data:
      method: 'GET'
      url: '/api/deals/filter_data'
    pipeline_report_totals:
      method: 'GET'
      url: '/api/deals/pipeline_report_totals'
    pipeline_report_monthly_budgets:
      method: 'GET'
      url: '/api/deals/pipeline_report_monthly_budgets'

  pipeline_report_resource = $resource '/api/deals/pipeline_report', {},
    query:  {
      isArray: true,
      transformResponse: (data, headers) ->
        resource.totalCount = headers()['x-total-count']
        angular.fromJson(data)
    }

  pipeline_summary_report_resource = $resource '/api/deals/pipeline_summary_report'

  currentDeal = undefined
  resource.totalCount = 0

  @pipeline_report_count = ->
    resource.totalCount

  @all = (params) ->
    deferred = $q.defer()
    resource.query params, (deals) ->
      deferred.resolve(deals)
    deferred.promise

  @list = (params) -> resource.list(params).$promise
  @deals_info_by_stage = (params) -> resource.deals_info_by_stage(params).$promise

  @filter_data = -> resource.filter_data().$promise

  @won_deals = (params) ->
    deferred = $q.defer()
    resource.won_deals params, (deals) ->
      deferred.resolve(deals)
    deferred.promise

  @pipeline_report = (params) ->
    deferred = $q.defer()
    pipeline_report_resource.query params, (response) ->
      deferred.resolve(response)
    deferred.promise

  @pipeline_report_totals = (params) ->
    deferred = $q.defer()
    resource.pipeline_report_totals params, (response) ->
      deferred.resolve(response)
    deferred.promise

  @pipeline_report_monthly_budgets = (params) ->
    deferred = $q.defer()
    resource.pipeline_report_monthly_budgets params, (response) ->
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

  @forecast_detail = (params) ->
    deferred = $q.defer()
    resource.forecast_detail params, (response) ->
      deferred.resolve(response)
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
        $rootScope.$broadcast 'newDeal', deal.id
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
        $rootScope.$broadcast 'updated_deals', deal
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
    resource.delete id: deletedDeal.id, (deal) ->
      deferred.resolve(deal)
      $rootScope.$broadcast 'updated_deals', deal, 'delete'
    , (error) ->
      deferred.reject(error)
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
