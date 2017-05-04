@app.controller 'DataImportExportController',
['$scope', '$modal', '$window',
($scope, $modal, $window) ->

  $scope.showUploadClientModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/client_upload.html'
      size: 'lg'
      controller: 'ClientsUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.showUploadContactModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_upload.html'
      size: 'lg'
      controller: 'ContactsUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.showUploadActivityModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/activity_upload.html'
      size: 'lg'
      controller: 'ActivityUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.showUploadDealsModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_upload.html'
      size: 'lg'
      controller: 'DealUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.showUploadDealProductModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_product_upload.html'
      size: 'lg'
      controller: 'DealProductUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.showUploadDealProductBudgetModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_product_budget_upload.html'
      size: 'lg'
      controller: 'DealProductBudgetUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.showUploadContactsModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/contact_upload.html'
      size: 'lg'
      controller: 'ContactsUploadController'
      backdrop: 'static'
      keyboard: false
      resolve:
        contact: ->
          {}

  $scope.showUploadDisplayIOModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/display_io_upload.html'
      size: 'lg'
      controller: 'DisplayIOUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.showUploadDisplayIOMonthlyBudgetModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/display_io_monthly_budget_upload.html'
      size: 'lg'
      controller: 'DisplayIOMonthlyBudgetUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.exportDisplayIOMonthlyBudgets = ->
    $window.open('/api/display_line_item_budgets.csv')
    return true

  $scope.exportClients = ->
    $window.open('/api/clients.csv')
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


  # TEMPORARY UPLOADERS
  $scope.showUploadSalesOrdersModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/sales_orders_upload.html'
      size: 'lg'
      controller: 'SalesOrdersUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.showUploadSalesOrderLineItemsModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/sales_order_lineitems_upload.html'
      size: 'lg'
      controller: 'SalesOrderLineItemsUploadController'
      backdrop: 'static'
      keyboard: false


#  $scope.exportContacts = ->
#    $window.open('/api/contacts.zip')
#    return true

#  $scope.exportActivities = ->
#    $window.open('/api/activities.zip')
#    return true
]
