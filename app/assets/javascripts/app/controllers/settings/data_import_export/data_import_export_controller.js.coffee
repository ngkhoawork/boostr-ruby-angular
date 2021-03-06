@app.controller 'DataImportExportController',
['$scope', '$modal', '$window', 'CsvImportLogs',
($scope, $modal, $window, CsvImportLogs) ->

  $scope.csvImportLogsUrl = 'api/csv_import_logs'
  $scope.csvImportLogsUrlParams = {
    source: 'ui'
  }

  $scope.getLogs = ->
    $scope.$broadcast('pagination:reload')

  $scope.showUploadClientModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/clients/csv_import'
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
          'CustomFieldNames'
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

  $scope.showUploadContractsModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contract_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/contracts'
        custom_fields_api: ->
          undefined
        metadata: ->
          false

  $scope.showUploadContractSpecialTermsModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contract_special_terms_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/contracts/import_special_terms'
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

  $scope.showUploadLeadsModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/leads_upload.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/leads/import'
        custom_fields_api: ->
          undefined
        metadata: ->
          false

  $scope.exportDisplayIOMonthlyBudgets = ->
    $window.open('/api/display_line_item_budgets.csv')
    return true

  $scope.exportClients = ->
    $window.open('/api/clients.csv?filter=all')
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

  $scope.showUploadActivePmpItem = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/active_pmp_item.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/active_pmps/import_item'
        custom_fields_api: ->
          'CustomFieldNames'
        metadata: ->
          false

  $scope.showUploadActivePmpObject = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/active_pmp_object.html'
      size: 'lg'
      controller: 'CsvUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        api_url: ->
          '/api/active_pmps/import_object'
        custom_fields_api: ->
          undefined
        metadata: ->
          false

  $scope.exportInfluencers = ->
    $window.open('/api/influencers.csv')
    return true

  $scope.exportIOCosts = ->
    $window.open('/api/ios/export_costs.csv')
    return true

  $scope.showBodyModal = (log) ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/csv_logs_body.html'
      size: 'lg'
      controller: 'CsvLogsBodyController'
      backdrop: 'static'
      keyboard: false
      resolve:
        log: ->
          log

  $scope.importOptions = [
    { title: 'Accounts Import', click: $scope.showUploadClientModal, linkText: 'Import Accounts' },
    { title: 'Activities Import', click: $scope.showUploadActivityModal, linkText: 'Import Activities' },
    { title: 'Asset Mapping Import', click: $scope.showUploadAssetMappingModal, linkText: 'Import Asset Mapping or check unmapped' },
    { title: 'Assets Import', click: $scope.showUploadAssetsModal, linkText: 'Import Compressed Assets' },
    { title: 'Contacts Import', click: $scope.showUploadContactsModal, linkText: 'Import Contacts' },
    { title: 'Contracts Import', click: $scope.showUploadContractsModal, linkText: 'Import Contracts' },
    { title: 'Contract Special Terms Import', click: $scope.showUploadContractSpecialTermsModal, linkText: 'Import Contract Special Terms' },
    { title: 'Deal Product Monthly Budget Import', click: $scope.showUploadDealProductBudgetModal, linkText: 'Import Deal Product Monthly Budget' },
    { title: 'Deal Products Import', click: $scope.showUploadDealProductModal, linkText: 'Import Deal Products' },
    { title: 'Deals Import', click: $scope.showUploadDealsModal, linkText: 'Import Deals' },
    { title: 'IO Import', click: $scope.showUploadDisplayIOModal, linkText: 'Import IOs' },
    { title: 'IO Costs Import', click: $scope.showUploadIOCostsModal, linkText: 'Import IO Costs' },
    { title: 'IO Content Fees Import', click: $scope.showUploadIOContentFeeModal, linkText: 'Import IO Content Fees' },
    { title: 'IO Monthly Product Budget Import', click: $scope.showUploadDisplayIOMonthlyBudgetModal, linkText: 'Import IO Monthly Budgets' },
    { title: 'Influencer Content Fee Import', click: $scope.showUploadInfluencerContentFeesModal, linkText: 'Import Content Fee' },
    { title: 'Influencers Import', click: $scope.showUploadInfluencersModal, linkText: 'Import Influencers' },
    { title: 'Integration ID Import', click: $scope.showUploadIntegrationIdModal, linkText: 'Import Integration IDs' },
    { title: 'Active PMP Import', click: $scope.showUploadActivePmpObject, linkText: 'Active PMP Import' },
    { title: 'Active PMP Item Import', click: $scope.showUploadActivePmpItem, linkText: 'Active PMP Item Import' }
    { title: 'PMP Daily Actual Import', click: $scope.showUploadPmpItemDailyActualsModal, linkText: 'Import PMP Daily Actual' },
    { title: 'Publishers Daily Actuals Import', click: $scope.showUploadPublisherModal, linkText: 'Publishers Daily Actuals Import' },
    { title: 'Quotas Import', click: $scope.showUploadQuotasModal, linkText: 'Import Quotas' },
    { title: 'Users Import', click: $scope.showUploadUsersModal, linkText: 'Import Users' }
  ]

  $scope.exportOptions = [
    { title: 'Accounts Export', click: $scope.exportClients, linkText: 'Export Accounts' },
    { title: 'Contacts Export', click: $scope.exportContacts, linkText: 'Export Contacts' },
    { title: 'Deal Product Monthly Budget Export', click: $scope.exportDealProductMonhtlyBudget, linkText: 'Export Deal Product Monthly Budget' },
    { title: 'Deal Products Export', click: $scope.exportDealProducts, linkText: 'Export Deal Products' },
    { title: 'Deals Export', click: $scope.exportDeals, linkText: 'Export Deals' },
    { title: 'Influencers Export', click: $scope.exportInfluencers, linkText: 'Export Influencers' },
    { title: 'IO Monthly Product Budget Export', click: $scope.exportDisplayIOMonthlyBudgets, linkText: 'Export IO Monthly Product Budgets' },
    { title: 'IO Costs Export', click: $scope.exportIOCosts, linkText: 'Export IO Costs' }
  ]

]