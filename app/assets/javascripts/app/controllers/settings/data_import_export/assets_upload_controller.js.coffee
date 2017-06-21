@app.controller "AssetsUploadController",
['$scope', '$rootScope', '$injector', '$modalInstance', '$timeout', 'Client', 'Upload', 'Transloadit', '$http',
($scope, $rootScope, $injector, $modalInstance, $timeout, Client, Upload, Transloadit, $http) ->

  $scope.progressPercentage = 0
  $scope.files = []
  $scope.errors = []
  $scope.uploading = false;
  $scope.$watch 'files', ->
    if $scope.files and $scope.files.length
      $scope.upload($scope.files[0])

  $scope.upload = (file) ->
    $scope.progressPercentage = 0
    $scope.errors = []
    $scope.is_uploading = true

    if not isValidFileSize file.size
      uploadError('File size must be below 1 Gigabyte')
      return

    $scope.uploading = Transloadit.upload(file, {
      params: {
        auth: {
          key: 'a49408107c0e11e68f21fda8b5e9bb0a'
        },

        template_id: $rootScope.transloaditTemplates.store_archive
      },

      signature: (callback) ->
        # ideally you would be generating this on the fly somewhere
        callback 'here-is-my-signature'
      ,

      progress: (loaded, total) ->
        # $scope.uploadFile.size = total
        $scope.progressPercentage = Math.round((loaded / total) * 100)
        $scope.$$phase || $scope.$apply();
      ,

      processing: () ->
        console.info 'done uploading, started processing'
      ,

      uploaded: (assemblyJson) ->
        if (assemblyJson && assemblyJson.results && assemblyJson.results['files'] && assemblyJson.results['files'].length)
          results = []
          results.push formatName(file) for file in assemblyJson.results['files']

          $http.post '/api/assets', assets: results
            .then (response) ->
              $scope.messages = response.data
              $scope.progressPercentage = 100
              $scope.is_uploading = false

        $scope.$$phase || $scope.$apply()
      ,

      error: (error) ->
        console.error('Error from transloadit', error)
        $scope.$$phase || $scope.$apply()

      })

  isValidFileSize = (size) ->
    return size < 1000000000

  uploadError = (msg) ->
    $scope.progressPercentage = 0;
    $scope.uploading = false
    $scope.errors.push({ message: [msg] })

  formatName = (file) ->
    folder = file.id.slice(0, 2) + '/' + file.id.slice(2) + '/'
    s3_file_path = folder + file.url.substr(file.url.lastIndexOf('/') + 1)

    {
      asset_file_name: s3_file_path
      asset_file_size: file.size
      asset_content_type: file.mime
      original_file_name: file.name
    }

  $scope.cancel = ->
    $modalInstance.close()

]
