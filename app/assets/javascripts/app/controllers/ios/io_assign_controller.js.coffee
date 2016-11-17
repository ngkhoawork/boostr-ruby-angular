@app.controller "IOAssignController",
['$scope', '$modal', '$modalInstance', '$filter', 'IO', 'TempIO', 'tempIO'
($scope, $modal, $modalInstance, $filter, IO, TempIO, tempIO) ->
  $scope.formType = "Edit"
  $scope.submitText = "Update"
  $scope.tempIO = tempIO
  $scope.searchText = ""
  IO.all({filter: 'all', page: 1}).then (ios) ->
    $scope.ios = ios

  $scope.searchObj = (name) ->
    if name == ""
      IO.all({filter: 'all', page: 1}).then (ios) ->
        $scope.ios = ios
    else
      IO.all({name: name, page: 1}).then (ios) ->
        $scope.ios = ios

  $scope.showIONewModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/io_form.html'
      size: 'lg'
      controller: 'IONewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        io: ->
          {}
        tempIO: ->
          $scope.tempIO
    .result.then (created_io) ->
      $scope.assignIO(created_io)

  $scope.assignIO = (io) ->
    tempIO.io_id = io.id
    console.log(tempIO);
    TempIO.update(id: tempIO.id, temp_io: tempIO).then (tempIO) ->
      $modalInstance.close(tempIO)

  $scope.cancel = ->
    $modalInstance.close()
]
