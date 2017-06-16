@app.controller 'DataImportExportController',
['$scope', '$modal', '$window', 'CsvImportLogs'
($scope, $modal, $window, CsvImportLogs) ->

  $scope.logs = []

  $scope.getLogs = () ->
    CsvImportLogs.all(source: 'ui').then (logs) ->
      $scope.logs = logs

  $scope.showUploadClientModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/clients'
        custom_fields_api: ->
          'AccountCfName'

  $scope.showUploadActivityModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/activity_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/activities'
        custom_fields_api: ->
          undefined

  $scope.showUploadDealsModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/deals'
        custom_fields_api: ->
          'DealCustomFieldName'

  $scope.showUploadDealProductModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_product_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/deal_products'
        custom_fields_api: ->
          'DealProductCfName'

  $scope.showUploadDealProductBudgetModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_product_budget_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/deal_product_budgets'
        custom_fields_api: ->
          undefined

  $scope.showUploadContactsModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/contacts'
        custom_fields_api: ->
          undefined

  $scope.showUploadDisplayIOModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/display_io_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/display_line_items'
        custom_fields_api: ->
          undefined

  $scope.showUploadDisplayIOMonthlyBudgetModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/display_io_monthly_budget_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/display_line_item_budgets'
        custom_fields_api: ->
          undefined

  $scope.showUploadIntegrationIdModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/integration_id_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/integrations'
        custom_fields_api: ->
          undefined

  $scope.exportDisplayIOMonthlyBudgets = ->
    $window.open('/api/display_line_item_budgets.csv')
    return true

  $scope.exportClients = ->
    $window.open('/api/clients.csv')
    return true

  $scope.exportContacts = ->
    $window.open('/api/contacts.csv')
    return true

  $scope.exportDeals = ->
    $window.open('/api/deals.csv')
    return true

  $scope.exportDealProducts = ->
    $window.open('/api/deal_products.csv')
    return true

  $scope.exportDealProductMonhtlyBudget = ->
    $window.open('/api/deal_product_budgets.csv')
    return true

  $scope.showBodyModal = (body) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/csv_logs_body.html'
      size: 'lg'
      controller: 'CsvLogsBodyController'
      backdrop: 'static'
      keyboard: false
      resolve:
        body: ->
          body
]
