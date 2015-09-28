@app.controller 'DashboardController',
['$scope', '$modal', 'Dashboard',
($scope, $modal, Dashboard) ->

  Dashboard.get().then (dashboard) ->
    $scope.dashboard = dashboard


  $scope.showNewDealModal = ->
    $scope.modalInstance = $modal.open
      templateUrl: 'modals/deal_form.html'
      size: 'lg'
      controller: 'DealsNewController'
      backdrop: 'static'
      keyboard: false
      resolve:
        deal: ->
          {}

]