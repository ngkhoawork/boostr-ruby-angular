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

    $scope.$on 'editFolder', (event, folder) ->
      $scope.createFolder "edit", folder

    $scope.$on 'deleteFolder', (event, folder) ->
      folders = findFolder($scope.folders.nodes, folder)
      updateFolderStructure(JSON.stringify(_.first(folders)))

    $scope.createFolder = (type, folder) ->
      $scope.modalInstance = $modal.open
        templateUrl: 'modals/egnyte_form.html'
        size: 'md'
        controller: 'EgnyteNewFolderController'
        backdrop: 'static'
        keyboard: false
        resolve:
          contentInfo: ->
            { folder: folder, folders: $scope.folders, activated: $scope.activatedFolder, parentFolder: $scope.parentFolder, type: type }

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

    findFolder = (nodes, folder) ->
      _.each nodes, (nestedNodes) ->
        if _.isObject(nestedNodes) && !nestedNodes.nodes && !_.isArray(nestedNodes)
          nestedNodes.nodes = []
        if _.isArray(nestedNodes) || nestedNodes.nodes
          if _.findWhere nestedNodes.nodes, folder
            removedNodes = nestedNodes.nodes.filter (el) ->
              return el.$$hashKey != folder.$$hashKey
            nestedNodes.nodes = removedNodes
          findFolder(nestedNodes, folder)

    updateFolderStructure = (folders) ->
      Egnyte.updateConfiguration({egnyte_integration: {deal_folder_tree: folders}}).then (res) ->
        $scope.showFolderStructure()

    $scope.init()
]