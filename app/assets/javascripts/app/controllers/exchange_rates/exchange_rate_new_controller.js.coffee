@app.controller 'ExchangeRateNewController',
['$scope', '$rootScope', '$modalInstance', 'Currency', 'ExchangeRate', 'options',
($scope, $rootScope, $modalInstance, Currency, ExchangeRate, options) ->
  $scope.formType = 'New'
  $scope.submitText = 'Create'
  $scope.popupTitle = 'Add New Exchange Rate'
  $scope.form = {
    start_date: new Date()
    end_date: new Date()
  }
  Currency.all().then (currencies) ->
    if options.curr_cd
      exchange_rate_currency = _.find currencies, (currency) ->
        currency.curr_cd == options.curr_cd
      $scope.currencies = [exchange_rate_currency]
      $scope.selectCurrency(exchange_rate_currency)
      $scope.dropdown_disabled = true
    else
      $scope.currencies = _.reject currencies, (currency) ->
        currency.curr_cd == 'USD'

  $scope.selectCurrency = (currency) ->
    $scope.selectedCurrency = currency
    $scope.form.currency_id = currency.id

  $scope.submitForm = ->
    $scope.errors = {}
    fields = ['currency_id', 'rate', 'start_date', 'end_date']

    fields.forEach (key) ->
      field = $scope.form[key]
      switch key
        when 'currency_id'
          if !field
            return $scope.errors[key] = 'Currency is required'
        when 'rate'
          if !field
            return $scope.errors[key] = 'Rate is required'
        when 'start_date'
          if !field
            return $scope.errors[key] = 'Start Date is required'
          if field > $scope.form.end_date
            return $scope.errors[key] = 'should precede End Date'
        when 'end_date'
          if !field
            return $scope.errors[key] = 'End Date is required'
          if field < $scope.form.start_date
            return $scope.errors[key] = 'can\'t precede Start Date'

    return if Object.keys($scope.errors).length > 0

    exchange_rate_data =
      currency_id: $scope.selectedCurrency.id
      rate: $scope.form.rate
      start_date: $scope.form.start_date
      end_date: $scope.form.end_date

    createExchangeRate(exchange_rate_data)

  createExchangeRate = (data) ->
    ExchangeRate.create(data).then (exchange_rate) ->
      $scope.cancel()
      $rootScope.$broadcast 'exchange_rates_modified'

  $scope.cancel = ->
    $modalInstance.close()
]
