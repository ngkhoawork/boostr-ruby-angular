@app.controller 'SettingsCurrenciesController',
['$scope', '$modal', 'Currency',
($scope, $modal, Currency) ->

  $scope.init = () ->
    $scope.getCurrencies()

  $scope.getCurrencies = () ->
    Currency.exchange_rates_by_currencies().then (currencies) ->
      $scope.active_currencies = currencies

  $scope.$on 'exchange_rates_modified', ->
    $scope.getCurrencies()

  $scope.showNewExchangeRateModal = (curr_cd = '') ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/exchange_rate_form.html'
      size: 'md'
      controller: 'ExchangeRateNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        options: ->
          curr_cd: curr_cd

  $scope.showEditExchangeRateModal = (curr_cd, exchange_rate) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/exchange_rate_form.html'
      size: 'md'
      controller: 'ExchangeRateEditController'
      backdrop: 'static'
      keyboard: false
      resolve:
        exchange_rate: ->
          exchange_rate
        options: ->
          curr_cd: curr_cd

  $scope.toggleRow = (rowId) ->
    if $scope.toggleId == rowId
      $scope.toggleId = null
    else
      $scope.toggleId = rowId

  $scope.deleteExchangeRate = (exchange_rate) ->
    console.log exchange_rate

  $scope.init()
]
