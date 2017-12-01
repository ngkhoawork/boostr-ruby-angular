@app.controller 'PmpNewItemController',
  ['$scope', '$modalInstance', 'pmp_item', 'pmp_id', 'PMPItem', 'SSP'
  ($scope,    $modalInstance,   pmp_item,   pmp_id,   PMPItem,   SSP) ->
    $scope.formType = 'New'
    $scope.submitText = 'Create'
    $scope.pmp_item = pmp_item || {}
    $scope.ssps = []

    init = () ->
      SSP.all().then (ssps) ->
        $scope.ssps = ssps

    $scope.submitForm = () ->
      # validates empty fields
      $scope.errors = {}
      fields = ['ssp_id', 'ssp_deal_id', 'budget_loc']
      titles = ['SSP', 'Deal-ID', 'Budget']
      fields.forEach (key) ->
        field = $scope.pmp_item[key]
        title = titles[_.indexOf(fields, key)]
        if !field then $scope.errors[key] = title + ' is required'
      if !_.isEmpty($scope.errors) then return

      PMPItem.create(pmp_id: pmp_id, pmp_item: $scope.pmp_item).then(
        (pmp_item) ->
          $modalInstance.close(pmp_item)
        (resp) ->
          for key, error of resp.data.errors
            $scope.errors[key] = error && error[0]
      )

    $scope.closeModal = () ->
      $modalInstance.dismiss()

    init()
  ]
