@app.controller 'DataImportExportController',
['$scope', '$modal', '$window', 'CsvImportLogs'
($scope, $modal, $window, CsvImportLogs) ->

  $scope.csvImportLogsUrl = 'api/csv_import_logs'
  $scope.csvImportLogsUrlParams = {
    source: 'ui'
  }

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
        metadata: ->
          false

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
        metadata: ->
          false

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
        metadata: ->
          false

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
        metadata: ->
          false

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
        metadata: ->
          false

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
        metadata: ->
          false

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
        metadata: ->
          false

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
        metadata: ->
          false

  $scope.showUploadIOContentFeeModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/io_content_fee_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/ios/import_content_fee'
        custom_fields_api: ->
          undefined
        metadata: ->
          false

  $scope.showUploadIOCostsModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/io_costs_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/ios/import_costs'
        custom_fields_api: ->
          undefined
        metadata: ->
          false

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
        metadata: ->
          false

  $scope.showUploadUsersModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/users_import.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/users/import'
        custom_fields_api: ->
          undefined
        metadata: ->
          false

  $scope.showUploadAssetsModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/assets_upload.html'
      size: 'lg'
      controller: 'AssetsUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.showUploadAssetMappingModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/asset_mapping_import.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/assets'
        custom_fields_api: ->
          undefined
        metadata: ->
          true

  $scope.showUploadQuotasModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/quotas_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/quotas/import'
        custom_fields_api: ->
          undefined
        metadata: ->
          false

  $scope.showUploadInfluencersModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/influencer_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/influencers'
        custom_fields_api: ->
          undefined
        metadata: ->
          false
  $scope.showUploadInfluencerContentFeesModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/influencer_content_fee_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/influencer_content_fees/import'
        custom_fields_api: ->
          undefined
        metadata: ->
          false
          
  $scope.showUploadPublisherModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/publisher_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/publisher_daily_actuals/import'
        custom_fields_api: ->
          undefined
        metadata: ->
          false

  $scope.showUploadPmpItemDailyActualsModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/pmp_item_daily_actual_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/pmp_item_daily_actuals/import'
        custom_fields_api: ->
          undefined
        metadata: ->
          false

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

  $scope.exportInfluencers = ->
    $window.open('/api/influencers.csv')
    return true

  $scope.exportIOCosts = ->
    $window.open('/api/ios/costs.csv')
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
