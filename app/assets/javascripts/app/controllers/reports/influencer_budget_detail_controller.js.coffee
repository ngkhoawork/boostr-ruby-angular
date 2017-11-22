@app.controller 'InfluencerBudgetDetailController',
  ['$scope', '$window', '$httpParamSerializer', 'Influencer', 'InfluencerContentFee',
  ( $scope,   $window,   $httpParamSerializer,   Influencer,   InfluencerContentFee) ->
      $scope.report_data_items = []
      $scope.totalNetAmount = 0
      $scope.totalGrossAmount = 0
      appliedFilter = null

      Influencer.all({}).then (data) ->
        $scope.influencers = data

      $scope.onFilterApply = (query) ->
        appliedFilter = query
        getReport query

      parseData = (data) ->
        $scope.totalNetAmount = 0
        $scope.totalGrossAmount = 0
        _.each data, (item) ->
          $scope.totalGrossAmount += (parseFloat(item.gross_amount_loc) || 0)
          $scope.totalNetAmount += (parseFloat(item.net_loc) || 0)
          if item.content_fee
            item.content_fee.budget_loc = parseFloat(item.content_fee.budget_loc) || 0
          item.fee_amount = parseFloat(item.fee_amount) || 0
          item.fee_amount_loc = parseFloat(item.fee_amount_loc) || 0
          item.gross_amount_loc = parseFloat(item.gross_amount_loc) || 0
          item.net_loc = parseFloat(item.net_loc) || 0
          item

      $scope.export = ->
        url = '/api/influencer_content_fees.csv'
        $window.open url + '?' + $httpParamSerializer appliedFilter
        return

      getReport = (query) ->
        InfluencerContentFee.all(query).then (data)->
          parseData(data)
          $scope.influencer_content_fees = data

  ]