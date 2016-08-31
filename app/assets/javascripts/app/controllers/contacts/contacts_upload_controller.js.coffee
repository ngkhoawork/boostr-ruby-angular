@app.controller "ContactsUploadController",
['$scope', '$rootScope', '$modalInstance', '$timeout', 'Contact', 'Upload',
($scope, $rootScope, $modalInstance, $timeout, Contact, Upload) ->

  $scope.progressPercentage = 0
  $scope.errors = []

  $scope.$watch 'files', ->
    $scope.upload($scope.files)

  $scope.upload = (files) ->
    if files and files.length
      i = 0
      while i < files.length
        file = files[i]
        Upload.upload(
          url: '/api/contacts'
          file: file
        ).progress((evt) ->
            $scope.progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
        ).success (data, status, headers, config) ->
          $scope.errors = data;

          $timeout ->
            $rootScope.$broadcast 'updated_clients'
        i++

  $scope.cancel = ->
    $modalInstance.close()
]