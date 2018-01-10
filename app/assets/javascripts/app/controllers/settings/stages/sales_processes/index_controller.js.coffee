@app.controller "SettingsSalesProcessesController",
['$scope', '$modal', '$filter', 'SalesProcess',
($scope, $modal, $filter, SalesProcess) ->
  $scope.salesProcesses = []

  init = () ->
    SalesProcess.all().then (salesProcesses) ->
      $scope.salesProcesses = $filter('orderBy')(salesProcesses, ['-active'])

  $scope.createSalesProcessModal = () ->
    modalInstance = $modal.open
      templateUrl: 'modals/sales_process_form.html'
      size: 'md'
      controller: 'SettingsSalesProcessNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        sales_process: ->
    modalInstance.result.then (result) ->
      $scope.salesProcesses.push result

  $scope.edit = (salesProcess) ->
    modalInstance = $modal.open
      templateUrl: 'modals/sales_process_form.html'
      size: 'md'
      controller: 'SettingsSalesProcessNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        sales_process: ->
          angular.copy salesProcess
    modalInstance.result.then (result) ->
      index = $scope.salesProcesses.indexOf(salesProcess)
      $scope.salesProcesses[index] = result

  $scope.delete = (salesProcess) ->
    if confirm('Are you sure you want to delete "' +  salesProcess.name + '"?')
      SalesProcess.delete(id: salesProcess.id).then (result) ->
        index = $scope.salesProcesses.indexOf(salesProcess)
        $scope.salesProcesses.splice index, 1

  init()
]
