@app.controller 'BPController',
  ['$scope', '$document', '$modal', 'BP',
    ($scope, $document, $modal, BP) ->

      class McSort
        constructor: (opts) ->
          @column = opts.column
          @compareFn = opts.compareFn || (-> 0)
          @dataset = opts.dataset || []
          @defaults = opts
          @direction = opts.direction || "asc"
          @hasMultipleDatasets = opts.hasMultipleDatasets || false
          @execute()

        execute: ->
          mcSort = @
          if not @hasMultipleDatasets
            @dataset.sort (a, b) ->
              mcSort.compareFn(mcSort.column, a, b)
            @dataset.reverse() if @direction == "desc"
          else
            @dataset = @dataset.map (row) ->
              row.sort (a, b) ->
                mcSort.compareFn(mcSort.column, a, b)
              row.reverse() if mcSort.direction == "desc"
              row
          @dataset

        reset: ->
          @column = @defaults.column
          @direction = @defaults.direction || "asc"
          @execute()

        toggle: (column) ->
          direction = "asc"
          direction = "desc" if @column == column and @direction == "asc"
          @column = column
          @direction = direction
          @execute()

      #create chart===========================================================
      $scope.teamFilters = []
      $scope.teamId = ''
      $scope.monthlyForecastData = []
      $scope.totalData = null
      $scope.isDateSet = false
      $scope.selectedBP = {id: 0}
      $scope.bpEstimates = []

      $scope.dataType = "weighted"
      $scope.notification = null

      setMcSort = ->
       $scope.sort = new McSort({
         column: "client_name",
         compareFn: (column, a, b) ->
           console.log(column)
           switch (column)
             when "client_name"
               a[column].localeCompare(b[column])
             when "user_name"
               a[column].localeCompare(b[column])
             else
               a[column] - b[column]
         dataset: $scope.bpEstimates
         hasMultipleDatasets: false
       })

      #init query
      init = () ->
        BP.all().then (bps) ->
          $scope.bps = bps

      init()

      $scope.selectBP = (bp) ->
        $scope.selectedBP = bp
        loadBPData()

      loadBPData = () ->
        BP.get($scope.selectedBP.id).then (data) ->
          $scope.bpEstimates = data.bp_estimates
          setMcSort()

#=======================END Cycle Time=======================================================
  ]
