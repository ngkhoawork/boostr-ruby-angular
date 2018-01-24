@app.controller "SettingsQuotasNewController",
['$scope', '$modalInstance', '$q', '$filter', 'Quota', 'User', 'TimePeriod', 'timePeriod', 'quotas', 'Product', 'ProductFamily',
($scope, $modalInstance, $q, $filter, Quota, User, TimePeriod, timePeriod, quotas, Product, ProductFamily) ->

  init = () ->
    $scope.formType = "New"
    $scope.submitText = "Create"
    $scope.types = ['gross', 'net']
    $scope.quota =
      time_period_id: timePeriod.id
    $q.all({
      time_periods: TimePeriod.all()
      users: User.query().$promise
      products: Product.all()
      product_families: ProductFamily.all()
    }).then (data) ->
      $scope.timePeriods = data.time_periods
      $scope.users = data.users
      $scope.products = data.products
      $scope.productFamilies = data.product_families

  $scope.submitForm = () ->
    if validateForm()
      if $scope.quota.product_type == 'ProductFamily'
        $scope.quota.product_id = $scope.quota.product_family_id
      Quota.create(quota: $scope.quota).then (quota) ->
        $modalInstance.close()

  $scope.onSelectProduct = () ->
    $scope.quota.product_family_id = null
    $scope.quota.product_type = 'Product'

  $scope.onSelectProductFamily = () ->
    $scope.quota.product_id = null
    $scope.quota.product_type = 'ProductFamily'

  validateForm = () ->
    $scope.errors = {}
    fields = ['time_period_id', 'user_id', 'value_type', 'value']
    labels = ['Time period', 'User', 'Type', 'Quota']

    fields.forEach (key, index) ->
      if !$scope.quota[key]
        $scope.errors[key] = "#{labels[index]} is required"

    return _.isEmpty($scope.errors)

  $scope.cancel = ->
    $modalInstance.dismiss()

  init()

]
