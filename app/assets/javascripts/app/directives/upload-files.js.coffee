@directives.directive 'uploadFile', ['$rootScope', '$timeout', '$http', 'Transloadit', 'Field', '$filter'
  ($rootScope, $timeout, $http, Transloadit, Field, $filter) ->
    restrict: 'E'
    templateUrl: 'directives/upload-files.html'
    scope:
      dealFiles: '='
      type: "@"
    controller: ($scope, $routeParams) ->
      $scope.fileToUpload = null
      $scope.progressBarCur = 0
      $scope.dealFiles = []
      $scope.uploadError = 'Connection lost'
      $scope.uploadShow = false;
      $scope.uploaded = false;
      $scope.assemblyJson = undefined;

      # $scope.subType = {};
      $scope.subTypes = [];

      Field.defaults {}, 'Multiple'
        .then (resp) ->
          $scope.subTypes = resp[0].options

      $scope.uploadFile =
        name: null
        size: null
        status: 'EMPTY' # LOADING ERROR, SUCCESS, ABORT

      $scope.retry = () ->
        $scope.upload($scope.fileToUpload)

      $scope.callUpload = (event) ->
        if $scope.uploadFile.status == 'LOADING'
          return

        $timeout ->
          document.getElementById 'file-uploader'
            .click()
          do event.preventDefault
        , 0

      $scope.changeFile = (e) ->
        $scope.$apply (scope) ->
          scope.upload e.target.files[0]

      returnUrlByType = () ->


      $scope.deleteFile = (file) ->
        if (file && file.id && confirm('Are you sure you want to delete "' +  file.original_file_name + '"?'))
          switch $scope.type
            when "contract"
              url = '/api/contracts/'+ $routeParams.id + '/attachments/' + file.id + '?type=' + $scope.type
            when "publisher"
              url = '/api/publishers/'+ $routeParams.id + '/attachments/' + file.id + '?type=' + $scope.type
            else
              url = '/api/deals/'+ $routeParams.id + '/attachments/' + file.id + '?type=' + $scope.type

          $http.delete url
          .then (respond) ->
            $scope.dealFiles = $scope.dealFiles.filter (dealFile) ->
              return dealFile.id != file.id

      $scope.saveOnServer = (file, subtype) ->
        switch $scope.type
          when "contract"
            url = '/api/contracts/'+ $routeParams.id + '/attachments/' + file.id
          when "publisher"
            url = '/api/publishers/'+ $routeParams.id + '/attachments/' + file.id
          else
            url = '/api/deals/'+ $routeParams.id + '/attachments/' + file.id

        $http.put url,
          type: $scope.type,
          asset:
            asset_file_name: file.asset_file_name
            asset_file_size: file.asset_file_size
            asset_content_type: file.asset_content_type
            original_file_name: file.original_file_name
            comment: file.comment
            subtype: file.subtype?.name || ''


      $scope.upload = (file) ->
        if not file or 'name' not of file
          alert 'Wrong file'
          return

        $scope.uploaded = false
        $scope.fileToUpload = file
        $scope.uploadFile.name = file.name
        $scope.uploadFile.size = file.size
        $scope.uploadShow = true;

        if not isValidFileName file
          $scope.uploadFile.status = 'ERROR'
          $scope.uploadError = 'Unable to upload a file: This file type is not supported'
          return

        if not isValidFileSize file
          $scope.uploadFile.status = 'ERROR'
          $scope.uploadError = 'Unable to upload a file: This file is too large to upload'
          return

        $scope.progressBarCur = 0
        $scope.uploadFile.status = 'LOADING'

        $scope.uploading = Transloadit.upload(file, {
          params: {
            auth: {
              key: 'a49408107c0e11e68f21fda8b5e9bb0a'
            },

            template_id: $rootScope.transloaditTemplates.store_single
          },

          signature: (callback) ->
            # ideally you would be generating this on the fly somewhere
            callback 'here-is-my-signature'
          ,

          progress: (loaded, total) ->
            $scope.uploadFile.size = total
            $scope.progressBarCur = loaded
            $scope.$$phase || $scope.$apply();
          ,

          processing: () ->
            console.info 'done uploading, started processing'
          ,

          uploaded: (assemblyJson) ->
            $scope.uploaded = true
            $scope.uploadFile.status = 'SUCCESS'

            if (assemblyJson && assemblyJson.results && assemblyJson.results[':original'] && assemblyJson.results[':original'].length)
              folder = assemblyJson.results[':original'][0].id.slice(0, 2) + '/' + assemblyJson.results[':original'][0].id.slice(2) + '/'
              fullFileName = folder + assemblyJson.results[':original'][0].url.substr(assemblyJson.results[':original'][0].url.lastIndexOf('/') + 1);

            switch $scope.type
              when "contract"
                url = '/api/contracts/'+ $routeParams.id + '/attachments'
              when "publisher"
                url = '/api/publishers/'+ $routeParams.id + '/attachments'
              else
                url = '/api/deals/'+ $routeParams.id + '/attachments'

            $http.post url,
                type: $scope.type,
                asset:
                  asset_file_name: fullFileName
                  asset_file_size: assemblyJson.results[':original'][0].size
                  asset_content_type: assemblyJson.results[':original'][0].mime
                  original_file_name: assemblyJson.results[':original'][0].name
                  # comment: $scope.comment
                  # subtype: $scope.subType.selected.name
              .then (response) ->
                $scope.dealFiles.push response.data

                $scope.progressBarCur = 0
                $scope.uploadFile.status = 'EMPTY'
                $scope.uploadShow = false
                $scope.fileToUpload = null
                $scope.uploadFile.name = ''
                $scope.comment = ''

            $scope.$$phase || $scope.$apply()
          ,

          cancel: () ->
            console.info 'upload canceled by user'
            $scope.uploadFile.status = 'ABORT'

          error: (error) ->
            $scope.uploadFile.status = 'ERROR'
            console.error('Error from transload', error)
            $scope.$$phase || $scope.$apply()

        })

      $scope.uploadCancel = () ->
        if $scope.uploading?
          $timeout ()->
            $scope.uploading.cancel()
          , 0

      isValidFileName = (file) ->
        name = file.name.toLowerCase() # (/\.(gif|jpg|jpeg|tiff|png)$/i).test(filename)
        return !(/\.(exe|bat|msi|msc|cmd|js|jse|reg)$/i).test(name)

      isValidFileSize = (file) ->
        mb = file.size # 1000000 * 100 <- 100 MB
        return mb < 100000000

    link: (scope, element, attrs) ->
      scope.dealFiles = element.dealFiles

]
