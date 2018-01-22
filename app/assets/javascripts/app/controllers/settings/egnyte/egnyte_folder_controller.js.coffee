@app.controller 'EgnyteFolderController',
  ['$scope', '$modal', 'Egnyte', ($scope, $modal, Egnyte) ->
    $scope.showParentButton = false
    $scope.showSubButton = false

    $scope.init = () ->
      $scope.showFolderStructure()

    $scope.showFolderStructure = () ->
      Egnyte.show().then (egnyteSettings) ->
        egnyteSettings.deal_folder_tree.root = true
        $scope.folders = {nodes: [egnyteSettings.deal_folder_tree]}

    $scope.$on 'updateFolderStructure', ->
      $scope.showFolderStructure()

    $scope.createFolder = (type) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/egnyte_form.html'
        size: 'md'
        controller: 'EgnyteNewFolderController'
        backdrop: 'static'
        keyboard: false
        resolve:
          contentInfo: ->
            { folders: $scope.folders, activated: $scope.activatedFolder, parentFolder: $scope.parentFolder, type: type }

    $scope.$on 'handleActionButtons', (event, folder, parentFolder) ->
      $scope.activatedFolder = folder
      $scope.parentFolder = parentFolder
      if folder
        if folder.root
          $scope.showParentButton = false
          $scope.showSubButton = true
        else
          $scope.showSubButton = true
          $scope.showParentButton = true
      else
        $scope.showSubButton = false
        $scope.showParentButton = false

    $scope.init()
]