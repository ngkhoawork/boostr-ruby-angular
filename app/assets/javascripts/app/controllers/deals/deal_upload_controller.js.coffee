@app.controller "DealUploadController",
['$scope', '$rootScope', '$modalInstance', '$timeout', 'Deal', 'Upload',
($scope, $rootScope, $modalInstance, $timeout, Deal, Upload) ->

  $scope.progressPercentage = 0
  $scope.errors = []
  $scope.uploading = false;
  $scope.$watch 'files', ->
    $scope.upload($scope.files)

  $scope.upload = (files) ->
    $scope.progressPercentage = 0;
    $scope.errors = []
    if files and files.length
      i = 0
      $scope.uploading = true;
      while i < files.length
        file = files[i]
        Upload.upload(
          url: '/api/deals'
          file: file
        ).progress((evt) ->
          percentage = parseInt(100.0 * evt.loaded / evt.total)
          if percentage > 90
            if $scope.progressPercentage < 90
              $scope.progressPercentage = 90
            else
              $scope.progressPercentage = $scope.progressPercentage + 2
          else
            $scope.progressPercentage = percentage
        ).success (data, status, headers, config) ->
          $scope.errors = data;
          $scope.progressPercentage = 100
          $scope.uploading = false;

          $timeout ->
            $rootScope.$broadcast 'updated_deals'
        i++

  $scope.cancel = ->
    $modalInstance.close()
]