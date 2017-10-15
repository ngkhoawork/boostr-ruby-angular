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
        $scope.notification = "Business Plan data is being generated in a few seconds."

      $scope.go = ($event, bp) ->
        if($($event.target).hasClass("delete-icon"))
          deleteBp bp
        else
          path = "/settings/bps/" + bp.id
          $location.path(path)

      deleteBp = (bp) ->
        if confirm('Are you sure you want to delete "' +  bp.name + '"?')
          BP.delete(bp).then(
            (bp) ->
              (err) ->
                console.log err
          )
          $scope.notification = "Business Plan successfully destroyed."

      $scope.$on 'updated_bps', getBps


#=======================END Cycle Time=======================================================
  ]
