@app.controller 'PmpNewItemController',
  ['$scope', '$modalInstance', 'CustomFieldNames', 'item', 'pmpId', 'PMPItem', 'SSP', 'PMPType', 'Product'
  ($scope,    $modalInstance, CustomFieldNames,   item,   pmpId,   PMPItem,   SSP,   PMPType,   Product) ->
    $scope.formType = 'New'
    $scope.submitText = 'Create'
    $scope.item = item || {}
    $scope.ssps = []
    $scope.products = []
    $scope.pmpTypes = PMPType.all

    init = () ->
      if !_.isEmpty(item)
        if item.custom_field
          item.pmp_item_custom_field_obj = item.custom_field
        $scope.item.product_id = item.product && item.product.id
        $scope.item.ssp_id = item.ssp && item.ssp.id
        $scope.formType = 'Edit'
        $scope.submitText = 'Update'
      SSP.all().then (ssps) ->
        $scope.ssps = ssps
      Product.all(revenue_type: 'PMP', active: true).then (data) ->
        $scope.products = data
      CustomFieldNames.all({subject_type: 'pmp_item', show_on_modal: true}).then (pmpItemcustomFieldNames) ->
        $scope.pmpItemcustomFieldNames = pmpItemcustomFieldNames

    $scope.submitForm = () ->
      # validates empty fields
      $scope.errors = {}
      fields = ['ssp_id', 'ssp_deal_id', 'budget_loc', 'pmp_type', 'product_id']
      titles = ['SSP', 'Deal-ID', 'Budget', 'PMP Type', 'Product']
      fields.forEach (key) ->
        field = $scope.item[key]
        title = titles[_.indexOf(fields, key)]
        if !field then $scope.errors[key] = title + ' is required'
      if !_.isEmpty($scope.errors) then return

      $scope.pmpItemcustomFieldNames.forEach (item) ->
        if item.is_required && !item.disabled && (!$scope.item.pmp_item_custom_field_obj || !$scope.item.pmp_item_custom_field_obj[item.field_name])
          $scope.errors[item.field_name] = item.field_label + ' is required'

      if $scope.formType == 'New'
        createPmpItem()
      else
        updatePmpItem()

    createPmpItem = () ->
      return if !angular.equals({}, $scope.errors)

      $scope.item.custom_field_attributes = $scope.item.pmp_item_custom_field_obj
      PMPItem.create(pmp_id: pmpId, pmp_item: $scope.item).then(
        (item) ->
          $modalInstance.close(item)
        (resp) ->
          for key, error of resp.data.errors
            $scope.errors[key] = error && error[0]
      )

    updatePmpItem = () ->
      return if !angular.equals({}, $scope.errors)

      $scope.item.custom_field_attributes = $scope.item.pmp_item_custom_field_obj
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
