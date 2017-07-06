@app.controller 'InfluencerBudgetDetailController',
  ['$scope', '$document', '$window', '$filter', '$location', 'Influencer', 'InfluencerContentFee',
    ($scope, $document, $window, $filter, $location, Influencer, InfluencerContentFee) ->
      $scope.report_data_items = []
      $scope.sortType = 'deal_type'
      $scope.sortReverse  = false
      $scope.filter =
        influencer: {id: null, name: 'All'}

      $scope.isDateSet = false

      Influencer.all({}).then (data) ->
        $scope.influencers = data
        $scope.influencers.unshift({name:'All', id: null})

      $scope.setFilter = (key, value) ->
        if $scope.filter[key]is value
          return
        $scope.filter[key] = value

      $scope.resetFilter = ->
        $scope.filter =
          influencer: {id: null, name: 'All'}

      $scope.applyFilter = ->
        getReportData()

      $scope.go = (path) ->
        $location.path(path)

      $scope.changeSortType = (sortType) ->
        if sortType == $scope.sortType
          $scope.sortReverse = !$scope.sortReverse
        else
          $scope.sortType = sortType
          $scope.sortReverse = false

      query = null
      $scope.exportReports = ->
        qs = for key, value of query
          key + '=' + value
        qs = qs.join('&')
        $window.open('/api/influencer_content_fees.csv?' + qs)
        true

      getReportData = ->
        f = $scope.filter
        query =
          influencer_id: f.influencer.id

        InfluencerContentFee.all(query).then (data)->
          $scope.influencer_content_fees = data

  ]