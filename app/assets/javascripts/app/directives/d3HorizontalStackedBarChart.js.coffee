@app.directive 'd3HorizonStackedBars', [
  '$window'
  '$timeout'
  'd3Service'
  ($window, $timeout, d3Service) ->
    {
    restrict: 'A'
    scope:
      data: '='
      label: '@'
      onClick: '&'
    link: (scope, ele, attrs) ->
      d3Service.d3().then (d3) ->
        renderTimeout = undefined
        margins =
          top: 12
          left: 80
          right: 24
          bottom: 24
        legendPanel = width: 0
        width = 560 - (margins.left) - (margins.right) - (legendPanel.width)
        height = 150 - (margins.top) - (margins.bottom)

        barHeight = parseInt(attrs.barHeight) or 20
        barPadding = parseInt(attrs.barPadding) or 5
        p_svg = d3.select(ele[0]).append('svg')


        $window.onresize = ->
          scope.$apply()
          return

        scope.$watch (->
          angular.element($window)[0].innerWidth
        ), ->
          scope.render scope.data
          return
        scope.$watch 'data', ((newData) ->
          scope.render newData
          return
        ), true

        scope.render = (data) ->
          p_svg.selectAll('*').remove()
          if !data || !data.dataset
            return
          if renderTimeout
            clearTimeout renderTimeout
          renderTimeout = $timeout((->
            if data.options.chart.margin
              margins = data.options.chart.margin
            if data.options.chart.width
              width = data.options.chart.width  - (margins.left) - (margins.right) - (legendPanel.width)
            else
              height = data.options.chart.height - (margins.top) - (margins.bottom)

            series = data.dataset.map((d) ->
              d.name
            )
            custom_colors = data.dataset.map((d) ->
              d.color
            )
            dataset = data.dataset.map((d) ->
              d.data.map (o, i) ->
                # Structure it so that your numeric
                # axis (the stacked amount) is y
                {
                y: o.value
                x: (if o.label.length > 12 then o.label.substr(0, 12) + "..." else o.label + "   ")
                }
            )

            stack = d3.layout.stack()
            stack dataset
            dataset = dataset.map((group) ->
              group.map (d) ->
                # Invert the x and y values, and y0 becomes x0
                {
                x: d.y
                y: d.x
                x0: d.y0
                }
            )

            svg = p_svg.attr('width', width + margins.left + margins.right + legendPanel.width).attr('height', 50 + height + margins.top + margins.bottom).append('g').attr('transform', 'translate(' + margins.left + ',' + margins.top + ')')
            xMax = d3.max(dataset, (group) ->
              d3.max group, (d) ->
                d.x + d.x0
            )

            x_tick_interval = 1
            max_range = xMax
            while (max_range > 10)
              x_tick_interval = x_tick_interval * 10
              max_range = max_range / 10
            if max_range < 3.5
              x_tick_interval = x_tick_interval / 2
              max_range = max_range * 2
            xScale = d3.scale.linear().domain([
              0
              xMax
            ]).range([
              0
              width
            ])
            labels = dataset[0].map((d) ->
              d.y
            )
            _ = console.log(labels)
            yScale = d3.scale.ordinal().domain(labels).rangeRoundBands([
              0
              height
            ], .1)
            xAxis = d3.svg.axis()
            .tickFormat(formatCurrency)
            .scale(xScale)
            .tickSize(height)
            .tickValues(d3.range(0, xMax, x_tick_interval))
            .orient('top')
            yAxis = d3.svg.axis().scale(yScale).orient('left')
            yAxis.tickSize(0)

            colours = d3.scale.category10()
            groups = svg.selectAll('g').data(dataset).enter().append('g').style('fill', (d, i) ->
              custom_colors[i]
            )
            rects = groups.selectAll('rect').data((d) ->
              d
            ).enter().append('rect').attr('x', (d) ->
              xScale d.x0
            ).attr('y', (d, i) ->
              yScale d.y
            ).attr('height', (d) ->
              yScale.rangeBand()
            ).attr('width', (d) ->
              xScale d.x
            ).on('mouseover', (d) ->
              xPos = parseFloat(d3.select(this).attr('x')) / 2 + width / 2
              yPos = parseFloat(d3.select(this).attr('y')) + yScale.rangeBand() / 2 - 10
              d3.select('#tooltip').style('left', xPos + 'px').style('top', yPos + 'px').select('#value').text formatCurrency(d.x)
              d3.select('#tooltip').classed 'hidden', false
              return
            ).on('mouseout', ->
              d3.select('#tooltip').classed 'hidden', true
              return
            )

            gx = svg.append('g').attr('class', 'axis').attr('transform', 'translate(0,' + height + ')').call xAxis
            gx.selectAll("g").filter((d) =>
              return d;
            ).classed("minor", true);

            gx.selectAll("text")
            .attr("dx", 0)
            .attr("y", 15);

            gy = svg.append('g').attr('class', 'axis').call yAxis

#            svg.append('rect').attr('fill', 'yellow').attr('width', 160).attr('height', 30 * dataset.length).attr('x', margins.left).attr 'y', 150

            series_space = 60
            series_x = width / 2 - series_space * series.length / 2
            series.forEach (s, i) ->
              svg.append('rect').attr('fill', custom_colors[i]).attr('width', 13).attr('height', 13).attr('x', series_x + i * series_space).attr 'y', 163
              svg.append('text').attr('fill', 'black').attr('x', series_x + i * series_space + 18 ).attr('y', 174).text s

              return

            formatNumber = d3.format(",")
            formatCurrency = (d) ->
              s = formatNumber(d)
              return "$" + s

            return
          ), 200)
          return

        return
      return

    }
]
#npsByJourneyType = (uxSettings) ->
#  directive =
#    restrict: 'E'
#    replace: false
#    scope:
#      chartData: '='
#      widgetId: '='
#      crossFilter: '='
#    template: '<svg id="w_{{widgetId}}" class="stacked-bar-chart clickable-x-axis"></svg>'
#    link: linkFn
#
#  linkFn = (scope, element) ->
#    container = angular.element(element)[0]
#    svgDOM = angular.element(element).children('svg')[0]
#    debouncedRender = _.debounce(render, 300)
#
#    render = ->
#      data = scope.chartData.data
#      labels = scope.chartData.labels or {}
#      values = _.pluck(data, 'values')
#      npsValues = _.pluck(_.flatten(values), 'y')
#
#      drawGraph = ->
#        chart = nv.models.multiBarChart().color(uxSettings.fourColors).duration(0).yDomain([
#          0
#          100
#        ]).y((d) ->
#          d.y
#        ).showControls(false).stacked(true).noData('No Data Available').groupSpacing(0.4)
#        chart.xAxis.tickPadding(25).tickFormat (d) ->
#          labels[d]
#        chart.yAxis.tickPadding(10).tickFormat (d) ->
#          d3.format('p') d / 100
#        chart.tooltip.enabled false
#        # chart.tooltip.valueFormatter(function (d) { return '' +d3.format(',.2f')(d) + '%'; })
#        chart.legend.updateState false
#        d3.select(svgDOM).datum(data).transition().duration(0).call(chart).each 'end', drawFinished
#        chart
#
#      drawFinished = ->
#        drawValueOnStackedBarChart scope.widgetId
#        svgId = '#w_' + scope.widgetId + ' '
#        xAxisTicks = d3.selectAll(svgId + '.nv-x .tick.zero text')[0]
#        drawRectOnXAxisTicks xAxisTicks
#        return
#
#      callback = (chart) ->
#        chart.multibar.dispatch.on 'elementClick', (point) ->
#          newFilter =
#            source: 'nps_by_journey_type'
#            key: 'nps'
#            value: point.data.key
#          scope.$emit 'CROSSFILTER_CHANGED', newFilter
#          return
#        # X-Axis click handler
#        svgId = '#w_' + scope.widgetId + ' '
#        d3.selectAll(svgId + 'g.nv-x.nv-axis .tick.zero').on 'click', (jtId) ->
#          newFilter =
#            source: 'journey_volumes_by_journey_type'
#            key: 'journey_type'
#            value: jtId
#          scope.$emit 'CROSSFILTER_CHANGED', newFilter
#          return
#        # Apply grey color based on crossfilter selection
#        if !scope.crossFilter
#          return
#        filter = scope.crossFilter
#        d3.selectAll(svgId + '.nv-bar').classed 'deselected', (d) ->
#          filter.journey_type.length and filter.journey_type.indexOf(d.x) < 0 or filter.nps.length and filter.nps.indexOf(d.key) < 0
#        d3.selectAll(svgId + '.nv-bar').classed 'clickable', (d) ->
#          filter.journey_type.length and filter.journey_type.indexOf(d.x) >= 0
#        d3.selectAll(svgId + 'g.nv-x.nv-axis .tick.zero').classed 'selected', (jtId) ->
#          filter.journey_type.length and filter.journey_type.indexOf(jtId) >= 0
#        return
#
#      if _.every(npsValues, ((v) ->
#        v == 0
#      ))
#        data = []
#      nv.addGraph
#        generate: drawGraph
#        callback: callback
#      return
#
#    $(container).parent().resize debouncedRender
#    scope.$watch 'chartData', ((newData, oldData) ->
#      if !newData
#        return
#      debouncedRender()
#      return
#    ), true
#    return
#
#  directive