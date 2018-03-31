@app.directive 'd3HorizontalBarChart', [
  '$window'
  '$filter'
  ($window, $filter) ->
    {
    restrict: 'A'
    scope:
      data: '='
      settings: '@'
      tooltipText: '&'
      yAxisLabelFormat: '&'
    link: (scope, ele, attrs) ->
      defaultMargin = {
        top: 0
        left: 0
        right: 0
        bottom: 0
      }
      tooltip = d3.select("body").append("div") 
          .attr("class", "d3-horizontal-bar-chart-tooltip")             
          .style("opacity", 0)

      scope.$watch 'data', ((data) ->
        scope.render data
        return
      ), true

      scope.render = (data) ->
        settings = JSON.parse(scope.settings)
        margin = settings.margin || defaultMargin
        miniMargin = settings.miniMargin || defaultMargin
        duration = settings.transitionTime || 1000
        maxBarWidth = settings.maxBarWidth || 100
        miniWidth = settings.miniWidth
        miniHeight = settings.miniHeight
        width = settings.width
        height = settings.height

        svg = d3.select(ele[0])
                .html("")
                .append("svg")
                .attr("class", "d3-horizontal-bar-chart")
                .attr("preserveAspectRatio", "xMinYMin meet")
                .attr("viewBox", "0 0 " + (width + margin.left + margin.right + miniWidth + miniMargin.left + miniMargin.right) + " " + (Math.max(height + margin.top + margin.bottom, miniHeight + miniMargin.top + miniMargin.bottom)))
        mainGroupWrapper = svg.append('g')            
                      .attr("class", "mainGroupWrapper")                                                               
                      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
        mainGroup = mainGroupWrapper.append("g")
                      .attr("clip-path", "url(#clip)")
                      .style("clip-path", "url(#clip)")
                      .attr("class", "mainGroup")
        miniGroup = svg.append("g")
                      .attr("class", "miniGroup")
                      .attr("transform", "translate(" + (miniMargin.left + margin.left + width + margin.right) + "," + miniMargin.top + ")")
        brushGroup = svg.append("g")
                      .attr("class", "brushGroup")
                      .attr("transform", "translate(" + (miniMargin.left + margin.left + width + margin.right) + "," + miniMargin.top + ")")

        update = () ->
          c = d3.scale.category10()
          bar = mainGroup.selectAll(".bar")
              .data(data)

          bar.attr("y", (d,i) -> x(d.x) + (x.rangeBand() - d3.min([x.rangeBand(), maxBarWidth]))/2)
            .attr("x", (d) -> 0)
            .attr("height", d3.min([x.rangeBand(), maxBarWidth]))
            .attr("width", (d) -> y(d.y))

          bar.enter().append("rect")
            .attr("class", "bar")
            .style("fill", (d) -> c(Math.random()*10))
            .attr("y", (d,i) -> x(d.x) + (x.rangeBand() - d3.min([x.rangeBand(), maxBarWidth]))/2)
            .attr("x", (d) -> 0)
            .attr("height", d3.min([x.rangeBand(), maxBarWidth]))
            .attr("width", 0)
            .transition().duration(duration)
            .attr("width", (d) -> y(d.y))
            .style('cursor', 'pointer')

          bar.exit()
            .remove()

        brushmove = () ->
          extent = brush.extent()

          selected = miniX.domain()
            .filter((d) -> (extent[0] - miniX.rangeBand() + 1e-2 <= miniX(d)) && (miniX(d) <= extent[1] - 1e-2)) 

          miniGroup.selectAll(".bar")
            .style("fill", (d, i) -> "#e0e0e0")

          svg.selectAll(".axisX text")
            .style("font-size", textScale(selected.length))
          
          originalRange = mainXZoom.range()
          mainXZoom.domain( extent )

          x.domain(data.map((d) -> d.x))
          x.rangeBands( [ mainXZoom(originalRange[0]), mainXZoom(originalRange[1]) ], 0.4, 0)

          mainGroup.select(".axisX").call(xAxis)

          # newMaxYScale = d3.max(data, (d) -> if selected.indexOf(d.x) > -1 then d.y else 0)
          # y.domain([0, newMaxYScale])

          mainGroupWrapper.select(".axisY")
            .transition().duration(50)
            .call(yAxis)

          update()

        brushcenter = () -> 
          target = d3.event.target
          extent = brush.extent()
          size = extent[1] - extent[0]
          range = miniX.range()
          x0 = d3.min(range) + size / 2
          x1 = d3.max(range) + miniX.rangeBand() - size / 2
          center = Math.max( x0, Math.min( x1, d3.mouse(target)[1] ) )

          d3.event.stopPropagation()

          gBrush
              .call(brush.extent([center - size / 2, center + size / 2]))
              .call(brush.event)

        # Axes
        mainGroup.append('line')
            .style('stroke', '#d9dde0')
            .attr('x1', 0)
            .attr('y1', 0)
            .attr('x2', 0)
            .attr('y2', height)
        mainGroup.append('line')
            .style('stroke', '#d9dde0')
            .attr('x1', 0)
            .attr('y1', height)
            .attr('x2', width)
            .attr('y2', height)

        x = d3.scale.ordinal().rangeBands([0, height], 0.4, 0)
        miniX = d3.scale.ordinal().rangeBands([0, miniHeight], 0.4, 0)
        y = d3.scale.linear().range([0, width])
        miniY = d3.scale.linear().range([0, miniWidth])

        mainXZoom = d3.scale.linear()
          .range([0, height])
          .domain([0, height])

        xAxis = d3.svg.axis().scale(x).orient('left')
                .outerTickSize(0)
                .innerTickSize(0)
                .tickPadding(10)
        mainGroup.insert('g', ':first-child')
          .attr('class', 'axisX axis')
          .attr('transform', 'translate(0,0)')

        yAxis = d3.svg.axis().scale(y).orient('bottom')
                .innerTickSize(-height)
                .outerTickSize(0)
                .tickFormat (v) -> 
                  if scope.yAxisLabelFormat
                    scope.yAxisLabelFormat({v: v})
                  else
                    $filter('number')(v)
        mainGroupWrapper.insert('g', ':first-child')
          .attr('class', 'axisY axis')
          .attr('transform', 'translate(0,' + height + ')')

        y.domain([0, (d3.max(data, (d) -> d.y) || 100)*1.1])
        miniY.domain([0, (d3.max(data, (d) -> d.y) || 100)*1.1])
        x.domain(data.map((d) -> d.x))
        miniX.domain(data.map((d) -> d.x))

        mainGroup.select(".axisX").call(xAxis)
        mainGroupWrapper.select(".axisY").call(yAxis)

        return if data.length == 0

        # Brush
        textScale = d3.scale.linear()
          .domain([15,50])
          .range([12,6])
          .clamp(true)

        brushExtent = Math.max( 1, Math.min( 20, Math.round(data.length*0.2) ) )
        lastExtent = if data.length <= 7 then miniHeight else miniX(data[brushExtent].x)

        brush = d3.svg.brush()
            .y(miniX)
            .extent([miniX(data[0].x), lastExtent])
            .on("brush", brushmove)

        gBrush = brushGroup.append("g")
          .attr("class", "brush")
          .call(brush)
        
        gBrush.selectAll(".resize")
          .append("line")
          .attr("x2", miniWidth)

        gBrush.selectAll(".resize")
          .append("path")
          .attr("d", d3.svg.symbol().type("triangle-up").size(20))
          .attr("transform", (d,i) -> 
            if i then "translate(" + (miniWidth/2) + "," + 4 + ") rotate(180)" else "translate(" + (miniWidth/2) + "," + -4 + ") rotate(0)"
          )

        gBrush.selectAll("rect")
          .attr("width", miniWidth);

        gBrush.select(".background")
          .on("mousedown.brush", brushcenter)
          .on("touchstart.brush", brushcenter);

        # Clip path
        defs = svg.append("defs")

        defs.append("clipPath")
          .attr("id", "clip")
          .append("rect")
          .attr("x", -margin.left)
          .attr("y", 0)
          .attr("width", width + margin.left)
          .attr("height", height)

        # Mini bar chart
        miniBar = miniGroup.selectAll(".bar")
          .data(data)

        miniBar
          .attr("width", (d) -> miniY(d.y))
          .attr("y", (d,i) -> miniX(d.x) + (miniX.rangeBand() - d3.min([miniX.rangeBand(), maxBarWidth]))/2)
          .attr("height", d3.min([miniX.rangeBand(), maxBarWidth]))

        miniBar.enter().append("rect")
          .attr("class", "bar")
          .attr("x", (d) -> 0)
          .attr("width", (d) -> miniY(d.y))
          .attr("y", (d,i) -> miniX(d.x) + (miniX.rangeBand() - d3.min([miniX.rangeBand(), maxBarWidth]))/2)
          .attr("height", d3.min([miniX.rangeBand(), maxBarWidth]))

        miniBar.exit()
          .remove()

        gBrush.call(brush.event)

        # Tooltip
        mouseOut = (d) ->
          tooltip.transition()        
              .duration(500)      
              .style("opacity", 0);
        mouseOver = (d) ->
          tooltip.transition()        
              .duration(200)      
              .style("opacity", .9);      
          tooltip.html(if scope.tooltipText then scope.tooltipText({x: d.x, y: d.y}) else "<p>#{d.y}</p>")  
              .style("left", (d3.event.pageX) - 50 + "px")     
              .style("top", (d3.event.pageY + 18) + "px")
        mouseMove = (d) ->
          tooltip.style("left", (d3.event.pageX) - 50 + "px")     
                .style("top", (d3.event.pageY + 18) + "px")

        svg.selectAll('.bar')   
                .on('mouseover', mouseOver)
                .on('mouseout', mouseOut) 
                .on('mousemove', mouseMove) 
    }
]