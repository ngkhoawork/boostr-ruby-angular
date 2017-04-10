@service.service 'TimePeriod',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  transformRequest = (original, headers) ->
    original.time_period.values_attributes = original.time_period.values
    angular.toJson(original)
#  resource = $resource '/api/time_periods/:id', { id: '@id' }

  resource = $resource '/api/time_periods/:id', { id: '@id' },
    save:
      method: 'POST'
      url: '/api/time_periods'
      transformRequest: transformRequest
    update:
      method: 'PUT'
      url: '/api/time_periods/:id'
      transformRequest: transformRequest
    current_year_quarters:
      method: 'GET'
      isArray: true
      url: '/api/time_periods/current_year_quarters'

  allTimePeriods = []

  @period_types = [
      {name: 'Year', value: 'year'}
      {name: 'Quarter', value: 'quarter'}
      {name: 'Month', value: 'month'}
      {name: 'Other', value: 'other'}
  ]

  @all = ->
    deferred = $q.defer()
    if allTimePeriods.length == 0
      resource.query {}, (time_periods) =>
        allTimePeriods = time_periods
        deferred.resolve(time_periods)
    else
      deferred.resolve(allTimePeriods)
    deferred.promise

  @current_year_quarters = (params) ->
    deferred = $q.defer()
    resource.current_year_quarters params, (data) ->
      deferred.resolve(data)
    deferred.promise

  @create = (params, errorCallback) ->
    deferred = $q.defer()
    resource.save params,
    (time_period) ->
      allTimePeriods.push(time_period)
      deferred.resolve(time_period)
      $rootScope.$broadcast 'updated_time_periods'
    , errorCallback
    deferred.promise

  @update = (params) ->
    deferred = $q.defer()
    resource.update params, (time_period) ->
      deferred.resolve(time_period)
      $rootScope.$broadcast 'updated_time_periods'
    deferred.promise

  @delete = (deletedTimePeriod) ->
    deferred = $q.defer()
    resource.delete id: deletedTimePeriod.id, () ->
      allTimePeriods = _.reject allTimePeriods, (time_period) ->
        time_period.id == deletedTimePeriod.id
      deferred.resolve()
      $rootScope.$broadcast 'updated_time_periods'
    deferred.promise


  return
]
