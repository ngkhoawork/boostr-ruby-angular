@app.controller 'EgnyteNewFolderController', ['$scope', '$modalInstance', 'folder', ( $scope, $modalInstance, folder ) ->
  $scope.folder = folder

  $scope.cancel = ->
    $modalInstance.close()

  $scope.submitForm = () ->
    formValidation()
    if Object.keys($scope.errors).length > 0 then return


  formValidation = () ->
    $scope.errors = {}
    fields = ['name']

    fields.forEach (key) ->
      field = $scope.folder[key]
      switch key
        when 'name'
          if !field then return $scope.errors[key] = 'Name is required'
]