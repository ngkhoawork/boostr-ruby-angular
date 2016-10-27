@app.controller 'SettingsDataImportController',
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

  $scope.showUploadRevenueModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/revenue_upload.html'
      size: 'lg'
      controller: 'RevenueUploadController'
      backdrop: 'static'
      keyboard: false

  $scope.showUploadActivityModal = () ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/activity_upload.html'
      size: 'lg'
      controller: 'ActivityUploadController'
      backdrop: 'static'
      keyboard: false

#  $scope.showUploadDealsModal = () ->
#    $scope.modalInstance = $modal.open
#      templateUrl: 'modals/deals_upload.html'
#      size: 'lg'
#      controller: 'DealUploadController'
#      backdrop: 'static'
#      keyboard: false

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
    $window.open('/api/deals.zip')
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
