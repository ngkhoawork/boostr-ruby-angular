@app.controller 'BPController',
  ['$scope', '$rootScope', '$document', '$modal', 'BP', 'BpEstimate',
    ($scope, $rootScope, $document, $modal, BP, BpEstimate) ->

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
      $scope.bpEstimateFilters = [
        {name: "My Estimates", value: "my"},
        {name: "My Team's Estimates", value: "team"},
        {name: "All Estimates", value: "all"}
      ]
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

      setSummaryMcSort = ->
        $scope.summarySort = new McSort({
          column: "name",
          compareFn: (column, a, b) ->
            switch (column)
              when "name"
                a[column].localeCompare(b[column])
              else
                a[column] - b[column]
          dataset: $scope.accountTotalEstimates
          hasMultipleDatasets: false
        })

      #init query
      init = () ->
        if $rootScope.userType == 1
          $scope.selectedFilter = {name: "My Estimates", value: "my"}
        else if $rootScope.userType == 2
          $scope.selectedFilter = {name: "My Team's Estimates", value: "team"}
        else
          $scope.selectedFilter = {name: "All Estimates", value: "all"}
        BP.all().then (bps) ->
          $scope.bps = bps

      init()

      $scope.selectFilter = (filter) ->
        $scope.selectedFilter = filter
        if $scope.selectedBP.id != 0
          loadBPData()

      $scope.selectBP = (bp) ->
        $scope.selectedBP = bp
        startDate = new Date(bp.time_period.start_date)
        year = startDate.getUTCFullYear()
        month = startDate.getUTCMonth()
        $scope.yearQuarter = 'Q' + (month / 3 + 1) + '-' + (year - 1)
        prevMonth = month - 3
        prevYear = year
        if prevMonth < 0
          prevMonth += 12
          prevYear = year - 1
        $scope.prevQuarter = 'Q' + (prevMonth / 3 + 1) + '-' + prevYear
        loadBPData()
        drawProgressCircle($scope.selectedBP.status * 100 / $scope.selectedBP.client_count)

      buildBPEstimate = (item) ->
        data = angular.copy(item)

        revenue = _.find $scope.revenues, (o) ->
          return o.account_dimension_id == item.client_id
        pipeline = _.find $scope.pipelines, (o) ->
          return o.account_dimension_id == item.client_id

        prev_revenue = _.find $scope.prev_revenues, (o) ->
          return o.account_dimension_id == item.client_id
        prev_pipeline = _.find $scope.prev_pipelines, (o) ->
          return o.account_dimension_id == item.client_id

        year_revenue = _.find $scope.year_revenues, (o) ->
          return o.account_dimension_id == item.client_id
        year_pipeline = _.find $scope.year_pipelines, (o) ->
          return o.account_dimension_id == item.client_id

        data.revenue = 0
        data.pipeline = 0
        data.prev_revenue = 0
        data.prev_pipeline = 0
        data.year_revenue = 0
        data.year_pipeline = 0

        if (revenue)
          data.revenue = revenue.revenue_amount
        if (pipeline)
          data.pipeline = pipeline.pipeline_amount

        if (prev_revenue)
          data.prev_revenue = prev_revenue.revenue_amount
        if (prev_pipeline)
          data.prev_pipeline = prev_pipeline.pipeline_amount

        if (year_revenue)
          data.year_revenue = year_revenue.revenue_amount
        if (year_pipeline)
          data.year_pipeline = year_pipeline.pipeline_amount

        return data

      loadBPData = () ->
        filters = { bp_id: $scope.selectedBP.id, filter: $scope.selectedFilter.value }
#        BP.accountTotalEstimates(id: $scope.selectedBP.id, filter: $scope.selectedFilter.value).then (accountTotalEstimates) ->
#          $scope.accountTotalEstimates = accountTotalEstimates
#          setSummaryMcSort()
        BpEstimate.all(filters).then (data) ->
          $scope.revenues = data.current.revenues
          $scope.pipelines = data.current.pipelines

          $scope.prev_revenues = data.prev.revenues
          $scope.prev_pipelines = data.prev.pipelines
          $scope.prev_time_period = data.prev.time_period

          $scope.year_revenues = data.year.revenues
          $scope.year_pipelines = data.year.pipelines
          $scope.year_time_period = data.prev.year_time_period

          $scope.bpEstimates = _.map data.bp_estimates, buildBPEstimate

          setMcSort()

      $scope.updateBpEstimate = (bpEstimate) ->
        BpEstimate.update(id: bpEstimate.id, bp_id: $scope.selectedBP.id, bp_estimate: bpEstimate)

      $scope.updateBpEstimateProduct = (bpEstimate) ->
        BpEstimate.update(id: bpEstimate.id, bp_id: $scope.selectedBP.id, bp_estimate: bpEstimate).then (data) ->
          replaceBpEstimate(data);

      $scope.unassignBpEstimate = (bpEstimate) ->
        if confirm('Are you sure you want to unassign the BP estimate?')
          bpEstimate.user_id = null
          BpEstimate.update(id: bpEstimate.id, bp_id: $scope.selectedBP.id, bp_estimate: bpEstimate).then (data) ->
            replaceBpEstimate(data)

      replaceBpEstimate = (bpEstimate) ->
        targetBpEstimate = _.find($scope.bpEstimates, {id: bpEstimate.id})
        targetBpEstimate.user_id = bpEstimate.user_id
        targetBpEstimate.user = bpEstimate.user
        targetBpEstimate.user_name = bpEstimate.user_name
        targetBpEstimate.estimate_seller = bpEstimate.estimate_seller
        targetBpEstimate.estimate_mgr = bpEstimate.estimate_mgr

      $scope.totalSum = (elements, field) ->
        total = 0
        _.each elements, (item) ->
          total += item[field]
        return total


      $scope.totalEstimate = (elements, field) ->
        total = 0
        _.each elements, (item) ->
          if (item.user_id != null)
            total += item[field]
        return total

      $scope.toggleRow = (rowId) ->
        if ($scope.toggleId == rowId)
          $scope.toggleId = null
        else
          $scope.toggleId = rowId

      drawProgressCircle = (p) ->
        p = Math.round(p)
        animationDuration = 500
        width = 105
        height = 105
        tau = 2 * Math.PI
        arc = d3.svg.arc()
        .innerRadius(45)
        .outerRadius(48)
        .startAngle(0)
        svg = d3.select("#progress-circle")
        .style('width': width + 'px')
        .style('height': height + 'px')
        svg.html('')
        g = svg.append('g')
        .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')')
        background = g.append('path')
        .datum(endAngle: tau)
        .style('fill', '#EEE')
        .attr('d', arc)
        foreground = g.append('path')
        .datum(endAngle: 0)
        .attr('d', arc)
        point = svg.append('circle')
        .attr('r', 5)
        .attr('transform', 'translate(75, 11.5)')

        arcTween = (newAngle) ->
          (d) ->
            interpolate = d3.interpolate(d.endAngle, newAngle)
            (t) ->
              d.endAngle = interpolate(t)
              arc d

        translateFn = (newAngle) ->
          () ->
            (t) ->
              rotation_radius = 46
              t_angle = newAngle * t - Math.PI / 2
              t_x = rotation_radius * Math.cos(t_angle)
              t_y = rotation_radius * Math.sin(t_angle)
              'translate(' + (width / 2 + t_x) + ',' + (height / 2 + t_y) + ')'
        endAngle = tau / 100 * p
        foreground.transition().duration(animationDuration).attrTween('d', arcTween(endAngle))
        point.transition().duration(animationDuration).attrTween('transform', translateFn(endAngle))

        i = 0
        progressNumber = $document.find('#progress-number')
        interval = setInterval (->
          if i is p then clearInterval(interval)
          progressNumber.html(i + '%')
          i++
        ), animationDuration / p


#=======================END Cycle Time=======================================================
  ]
