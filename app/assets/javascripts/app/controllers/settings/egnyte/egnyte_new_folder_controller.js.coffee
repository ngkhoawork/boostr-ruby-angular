@app.controller 'EgnyteNewFolderController',
  ['$scope', '$modalInstance', 'contentInfo', 'Egnyte', '$rootScope'
    ( $scope, $modalInstance, contentInfo, Egnyte, $rootScope ) ->
      $scope.contentInfo = contentInfo
      $scope.newFolder = { nodes: [] }

      $scope.cancel = ->
        $modalInstance.close()

      $scope.submitForm = () ->
        formValidation()
        if Object.keys($scope.errors).length > 0 then return

        activeFolder = $scope.contentInfo.activated
        folders = deepNestedFolder(_.first($scope.contentInfo.folders.nodes))
        type = $scope.contentInfo.type
        parentFolder = $scope.contentInfo.parentFolder

        if type == 'sub'
          activeFolder.nodes.push $scope.newFolder
          updateFolderStructure(JSON.stringify(folders))

        else
          $scope.newFolder.nodes.push activeFolder
          parentFolder.nodes.push $scope.newFolder
          updatedParent = parentFolder.nodes.filter((folder) ->
            folder.title != activeFolder.title
          )
          parentFolder.nodes = updatedParent
          updateFolderStructure(JSON.stringify(folders))

      deepNestedFolder = (nodes) ->
        delete nodes['$$hashKey']
        _.each nodes, (nestedNodes) ->
          if _.isObject(nestedNodes) && !nestedNodes.nodes && !_.isArray(nestedNodes)
            nestedNodes.nodes = []
          if _.isArray(nestedNodes) || nestedNodes.nodes
            deepNestedFolder(nestedNodes)

      updateFolderStructure = (folders) ->
        Egnyte.updateConfiguration({egnyte_integration: {deal_folder_tree: folders}}).then (res) ->
          $rootScope.$broadcast 'updateFolderStructure'
          $scope.cancel()

      formValidation = () ->
        $scope.errors = {}
        fields = ['title']
        fields.forEach (key) ->
          field = $scope.newFolder[key]
          switch key
            when 'title'
              if !field then return $scope.errors[key] = 'Title is required'


]