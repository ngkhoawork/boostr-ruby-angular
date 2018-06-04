@app.controller 'PmpNewItemController',
  ['$scope', '$modalInstance', 'CustomFieldNames', 'item', 'pmpId', 'PMPItem', 'SSP', 'PMPType', 'Product', 'Company'
  ($scope,    $modalInstance, CustomFieldNames,   item,   pmpId,   PMPItem,   SSP,   PMPType,   Product, Company) ->
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
        if !_.isEmpty(item)
          $scope.productsByLevelEdit(0,item.product)
          $scope.productsByLevelEdit(1,item.product)
          $scope.productsByLevelEdit(2,item.product)
      CustomFieldNames.all({subject_type: 'pmp_item', show_on_modal: true}).then (pmpItemcustomFieldNames) ->
        $scope.pmpItemcustomFieldNames = pmpItemcustomFieldNames
      Company.get().$promise.then (company) ->
        $scope.company = company
        $scope.productOptionsEnabled = company.product_options_enabled
        $scope.productOption1Enabled = company.product_option1_enabled
        $scope.productOption2Enabled = company.product_option2_enabled
        $scope.option1Field = company.product_option1_field || 'Option1'
        $scope.option2Field = company.product_option2_field || 'Option2'

    $scope.productsByLevel = (level) ->
      _.filter $scope.products, (p) ->
        if level == 0
          p.level == level
        else if level == 1
          p.level == 1 && p.parent_id == $scope.item.product0
        else if level == 2
          p.level == 2 && p.parent_id == $scope.item.product1

    $scope.productsByLevelEdit = (level, product)->
      _.filter $scope.products, (p) ->
        if level == 0
          $scope.item.product0 = product.level0.id
          p.level == level
        else if level == 1
          $scope.item.product1 = product.level1.id
          p.level == 1 && p.parent_id == product.level0.id
        else if level == 2
          $scope.item.product2 = product.level2.id
          p.level == 2 && p.parent_id == product.level1.id

    $scope.onChangeProduct = (item, model) ->
      if item
        $scope.item.product_id = item.id
        if item.level == 0
          $scope.item.product1 = null
          $scope.item.product2 = null
        else if item.level == 1
          $scope.item.product2 = null
      else
        if !$scope.item.product1
          $scope.item.product_id = $scope.item.product0
          $scope.item.product2 = null
        else if !$scope.item.product2
          $scope.item.product_id = $scope.item.product1

    $scope.hasSubProduct = (level) ->
      if $scope.productOptionsEnabled && subProduct = _.find($scope.products, (p) ->
        (!level || p.level == level) && p.parent_id == $scope.item.product_id)
        return subProduct

    $scope.selectedProduct = () ->
      _.find $scope.products, (p) -> p.id == $scope.item.product_id

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

      if $scope.company.product_options_enabled
        if !$scope.item.product_id
          $scope.errors['product_id'] = 'Product is required'
        else if subProduct = $scope.hasSubProduct()
          if subProduct.level == 1 && $scope.company.product_option1_enabled
            $scope.errors['product' + 1] = $scope['option' + 1 + 'Field'] + ' is required'
          if subProduct.level == 2 && $scope.company.product_option2_enabled
            $scope.errors['product' + 2] = $scope['option' + 2 + 'Field'] + ' is required'

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
