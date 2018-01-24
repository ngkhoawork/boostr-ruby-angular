@app.controller 'PmpItemNewDailyActualController',
  ['$scope', '$modalInstance', 'dailyActual', 'pmpId', 'pmpItems', 'PMPItemDailyActual'
  ($scope,    $modalInstance,   dailyActual,   pmpId,   pmpItems,   PMPItemDailyActual) ->
    $scope.formType = 'New'
    $scope.submitText = 'Create'
    $scope.dailyActual = dailyActual || {}
    $scope.pmpItems = pmpItems || []

    init = () ->
      if !_.isEmpty(dailyActual)
        $scope.formType = 'Edit'
        $scope.submitText = 'Update'

    $scope.submitForm = () ->
      # validates empty fields
      $scope.errors = {}
      fields = ['date', 'pmp_item_id', 'ad_unit', 'bids', 'impressions', 'price', 'revenue_loc']
      titles = ['Date', 'Deal-ID', 'Ad Unit/Product', 'Bids', 'Impressions', 'eCPM', 'Revenue']
      fields.forEach (key) ->
        field = $scope.dailyActual[key]
        title = titles[_.indexOf(fields, key)]
        if !field then $scope.errors[key] = title + ' is required'
      if !_.isEmpty($scope.errors) then return

      updatePmpItemDailyActual()

    updatePmpItemDailyActual = () ->
      PMPItemDailyActual.update(pmp_id: pmpId, id: $scope.dailyActual.id, pmp_item_daily_actual: $scope.dailyActual).then(
        (pmp) ->
          $modalInstance.close(pmp)
        (resp) ->
          for key, error of resp.data.errors
            $scope.errors[key] = error && error[0]
      )

    $scope.closeModal = () ->
      $modalInstance.dismiss()

    init()
  ]
