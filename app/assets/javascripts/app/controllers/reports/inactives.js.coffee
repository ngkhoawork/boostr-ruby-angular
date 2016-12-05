@app.controller 'InactivesController',
    ['$scope', '$document', 'Product', 'Field'
        ($scope, $document, Product, Field) ->

            generateData = (n) ->
                arr = []
                for i in [1...n + 1]
                    arr.push {
                        name: 'Company ' + i
                        average: (Math.round(Math.random() * 100) + 5) * 10000
                        open: (Math.round(Math.random() * 100) + 1) * 10000
                        seller: 'Seller ' + i
                    }
                arr

            data = generateData(5)
            $scope.data = angular.copy data
            data.reverse()

            margin =
                top: 20
                right: 50
                bottom: 70
                left: 80
            width = 1000
            height = data.length * 90

            x = d3.scale.linear().range([
                0
                width
            ], .05)
            y = d3.scale.ordinal().rangeRoundBands([
                height
                0
            ])
            xAxis = d3.svg.axis()
                .scale(x)
                .orient('bottom')
                .ticks(5)
                .tickFormat (v) ->
                    if v > 0 then return '$' + v.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") else v

            yAxis = d3.svg.axis()
                .scale(y)
                .orient('left')

            svg = d3.select('#inactive-chart')
                .attr('width', width + margin.left + margin.right)
                .attr('height', height + margin.top + margin.bottom)
                .append('g')
                    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

            y.domain data.map((d) ->
                d.name
            )
            x.domain [
                0
                d3.max(data, (d) ->
                    Math.max(d.average, d.open)
                )
            ]
            svg.append('g')
                .attr('class', 'x axis')
                .attr('transform', 'translate(0,' + height + ')')
                .call(xAxis)
                .selectAll('text')
                .style('text-anchor', 'middle')
                .attr('y', 16)
            svg.append('g')
                .attr('class', 'y axis')
                .call(yAxis)
                .append('text')
                .attr('transform', 'rotate(-90)')
                .attr('y', 6)
                .attr('dy', '.71em')
                .style('text-anchor', 'end')
            barWidth = 25
            barsWithData = svg.selectAll('bar').data(data).enter()
            barsWithData
                .append('rect')
                    .style('fill', '#3498DB')
                    .attr('height', barWidth)
                    .attr('x', 1)
                    .attr 'y', (d) ->
                        (y(d.name) + (y.rangeBand() - barWidth) / 2) - (barWidth / 2 + 4)
                    .attr 'width', 0
                    .transition()
                    .duration 1000
                    .delay 300
                    .attr 'width', (d) ->
                        console.log(d.average, x(d.average))
                        x(d.average)
            barsWithData
                .append('rect')
                    .style('fill', '#8CC135')
                    .attr('height', barWidth)
                    .attr('x', 1)
                    .attr 'y', (d) ->
                        (y(d.name) + (y.rangeBand() - barWidth) / 2) + (barWidth / 2 + 4)
                    .attr 'width', 0
                    .transition()
                    .duration 1000
                    .delay 300
                    .attr 'width', (d) ->
                        x(d.open)

    ]