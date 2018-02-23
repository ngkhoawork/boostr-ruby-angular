@app.controller 'BPController',
  ['$scope', '$rootScope', '$window', '$document', '$modal', 'BP', 'BpEstimate', 'Team', 'Seller'
    ($scope, $rootScope, $window, $document, $modal, BP, BpEstimate, Team, Seller) ->

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
      defaultUser = {id: 'all', name: 'All', first_name: 'All'}
      $scope.teamId = ''
      $scope.monthlyForecastData = []
      $scope.totalData = null
      $scope.isDateSet = false
      $scope.selectedBP = {id: 0}
      $scope.selectedTeam = {id: null, name: 'All'}
      $scope.selectedUser = defaultUser
      $scope.bpEstimates = []
      $scope.isLoading = false
      $scope.hasMoreBps = true
      $scope.page = 1
      $scope.totalCount = 0
      $scope.totalClients = 0
      $scope.totalStatus = 0
      $scope.totalSellerEstimate = 0
      $scope.totalMgrEstimate = 0

      $scope.dataType = "weighted"
      $scope.notification = null
      $scope.filter =
        team: {id: null, name: 'All'}
        user: defaultUser
        bp: {id: 0}
      $scope.selectedTeam = $scope.filter.team

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

      $scope.selectFilter = (filter) ->
        $scope.selectedFilter = filter
        if $scope.selectedBP.id != 0
          $scope.page = 1
          $scope.bpEstimates = []
          $scope.hasMoreBps = true
          loadBPData()

      $scope.setFilter = (key, value) ->
        if $scope.filter[key]is value
          return
        $scope.filter[key] = value

      $scope.$watch 'filter.team', (nextTeam, prevTeam) ->
        if nextTeam.id then $scope.filter.user = defaultUser
        $scope.setFilter('team', nextTeam)
        Seller.query({id: nextTeam.id || 'all'}).$promise.then (users) ->
          $scope.users = users
          $scope.users.unshift(defaultUser)

      onScroll = (evt) ->
        scrollTop = evt.target.scrollingElement.scrollTop
        scrollLeft = evt.target.scrollingElement.scrollLeft
        targetTop = $('.bp-table-wrapper')[0].offsetTop
        if scrollTop >= targetTop
          $('.fixed')[0].style.top = (scrollTop - targetTop) + 'px';
          $('.fixed')[0].style.display = "table";
        else
          $('.fixed')[0].style.display = "none"

      $document.on 'scroll', onScroll
      $scope.$on '$destroy', () ->
        $document.off('scroll', onScroll)

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

        Team.all(all_teams: true).then (teams) ->
          $scope.teams = teams
          $scope.teams.unshift {id: null, name: 'All'}

        Team.all_members(team_id: 'all').then (users) ->
          $scope.users = users
          $scope.users.unshift(defaultUser)

      init()

      $scope.export = () ->
        if $scope.selectedBP.id > 0
          url = '/api/bps/' + $scope.selectedBP.id + '/bp_estimates.csv?filter=' + $scope.selectedFilter.value
          if $scope.selectedTeam.id > 0
            url += '&team_id=' + $scope.selectedTeam.id
          if $scope.selectedUser.id > 0
            url += '&user_id=' + $scope.selectedUser.id
          $window.open(url)
          return true

      $scope.showAddClientModal = () ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/bp_add_client_form.html'
          size: 'md'
          controller: 'BpAssignClientController'
          backdrop: 'static'
          keyboard: false
          resolve:
            bp: ->
              $scope.selectedBP
        .result.then (bp) ->
          if (bp && bp.id)
            $scope.page = 1
            loadBPData()

      $scope.applyFilter = () ->
        if $scope.filter.bp.id && !$scope.isLoading
          $scope.selectedBP = $scope.filter.bp
          $scope.selectedTeam = $scope.filter.team
          $scope.selectedUser = $scope.filter.user

          startDate = new Date($scope.selectedBP.time_period.start_date)
          year = startDate.getUTCFullYear()
          month = startDate.getUTCMonth()
          $scope.yearQuarter = 'Q' + (month / 3 + 1) + '-' + (year - 1)
          prevMonth = month - 3
          prevYear = year
          if prevMonth < 0
            prevMonth += 12
            prevYear = year - 1
          $scope.prevQuarter = 'Q' + (prevMonth / 3 + 1) + '-' + prevYear
          $scope.bpEstimates = []
          $scope.hasMoreBps = true
          $scope.page = 1
          loadStatus()
          loadBPData()

      $scope.loadMoreBps = ->
        if !$scope.isLoading && $scope.hasMoreBps == true
          $scope.page = $scope.page + 1
          loadBPData()

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

        if data.estimate_seller > 0 && data.year_revenue > 0
          data.year_change = (parseFloat(data.estimate_seller) / parseFloat(data.year_revenue) - 1) * 100
        else
          data.year_change = null

        if data.estimate_seller > 0 && data.prev_revenue > 0
          data.prev_year_change = (parseFloat(data.estimate_seller) / parseFloat(data.prev_revenue) - 1) * 100
        else
          data.prev_year_change = null

        return data

      loadBPData = () ->
        if $scope.selectedBP.id
          filters = {
            bp_id: $scope.selectedBP.id,
            filter: $scope.selectedFilter.value
            team_id: $scope.selectedTeam.id
            user_id: $scope.selectedUser.id
            page: $scope.page
            per: 10
          }
          $scope.isLoading = true
          BpEstimate.all(filters).then (data) ->
            $scope.revenues = data.current.revenues
            $scope.pipelines = data.current.pipelines

            $scope.prev_revenues = data.prev.revenues
            $scope.prev_pipelines = data.prev.pipelines
            $scope.prev_time_period = data.prev.time_period

            $scope.year_revenues = data.year.revenues
            $scope.year_pipelines = data.year.pipelines
            $scope.year_time_period = data.prev.year_time_period

            if $scope.page == 1
              $scope.bpEstimates = _.map data.bp_estimates, buildBPEstimate
            else
              $scope.bpEstimates = $scope.bpEstimates.concat(_.map data.bp_estimates, buildBPEstimate)
            
            setMcSort()
            $scope.isLoading = false
            if data.bp_estimates.length == 0
              $scope.hasMoreBps = false

      loadStatus = () ->
        if $scope.selectedBP.id
          filters = {
            bp_id: $scope.selectedBP.id,
            filter: $scope.selectedFilter.value
            team_id: $scope.selectedTeam.id
            user_id: $scope.selectedUser.id
          }
          $scope.isLoading = true
          BpEstimate.get_status(filters).then (data) ->
            $scope.totalClients = data.total_clients
            $scope.totalStatus = data.total_status
            $scope.totalSellerEstimate = data.total_seller_estimate
            $scope.totalMgrEstimate = data.total_mgr_estimate
            calculateStatus()
            $scope.isLoading = false

      calculateStatus = () ->
        if ($scope.totalClients > 0)
          percentage = $scope.totalStatus * 100 / $scope.totalClients
        drawProgressCircle(percentage)

      $scope.updateBpEstimate = (bpEstimate) ->
        BpEstimate.update(id: bpEstimate.id, bp_id: $scope.selectedBP.id, bp_estimate: bpEstimate).then (data) ->
          calculateChange(data)

      $scope.updateBpEstimateProduct = (bpEstimate) ->
        BpEstimate.update(id: bpEstimate.id, bp_id: $scope.selectedBP.id, bp_estimate: bpEstimate).then (data) ->
          replaceBpEstimate(data)
          calculateChange(data)

      $scope.unassignBpEstimate = (bpEstimate) ->
        if confirm('Are you sure you want to unassign the BP estimate?')
          bpEstimate.user_id = null
          BpEstimate.update(id: bpEstimate.id, bp_id: $scope.selectedBP.id, bp_estimate: bpEstimate).then (data) ->
            replaceBpEstimate(data)
            calculateChange(data)


      calculateChange = (bpEstimate) ->
        loadStatus()
        targetBpEstimate = _.find($scope.bpEstimates, {id: bpEstimate.id})
        if targetBpEstimate.estimate_seller > 0 && targetBpEstimate.year_revenue > 0
          targetBpEstimate.year_change = (parseFloat(targetBpEstimate.estimate_seller) / parseFloat(targetBpEstimate.year_revenue) - 1) * 100
        else
          targetBpEstimate.year_change = null

        if targetBpEstimate.estimate_seller > 0 && targetBpEstimate.prev_revenue > 0
          targetBpEstimate.prev_year_change = (parseFloat(targetBpEstimate.estimate_seller) / parseFloat(targetBpEstimate.prev_revenue) - 1) * 100
        else
          targetBpEstimate.prev_year_change = null

      replaceBpEstimate = (bpEstimate) ->
        targetBpEstimate = _.find($scope.bpEstimates, {id: bpEstimate.id})
        targetBpEstimate.user_id = bpEstimate.user_id
        targetBpEstimate.user = bpEstimate.user
        targetBpEstimate.user_name = bpEstimate.user_name
        targetBpEstimate.estimate_seller = bpEstimate.estimate_seller
        targetBpEstimate.estimate_mgr = bpEstimate.estimate_mgr
        targetBpEstimate.bp_estimate_products = bpEstimate.bp_estimate_products

      $scope.totalSum = (elements, field) ->
        total = 0
        _.each elements, (item) ->
          total += item[field]
        return total


      $scope.totalEstimate = (elements, field) ->
        total = 0
        _.each elements, (item) ->
          if (item.user_id != null && item[field])
            total += parseInt(item[field])
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
#          progressNumber.html(i + '%')
          i++
        ), animationDuration / p


#=======================END Cycle Time=======================================================
  ]
