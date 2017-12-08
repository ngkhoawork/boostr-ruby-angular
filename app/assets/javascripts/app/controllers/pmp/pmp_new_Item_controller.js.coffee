@app.controller 'PmpNewItemController',
  ['$scope', '$modalInstance', 'item', 'pmpId', 'PMPItem', 'SSP'
  ($scope,    $modalInstance,   item,   pmpId,   PMPItem,   SSP) ->
    $scope.formType = 'New'
    $scope.submitText = 'Create'
    $scope.item = item || {}
    $scope.ssps = []

    init = () ->
      if !_.isEmpty(item)
        item.ssp_id = item.ssp.id
        $scope.formType = 'Edit'
        $scope.submitText = 'Update'
      SSP.all().then (ssps) ->
        $scope.ssps = ssps

    $scope.submitForm = () ->
      # validates empty fields
      $scope.errors = {}
      fields = ['ssp_id', 'ssp_deal_id', 'budget_loc']
      titles = ['SSP', 'Deal-ID', 'Budget']
      fields.forEach (key) ->
        field = $scope.item[key]
        title = titles[_.indexOf(fields, key)]
        if !field then $scope.errors[key] = title + ' is required'
      if !_.isEmpty($scope.errors) then return

      if $scope.formType == 'New'
        createPmpItem()
      else
        updatePmpItem()

    createPmpItem = () ->
      PMPItem.create(pmp_id: pmpId, pmp_item: $scope.item).then(
        (item) ->
          $modalInstance.close(item)
        (resp) ->
          for key, error of resp.data.errors
            $scope.errors[key] = error && error[0]
      )

    updatePmpItem = () ->
      PMPItem.update(pmp_id: pmpId, id: $scope.item.id, pmp_item: $scope.item).then(
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
