@app.controller "CsvUploadController",
['$scope', '$rootScope', '$modalInstance', '$timeout', 'Client', 'Upload', 'Transloadit', '$http', 'api_url'
($scope, $rootScope, $modalInstance, $timeout, Client, Upload, Transloadit, $http, api_url) ->

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

    if not isValidFileName file.name
      uploadError('Unable to upload file. This file type is not supported')
      return

    if not isValidFileSize file.size
      uploadError('File size must be below 100 megabytes')
      return

    $scope.uploading = Transloadit.upload(file, {
      params: {
        auth: {
          key: 'a49408107c0e11e68f21fda8b5e9bb0a'
        },

        template_id: $rootScope.transloaditTemplate
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
        if (assemblyJson && assemblyJson.results && assemblyJson.results[':original'] && assemblyJson.results[':original'].length)
          folder = assemblyJson.results[':original'][0].id.slice(0, 2) + '/' + assemblyJson.results[':original'][0].id.slice(2) + '/'
          s3_file_path = folder + assemblyJson.results[':original'][0].url.substr(assemblyJson.results[':original'][0].url.lastIndexOf('/') + 1);

          $http.post api_url,
              file:
                s3_file_path: s3_file_path
                original_filename: assemblyJson.results[':original'][0].name

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

  isValidFileName = (name) ->
    return (/\.csv$/i).test(name.toLowerCase())

  isValidFileSize = (size) ->
    return size < 100000000

  uploadError = (msg) ->
    $scope.progressPercentage = 0;
    $scope.uploading = false
    $scope.errors.push({ message: [msg] })

  $scope.cancel = ->
    $modalInstance.close()
]
