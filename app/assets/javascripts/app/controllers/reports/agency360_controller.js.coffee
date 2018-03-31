@app.controller 'Agency360Controller',
  ['$scope', '$window', '$q', '$filter', 'Agency360', 'HoldingCompany', 'Field', 'Client', 'zError', 'TimeDimension',
    ( $scope,   $window,   $q,   $filter,   Agency360,   HoldingCompany,   Field,   Client, zError, TimeDimension ) ->

      FIRST_CHART_ID = '#spend-product-chart'
      SECOND_CHART_ID = '#spend-advertiser-chart'
      THIRD_CHART_ID = '#spend-category-chart'
      FOURTH_CHART_ID = '#win-rate-category-chart'

      $scope.holdingCompanies = []
      $scope.timeDimensions = []
      $scope.relatedContacts = []
      $scope.relatedAdvertisers = []
      $scope.activities = []

      $scope.onFilterApply = (query) ->
        if !query.start_date || !query.end_date
          zError '#agency-date-range', 'Please select a Date Range to run this report'
        updateDashboard query

      $scope.onResetFilter = ->
        $scope.showDashboard = false

      $scope.updateAgency = (holdingCompany) ->
        $scope.holdingCompany = holdingCompany
        if holdingCompany && holdingCompany.id
          HoldingCompany.relatedAccounts(holdingCompany.id).then (data) ->
            $scope.agencies = data

      getMonths = (startDate, endDate) ->
        start = moment startDate
        end = moment endDate
        months = []
        while end > start
          months.push
            label: start.format('MMM YY')
            date: start.format('YYYY-MM')
          start.add 1, 'month'
        months
      $scope.months = []

      $scope.getAgencies = ->
        Client.search_clients({
          client_type_id: $scope.agencyOptionId
          name: $scope.agencySearch
        }).$promise.then (data) -> $scope.agencies = data

      Field.defaults({}, 'Client')
        .then (fields) ->
          client_types = Field.findClientTypes(fields)
          option = _.findWhere client_types.options, {name: 'Agency'}
          $scope.agencyOptionId = option.id
          $scope.getAgencies()

      HoldingCompany.all().then (holdingCompanies) ->
        $scope.holdingCompanies = holdingCompanies

      TimeDimension.all().then (timeDimensions) ->
        $scope.timeDimensions = _.map timeDimensions, (td) ->
          td.type = switch
            when td.days_length >= 28 && td.days_length <= 31 then 'month'
          td
        $scope.timeDimensions = _.where($scope.timeDimensions, {type: 'month'});

      transformData = (data) ->
        grouped = _.groupBy data, 'name'
        arr = _.map grouped, (values, name) ->
          valuesByDate = _.mapObject (_.groupBy values, 'date'), (val) -> val[0] && val[0].sum
          values = _.map $scope.months, (month) -> parseInt(valuesByDate[month.date]) || null
          {name: name, values: values, total: _.reduce values, ((sum, val) -> sum += val || 0), 0}
        totalValues = _.map $scope.months, (m, i) -> _.reduce arr, ((sum, item) -> sum += item.values[i] || 0), 0
        arr.push {name: 'Total', values: totalValues, total: _.reduce totalValues, ((sum, val) -> sum += val || 0), 0}
        arr

      updateDashboard = (query) ->
        if !(query.start_date && query.end_date) then return
        $scope.showDashboard = true
        $scope.months = getMonths(query.start_date, query.end_date)
        Agency360.spendByProduct(query).then (data) ->
          $scope.spendByProducts = transformData data
          drawChart($scope.spendByProducts, FIRST_CHART_ID)
        Agency360.spendByAdvertiser(query).then (data) ->
          $scope.spendByAdvertisers = transformData data
          drawChart($scope.spendByAdvertisers, SECOND_CHART_ID)
        Agency360.spendByCategory(query).then (data) ->
          data = _.map data, (c) -> {name: c.category_name, value: c.sum}
          drawPieChart(data, THIRD_CHART_ID)
        Agency360.winRateByCategory(query).then (data) ->
          data = _.map data, (c) -> {name: c.name, value: Math.round c.win_rate}
          drawWinRateChart(data, FOURTH_CHART_ID)
        Agency360.relatedContacts(query).then (data) ->
          $scope.relatedContacts = data
        Agency360.activityHistory(query).then (data) ->
          $scope.activities = data
        Agency360.advertisersWithoutSpend(query).then (data) ->
          $scope.relatedAdvertisers = data

      $scope.getIconName = (typeName) ->
        typeName && typeName.split(' ').join('-').toLowerCase()

      $scope.sumTotalValues = (arr) ->
        _.reduce arr, ((sum, item) -> sum += item.total || 0), 0

      drawChart = (data, chartId) ->
        chartContainer = angular.element(chartId + '-container')
        delay = 1000
        duration = 2000
        margin =
          top: 10
          left: 70
          right: 10
          bottom: 40
        minWidth = $scope.months.length * 60
        width = chartContainer.width() - margin.left - margin.right
        width = minWidth if width < minWidth
        height = 400

        months = $scope.months
        currentMonth = _.findIndex months, {date: moment().format('YYYY-MM')}
        colors = d3.scale.category10()

        dataset = data

        svg = d3.select(chartId)
          .attr('width', width + margin.left + margin.right)
          .attr('height', height + margin.top + margin.bottom)
          .html('')
          .append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')


        maxValue = (d3.max dataset, (item) -> d3.max item.values) || 0
        yMax = maxValue * 1.2

        x = d3.scale.ordinal().domain([0..months.length - 1]).rangePoints([width / months.length,
          width - width / months.length])
        y = d3.scale.linear().domain([yMax || 1, 0]).rangeRound([0, height])


        xAxis = d3.svg.axis().scale(x).orient('bottom')
          .outerTickSize(0)
          .innerTickSize(0)
          .tickPadding(10)
          .tickFormat (v, i) ->
            tick = d3.select(this)
            tick.attr 'class', 'x-tick-text'
            if currentMonth == v
              tick
                .style 'font-weight', 'bold'
                .style 'font-size', '16px'
            months[v].label
        yAxis = d3.svg.axis().scale(y).orient('left')
          .innerTickSize(-width)
          .tickPadding(10)
          .outerTickSize(0)
          .ticks(if yMax > 6 then 6 else yMax || 1)
          .tickFormat (v) -> $filter('formatMoney')(v)
        yAxis.tickValues([0]) if yMax == 0

        svg.append('g').attr('class', 'axis').attr('transform', 'translate(0,' + height + ')').call xAxis
        svg.append('g').attr('class', 'axis').call yAxis

        if currentMonth && currentMonth != -1
          svg.append('line')
            .attr('class', 'month-line')
            .attr 'x1', x(currentMonth)
            .attr 'y1', height
            .attr 'x2', x(currentMonth)
            .attr 'y2', height
            .transition()
            .delay(delay / 2)
            .duration(duration / 2)
            .ease('linear')
            .attr('y1', 0)

        graphLine = d3.svg.line()
          .x((value, i) -> x(i))
          .y((value, i) -> y(value))
          .defined((value, i) -> _.isNumber value)

        graphsContainer = svg.append('g')
          .attr('class', 'graphs-container')

        graphs = graphsContainer.selectAll('.graph')
          .data(dataset)
          .enter()
          .append('path')
          .attr('class', 'graph')
          .attr 'stroke', (d) -> colors(d.name)
          .attr 'd', -> graphLine(_.map months, -> 0)
          .transition()
          .duration(duration)
          .attr 'd', (d) -> graphLine(d.values)

        #legend
        legendContainer = d3.select(chartId + '-container .legend-container')
          .html('')
          .style 'margin-left', margin.left + 'px'
        legend = legendContainer
          .selectAll('.legend')
          .data(dataset)
          .enter()
          .append('div')
          .attr('class', 'legend')
        legend.append('svg')
          .style 'width', '36'
          .style 'height', '4px'
          .style 'margin-right', '8px'
          .append('line')
          .style 'stroke', (d) -> colors(d.name)
          .style 'stroke-width', 3
          .attr 'x1', 0
          .attr 'y1', 2
          .attr 'x2', 36
          .attr 'y2', 2
        legend.append('span')
          .attr 'class', 'legend-text'
          .html (d) -> d.name

      drawPieChart = (data, chartId)->
        width = angular.element(chartId).width()
        height = width
        radius = width / 2
        colors = d3.scale.category10()

        chart = d3.select(chartId).data([data])
          .attr('width', width)
          .attr('height', height)
          .append('svg:g')
          .attr('transform', 'translate(' + radius + ',' + radius + ')')
        arc = d3.svg.arc().outerRadius(radius)
        pie = d3.layout.pie().value (d) -> d.value
        arcs = chart.selectAll('g.slice')
          .data(pie).enter()
          .append('svg:g')
          .attr('class', 'slice')
        arcs.append('svg:path')
          .attr 'fill', (d, i) -> colors i
          .attr 'd', arc

        #legend
        legendContainer = d3.select(chartId + '-container .legend-container')
          .html('')
          .style 'min-height', height + 'px'
        legend = legendContainer
          .selectAll('.legend')
          .data(data)
          .enter()
          .append('div')
          .attr('class', 'legend')
        legend.append('div')
          .style 'margin-right', '8px'
          .append('svg')
          .attr 'width', 36
          .attr 'height', 10
          .style 'height', '10px'
          .append('rect')
          .style 'fill', (d, i) -> colors i
          .attr 'x', 0
          .attr 'y', 0
          .attr 'width', 34
          .attr 'height', 10
        legendText = legend.append('div')
          .attr 'class', 'legend-text'
        legendText.append('span')
          .html (d) -> d.name
          .style 'font-weight', 'bold'
        legendText.append('span')
          .html (d) -> $filter('formatMoney')(d.value)

      drawWinRateChart = (data, chartId) ->
        chartContainer = angular.element(chartId + '-container')
        delay = 500
        duration = 1000
        margin =
          top: 20
          left: 100
          right: 20
          bottom: 0
        barHeight = 25
        barMargin = 25
        barColor = '#3498DB'
        #			totalColor = '#f1c40f'
        width = chartContainer.width() - margin.left - margin.right || 800
        height = data.length * (barHeight + barMargin)

        svg = d3.select(chartId)
          .attr('width', width + margin.left + margin.right)
          .attr('height', height + margin.top + margin.bottom)
          .html('')
          .append('g')
          .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

        x = d3.scale.linear().domain([0, 100]).rangeRound([0, width])
        items = data.map (d) -> d.name
        y = d3.scale.ordinal().domain(items).rangeRoundBands([0, height])
        xAxis = d3.svg.axis().scale(x).orient('top')
          .innerTickSize(-height)
          .tickPadding(10)
          .outerTickSize(-height)
          .tickValues([25, 50, 75, 100])
          .tickFormat (v) -> v + '%'
        yAxis = d3.svg.axis().scale(y).orient('left')
          .innerTickSize(0)
          .tickPadding(10)
          .outerTickSize(-width)

        svg.append('g').attr('class', 'axis').call xAxis
        svg.append('g').attr('class', 'axis').call yAxis

        rightRoundedRect = (x, y, w, h, r) ->
          'M' + x + ',' + y + 'h' + (w - r) + 'a' + r + ',' + r + ' 0 0 1 ' + r + ',' + r + 'v' + (h - 2 * r) + 'a' + r + ',' + r + ' 0 0 1 ' + -r + ',' + r + 'h' + (r - w) + 'z'

        barsWithData = svg.append('g')
          .selectAll('g')
          .data(data)
          .enter()
          .append('g')
          .attr 'class', 'category-bar'
        barsWithData.append('path')
          .attr 'fill', barColor
          .attr 'class', 'win-rate-rect'
          .attr 'd', (d) -> if d.value > 0 then rightRoundedRect(0, (y d.name) + y.rangeBand() / 2 - barHeight / 2, x(d.value), barHeight, 5)

        minXForInnerText = 36
        barsWithData.append('text')
          .text (d) -> d.value + '%'
          .attr 'fill', (d) -> if x(d.value) < minXForInnerText then null else 'white'
#                .attr 'font-weight', 'bold'
          .attr 'alignment-baseline', 'middle'
          .attr 'text-anchor', (d) -> if x(d.value) < minXForInnerText then 'start' else 'end'
          .attr 'x', (d) -> if x(d.value) < minXForInnerText then x(d.value) + 5 else x(d.value) - 6
          .attr 'y', (d) -> ((y d.name) + y.rangeBand() / 2) + 2

  ]