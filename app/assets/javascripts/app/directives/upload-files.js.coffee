@directives.directive 'uploadFile', ['$timeout', '$http', 'Transloadit'
  ($timeout, $http, Transloadit) ->
    restrict: 'E'
    templateUrl: 'directives/upload-files.html'
    scope:
      dealFiles: '='
    controller: ($scope, $routeParams) ->
      $scope.progressBarCur = 0
      $scope.uploadedFiles = []
      $scope.dealFiles = []

      $scope.uploadFile =
        name: null
        size: null
        status: 'EMPTY' # LOADING ERROR, SUCCESS, ABORT

      $scope.callUpload = (event) ->
        if $scope.uploadFile.status == 'LOADING'
          return

        $timeout ->
          document.getElementById 'file-uploader'
            .click()
          do event.preventDefault
        , 0

        $scope.changeFile = (element) ->
          $scope.$apply (scope) ->
            scope.upload element.files[0]

        $scope.deleteFile = (file) ->
          if (file && file.id)
            $http.delete('/api/deals/'+ $routeParams.id + '/deal_assets/' + file.id)
            .then (respond) ->
              console.log('del file', respond)
              $scope.dealFiles = $scope.dealFiles.filter (dealFile) ->
                return dealFile.id != file.id

        $scope.upload = (file) ->
          if not file or 'name' not of file
            return

          # console.log 'file', file
          $scope.progressBarCur = 0
          $scope.uploadFile.status = 'LOADING'
          $scope.uploadFile.name = file.name
          $scope.uploadFile.size = file.size

          $scope.uploading = Transloadit.upload(file, {
            params: {
              auth: {
                key: 'a49408107c0e11e68f21fda8b5e9bb0a'
              },

              template_id: '689738007e6b11e693c6c33c0cd97f1d'
            },

            signature: (callback) ->
      #       ideally you would be generating this on the fly somewhere
              callback 'here-is-my-signature'
            ,

            progress: (loaded, total) ->
              $scope.uploadFile.size = total
              $scope.progressBarCur = loaded
              $scope.$$phase || do $scope.$apply;
            ,

            processing: () ->
              console.info 'done uploading, started processing'
            ,

            uploaded: (assemblyJson) ->
              if (assemblyJson && assemblyJson.results && assemblyJson.results[':original'] && assemblyJson.results[':original'].length)
                # console.log assemblyJson.results[':original'][0]
                folder = assemblyJson.results[':original'][0].id.slice(0, 2) + '/' + assemblyJson.results[':original'][0].id.slice(2) + '/'
                fullFileName = folder + assemblyJson.results[':original'][0].name
              $http.post('/api/deals/'+ $routeParams.id + '/deal_assets',
                {
                  asset:
                    asset_file_name: fullFileName
                    asset_file_size: assemblyJson.results[':original'][0].size
                    asset_content_type: assemblyJson.results[':original'][0].mime
                    original_file_name: assemblyJson.results[':original'][0].name
                })
                .then (response) ->
                  console.log(response.data)
      #            $scope.uploadedFiles.push response.data
                  $scope.dealFiles.push response.data

              $scope.uploadFile.status = 'SUCCESS'
              # console.log "$scope.uploadFile.status", $scope.uploadFile.status
              # console.log('uploaded', assemblyJson)
              $timeout (->
                $scope.progressBarCur = 0
                return
              ), 2000
              $scope.$$phase || $scope.$apply()
            ,

            cancel: () ->
              console.info 'upload canceled by user'
              $scope.uploadFile.status = 'ABORT'

            error: (error) ->
              $scope.uploadFile.status = 'ERROR'
              console.log('error', error)
              $scope.$$phase || $scope.$apply()

          })
          console.log '$scope.uploading', $scope.uploading
    link: (scope, element, attrs) ->
      scope.dealFiles = element.dealFiles
]