@app.controller 'InfluencerBudgetDetailController',
  ['$scope', '$document', '$window', '$filter', '$location', 'Influencer', 'InfluencerContentFee',
    ($scope, $document, $window, $filter, $location, Influencer, InfluencerContentFee) ->
      $scope.report_data_items = []
      $scope.sortType = 'deal_type'
      $scope.sortReverse  = false
      $scope.totalNetAmount = 0
      $scope.totalGrossAmount = 0
      $scope.filter =
        influencer:
          id: null
          name: 'All'
        assetDate:
          startDate: null
          endDate: null
      $scope.isDateSet = false
      appliedFilter = null

      Influencer.all({}).then (data) ->
        $scope.influencers = data
        $scope.influencers.unshift({name:'All', id: null})

      $scope.datePicker =
        toString: (key) ->
          date = $scope.filter[key]
          if !date.startDate || !date.endDate then return false
          date.startDate.format('MMM D, YY') + ' - ' + date.endDate.format('MMM D, YY')

      $scope.setFilter = (key, value) ->
        if $scope.filter[key]is value
          return
        $scope.filter[key] = value

      $scope.resetFilter = ->
        $scope.filter =
          influencer:
            id: null
            name: 'All'
          assetDate:
            startDate: null
            endDate: null

      $scope.applyFilter = ->
        appliedFilter = angular.copy $scope.filter
        getReportData()

      $scope.isFilterApplied = ->
        !angular.equals $scope.filter, appliedFilter

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
          if value
            key + '=' + value
        qs = qs.join('&')
        $window.open('/api/influencer_content_fees.csv?' + qs)
        true

      getReportData = ->
        f = $scope.filter
        query =
          influencer_id: f.influencer.id
        if f.assetDate.startDate && f.assetDate.endDate
          query.asset_date_start = f.assetDate.startDate.format('YYYY-MM-DD')
          query.asset_date_end = f.assetDate.endDate.format('YYYY-MM-DD')

        InfluencerContentFee.all(query).then (data)->
          $scope.influencer_content_fees = data
          $scope.totalNetAmount = 0
          $scope.totalGrossAmount = 0
          _.each data, (item) ->
            $scope.totalGrossAmount += (parseFloat(item.gross_amount_loc) || 0)
            $scope.totalNetAmount += (parseFloat(item.net_loc) || 0)
          console.log($scope.totalGrossAmount)
          console.log($scope.totalNetAmount)

  ]