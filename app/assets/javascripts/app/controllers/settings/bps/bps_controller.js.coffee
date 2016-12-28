@app.controller 'BPsController',
  ['$scope', '$document', '$location', '$modal', 'BP', 'TimePeriod',
    ($scope, $document, $location, $modal, BP, TimePeriod) ->

      #create chart===========================================================
      $scope.teamFilters = []
      $scope.teamId = ''
      $scope.monthlyForecastData = []
      $scope.totalData = null
      $scope.isDateSet = false

      $scope.dataType = "weighted"
      $scope.notification = null


      #init query
      init = () ->
        BP.all().then (bps) ->
          $scope.bps = bps

      init()

      $scope.showModal = ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/bp_form.html'
          size: 'lg'
          controller: 'BPsNewController'
          backdrop: 'static'
          keyboard: false

      $scope.$on 'newBP', ->
        $scope.notification = "Business Plan data is being generated in a few seconds."
        init()

      $scope.go = (bpId) ->
        path = "/settings/bps/" + bpId
        $location.path(path)


#=======================END Cycle Time=======================================================
  ]
