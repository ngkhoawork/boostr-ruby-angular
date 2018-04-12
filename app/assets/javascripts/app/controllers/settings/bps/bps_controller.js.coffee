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

      getBps = () ->
        BP.all({settings: true}).then (bps) ->
          $scope.bps = bps
      getBps()

      $scope.showModal = ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/bp_form.html'
          size: 'lg'
          controller: 'BPsNewController'
          backdrop: 'static'
          keyboard: false

      $scope.$on 'newBP', ->
        $scope.notification = "Bottoms Up data is being generated in a few seconds."

      $scope.go = ($event, bp) ->
        path = "/settings/bps/" + bp.id
        $location.path(path)

      $scope.deleteBp = ($event, bp) ->
        $event.stopPropagation()
        deleteBp bp

      $scope.activateBp = (bp) ->
        BP.update(id: bp.id, bp: bp).then (data) ->
          bp.active = data.active

      deleteBp = (bp) ->
        if confirm('Are you sure you want to delete "' +  bp.name + '"?')
          BP.delete(bp).then(
            (bp) ->
              (err) ->
                console.log err
          )

      $scope.$on 'updated_bps', getBps


#=======================END Cycle Time=======================================================
  ]
