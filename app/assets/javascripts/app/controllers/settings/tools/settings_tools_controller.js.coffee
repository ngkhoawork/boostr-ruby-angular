@app.controller 'SettingsDataImportController',
['$scope', '$modal',
($scope, $modal) ->

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
]
