@service.service 'TimePeriod',
['$resource', '$rootScope', '$q',
($resource, $rootScope, $q) ->

  resource = $resource '/api/time_periods/:id', { id: '@id' }

  allTimePeriods = []

  @all = ->
    deferred = $q.defer()
    if allTimePeriods.length == 0
      resource.query {}, (time_periods) =>
        allTimePeriods = time_periods
        deferred.resolve(time_periods)
    else
      deferred.resolve(allTimePeriods)
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
