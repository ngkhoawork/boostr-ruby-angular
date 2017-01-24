@app.controller 'ExchangeRateEditController',
['$scope', '$rootScope', '$modalInstance', 'Currency', 'ExchangeRate', 'options', 'exchange_rate',
($scope, $rootScope, $modalInstance, Currency, ExchangeRate, options, exchange_rate) ->
  $scope.formType = 'Edit'
  $scope.submitText = 'Update'
  $scope.popupTitle = "Edit #{options.curr_cd} Exchange Rate to USD"

  if exchange_rate
    $scope.form = {
      start_date: new Date(exchange_rate.start_date)
      end_date: new Date(exchange_rate.end_date)
      rate: Number(exchange_rate.rate)
    }

  Currency.all().then (currencies) ->
    exchange_rate_currency = _.find currencies, (currency) ->
      currency.curr_cd == options.curr_cd
    $scope.currencies = [exchange_rate_currency]
    $scope.selectCurrency(exchange_rate_currency)
    $scope.dropdown_disabled = true

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

    $scope.buttonDisabled = true
    updateExchangeRate(exchange_rate_data)

  updateExchangeRate = (data) ->
    ExchangeRate.update(id: exchange_rate.id, exchange_rate: data).then(
      (exchange_rate) ->
        $scope.cancel()
        $rootScope.$broadcast 'exchange_rates_modified'
      (resp) ->
        for key, error of resp.data.errors
          $scope.errors[key] = error && error[0]
        $scope.buttonDisabled = false
    )

  $scope.cancel = ->
    $modalInstance.close()
]
