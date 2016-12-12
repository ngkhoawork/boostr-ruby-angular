@app.controller 'BPsController',
  ['$scope', '$document', '$modal', 'BP', 'TimePeriod',
    ($scope, $document, $modal, BP, TimePeriod) ->

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


#=======================END Cycle Time=======================================================
  ]
