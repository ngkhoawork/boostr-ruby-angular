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

  $scope.showUploadRevenuesModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/revenue_upload.html'
      size: 'lg'
      controller: 'RevenueUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.exportClients = ->
    $window.open('/api/clients.csv')
    return true

  $scope.exportDeals = ->
    $window.open('/api/deals.csv')
    return true

#  $scope.exportContacts = ->
#    $window.open('/api/contacts.zip')
#    return true

#  $scope.exportRevenues = ->
#    $window.open('/api/revenues.zip')
#    return true

#  $scope.exportActivities = ->
#    $window.open('/api/activities.zip')
#    return true
]
