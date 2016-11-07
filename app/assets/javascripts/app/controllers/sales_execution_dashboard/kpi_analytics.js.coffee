@app.controller 'KPIAnalyticsController',
  ['$scope', '$rootScope', '$modal', '$routeParams', '$location', '$window', 'User', 'ActivityType', 'TimePeriod', 'Company', 'ActivityReport',
    ($scope, $rootScope, $modal, $routeParams, $location, $window, User, ActivityType, TimePeriod, Company, ActivityReport) ->

      $scope.teamFilters = [
        { name: 'My Team', param: '' }
        { name: 'All Team', param: 'all' }
      ]

      $scope.sellerFilters = [
        { name: 'seller1', param: 'seller1' }
        { name: 'seller2', param: 'seller2' }
        { name: 'seller3', param: 'seller3' }
      ]

      $scope.timeFilters = [
        { name: 'period1', param: 'period1' }
        { name: 'period1', param: 'period1' }
      ]

      $scope.productFilters = [
        { name: 'product1', param: 'product1' }
        { name: 'product2', param: 'product2' }
      ]

      `
          // var dataset = [{"id":109, "time":1362145698957, "userName":"perky", "activity":"caught pacman"},
          //     {"id":110, "time":1362145696050, "userName":"pinky", "activity":"respawn"},
          //     {"id":111, "time":1362145553187, "userName":"perky", "activity":"change direction"},
          //     {"id":111, "time":1362145523957, "userName":"perky", "activity":"change direction"},
          //     {"id":111, "time":1362068521903, "userName":"perky", "activity":"respawn"},
          //     {"id":111, "time":1362067554943, "userName":"perky", "activity":"change direction"},
          //     {"id":111, "time":1362066127737, "userName":"perky", "activity":"change direction"},
          //     {"id":112, "time":1362063878087, "userName":"clyde", "activity":"caught pacman"},
          //     {"id":113, "time":1362060704480, "userName":"perky", "activity":"respawn"},
          //     {"id":114, "time":1362055941193, "userName":"perky", "activity":"caught pacman"},
          //     {"id":115, "time":1362053409677, "userName":"clyde", "activity":"caught pacman"},
          //     {"id":116, "time":1362050389927, "userName":"perky", "activity":"caught pacman"},
          //     {"id":117, "time":1362049688533, "userName":"perky", "activity":"caught pacman"},
          //     {"id":118, "time":1362048768800, "userName":"pinky", "activity":"respawn"},
          //     {"id":119, "time":1361984202243, "userName":"clyde", "activity":"respawn"},
          //     {"id":120, "time":1361983730340, "userName":"clyde", "activity":"caught pacman"},
          //     {"id":121, "time":1361982886800, "userName":"perky", "activity":"respawn"},
          //     {"id":122, "time":1361982415347, "userName":"perky", "activity":"change direction"},
          //     {"id":123, "time":1361981332543, "userName":"pinky", "activity":"caught pacman"},
          //     {"id":124, "time":1361873308440, "userName":"clyde", "activity":"change direction"}]
          //
          // var dateFormat = d3.time.format("%x"),
          //     nestedData = d3.nest()
          //         .key(function(d) { return d.activity; })
          //         .key(function(d) {return dateFormat(new Date(d.time));})
          //         .entries(dataset);
          //
          // var margin = {top: 20, right: 80, bottom: 30, left: 50},
          //     width = 700 - margin.left - margin.right,
          //     height = 400 - margin.top - margin.bottom,
          //     min = d3.min(nestedData, function(datum) {
          //         return d3.min(datum.values, function(d) { return d.values.length; });
          //     }),
          //     max = d3.max(nestedData, function(datum) {
          //         return d3.max(datum.values, function(d) { return d.values.length; });
          //     });
          //
          // var x = d3.time.scale().range([0, width]);
          // var y = d3.scale.linear().range([height, 0]);
          //
          // var xAxis = d3.svg.axis()
          //     .scale(x)
          //     .orient("bottom")
          //     .ticks(d3.time.days, 1)
          //     .tickFormat(d3.time.format("%d-%b-%Y"))
          //     .tickSize(height +6, 6, 0);
          //
          // var yAxis = d3.svg.axis()
          //     .scale(y)
          //     .orient("right")
          //     .ticks(max)
          //     .tickSubdivide(true)
          //     .tickFormat(d3.format("d"))
          //     .tickSize(width +6, width +6, 0);
          //
          // var color = d3.scale.category10();
          //
          // var svg = d3.select(".graph").append("svg")
          //     .attr("width", width + margin.left + margin.right)
          //     .attr("height", height + margin.top + margin.bottom)
          //     .append("g")
          //     .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
          //
          // drawMainGraph();
          //
          // function drawMainGraph() {
          //
          //     var line = d3.svg.line()
          //         .interpolate("monotone") // linear, cardinal or monotone are good
          //         .x( function(d) {return x(dateFormat.parse(d.key)) } )
          //         .y( function(d) {return y(d.values.length) } );
          //
          //     x.domain(d3.extent( dataset, function(d) { return d3.time.day(new Date(d.time)) } ));
          //     y.domain([min, max]);
          //
          //     // append a rectangle which will be the charts background:
          //     svg.append("svg:rect")
          //         .attr("x", 0)
          //         .attr("y", 0)
          //         .attr("height", height)
          //         .attr("width", width)
          //         .attr("fill", "#E6E6E6");
          //
          //     // Add a title:
          //     svg.append("svg:text")
          //         .attr("x", width/4)
          //         .attr("y", 20)
          //         .attr("style", "font-size: 12; font-family: Helvetica, sans-serif")
          //         .text("Daily Activities");
          //
          //     svg.append("g")
          //         .attr("class", "grid")
          //         //.attr("transform", "translate(0," + height + ")")
          //         .call(xAxis);
          //
          //     svg.append("g")
          //         .attr("class", "grid")
          //         .call(yAxis)
          //         .append("text")
          //         .attr("transform", "rotate(-90)")
          //         .attr("y", 6)
          //         .attr("dy", ".71em")
          //         .attr("style", "font-size: 10; font-family: Helvetica, sans-serif")
          //         .style("text-anchor", "end")
          //         .text("Count");
          //
          //     var activityLine = svg.selectAll(".activity")
          //         .data( nestedData )
          //         .enter()
          //         .append("g")
          //         .attr("class", "activity")
          //         .attr("id", function(d) { return d.key } );
          //
          //     activityLine.append("path")
          //         .attr("class", "line")
          //         .attr("d", function(d) { return line(d.values); } )
          //         .style("stroke", function(d) { return color(d.key); } )
          //         .attr("fill", "none")
          //         .attr("stroke-width", 4.8)
          //         .attr("stroke-opacity", 0.0001)
          //         .transition().duration(2000)
          //         .attr("stroke-opacity", 1)
          //         .attr("stroke-width", 2.8);
          //
          //     activityLine.selectAll("circle")
          //         .data(function(d) {
          //             console.log(d);
          //             return(d.values);
          //         })
          //         .enter().append("circle")
          //         .attr("stroke", function(d, i) {
          //             if(d.values[i])
          //                 return color(d.values[i].activity);
          //         })
          //         .attr("cx", function(d) {
          //             return x(dateFormat.parse(d.key));
          //         })
          //         .attr("cy", function(d) {
          //             return y(d.values.length);
          //         })
          //         .attr("stroke-width", 4.8)
          //         .attr("fill", "white")
          //         .attr("r", 6)
          //         .attr("stroke-opacity", 0.0001)
          //         .attr("fill-opacity", 0.0001)
          //         .transition().delay(1000).duration(1500)
          //         .attr("stroke-opacity", 1)
          //         .attr("fill-opacity", 1)
          //         .attr("stroke-width", 2.8)
          //         .attr("r", 3.4);
          // }


          // / ======================================================graph2
          //
          // var margin = {
          //     top: 30,
          //     right: 20,
          //     bottom: 30,
          //     left: 50
          // };
          // var width = 600 - margin.left - margin.right;
          // var height = 270 - margin.top - margin.bottom;
          //
          // var parseDate = d3.time.format("%d-%b-%y").parse;
          //
          // var x = d3.time.scale().range([0, width]);
          // var y = d3.scale.linear().range([height, 0]);
          //
          // var xAxis = d3.svg.axis().scale(x)
          //     .orient("bottom").ticks(5);
          //
          // var yAxis = d3.svg.axis().scale(y)
          //     .orient("left").ticks(5);
          //
          // var valueline = d3.svg.line()
          //     .x(function (d) {
          //         return x(d.date);
          //     })
          //     .y(function (d) {
          //         return y(d.close);
          //     });
          //
          // var svg = d3.select(".graph2")
          //     .append("svg")
          //     .attr("width", width + margin.left + margin.right)
          //     .attr("height", height + margin.top + margin.bottom)
          //     .append("g")
          //     .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
          //
          // // Get the data
          // var data = [{
          //     date: "1-May-12",
          //     close: "58.13"
          // }, {
          //     date: "30-Apr-12",
          //     close: "53.98"
          // }, {
          //     date: "27-Apr-12",
          //     close: "67.00"
          // }, {
          //     date: "26-Apr-12",
          //     close: "89.70"
          // }, {
          //     date: "25-Apr-12",
          //     close: "99.00"
          // }];
          //
          // data.forEach(function (d) {
          //     d.date = parseDate(d.date);
          //     d.close = +d.close;
          // });
          //
          // // Scale the range of the data
          // x.domain(d3.extent(data, function (d) {
          //     return d.date;
          // }));
          // y.domain([0, d3.max(data, function (d) {
          //     return d.close;
          // })]);
          //
          // svg.append("path") // Add the valueline path.
          //     .attr("d", valueline(data));
          //
          // svg.append("g") // Add the X Axis
          //     .attr("class", "x axis")
          //     .attr("transform", "translate(0," + height + ")")
          //     .call(xAxis);
          //
          // svg.append("g") // Add the Y Axis
          //     .attr("class", "y axis")
          //     .call(yAxis);



// =======================================graph4================================================


          // var data = [ { label: "Data Set 1",
          //     x: [0, 1, 2, 3, 4],
          //     y: [0, 1, 2, 3, 4] },
          //     { label: "Data Set 2",
          //         x: [0, 1, 2, 3, 4],
          //         y: [0, 1, 4, 9, 16] } ] ;
          // var xy_chart = d3_xy_chart()
          //     .width(960)
          //     .height(500)
          //     .xlabel("X Axis")
          //     .ylabel("Y Axis") ;
          // var svg = d3.select(".graph4").append("svg")
          //     .datum(data)
          //     .call(xy_chart) ;
          //
          // function d3_xy_chart() {
          //     var width = 640,
          //         height = 480,
          //         xlabel = "X Axis Label",
          //         ylabel = "Y Axis Label" ;
          //
          //     function chart(selection) {
          //         selection.each(function(datasets) {
          //             //
          //             // Create the plot.
          //             //
          //             var margin = {top: 20, right: 80, bottom: 30, left: 50},
          //                 innerwidth = width - margin.left - margin.right,
          //                 innerheight = height - margin.top - margin.bottom ;
          //
          //             var x_scale = d3.scale.linear()
          //                 .range([0, innerwidth])
          //                 .domain([ d3.min(datasets, function(d) { return d3.min(d.x); }),
          //                     d3.max(datasets, function(d) { return d3.max(d.x); }) ]) ;
          //
          //             var y_scale = d3.scale.linear()
          //                 .range([innerheight, 0])
          //                 .domain([ d3.min(datasets, function(d) { return d3.min(d.y); }),
          //                     d3.max(datasets, function(d) { return d3.max(d.y); }) ]) ;
          //
          //             var color_scale = d3.scale.category10()
          //                 .domain(d3.range(datasets.length)) ;
          //
          //             var x_axis = d3.svg.axis()
          //                 .scale(x_scale)
          //                 .orient("bottom") ;
          //
          //             var y_axis = d3.svg.axis()
          //                 .scale(y_scale)
          //                 .orient("left") ;
          //
          //             var x_grid = d3.svg.axis()
          //                 .scale(x_scale)
          //                 .orient("bottom")
          //                 .tickSize(-innerheight)
          //                 .tickFormat("") ;
          //
          //             var y_grid = d3.svg.axis()
          //                 .scale(y_scale)
          //                 .orient("left")
          //                 .tickSize(-innerwidth)
          //                 .tickFormat("") ;
          //
          //             var draw_line = d3.svg.line()
          //                 .interpolate("basis")
          //                 .x(function(d) { return x_scale(d[0]); })
          //                 .y(function(d) { return y_scale(d[1]); }) ;
          //
          //             var svg = d3.select(this)
          //                 .attr("width", width)
          //                 .attr("height", height)
          //                 .append("g")
          //                 .attr("transform", "translate(" + margin.left + "," + margin.top + ")") ;
          //
          //             svg.append("g")
          //                 .attr("class", "x grid")
          //                 .attr("transform", "translate(0," + innerheight + ")")
          //                 .call(x_grid) ;
          //
          //             svg.append("g")
          //                 .attr("class", "y grid")
          //                 .call(y_grid) ;
          //
          //             svg.append("g")
          //                 .attr("class", "x axis")
          //                 .attr("transform", "translate(0," + innerheight + ")")
          //                 .call(x_axis)
          //                 .append("text")
          //                 .attr("dy", "-.71em")
          //                 .attr("x", innerwidth)
          //                 .style("text-anchor", "end")
          //                 .text(xlabel) ;
          //
          //             svg.append("g")
          //                 .attr("class", "y axis")
          //                 .call(y_axis)
          //                 .append("text")
          //                 .attr("transform", "rotate(-90)")
          //                 .attr("y", 6)
          //                 .attr("dy", "0.71em")
          //                 .style("text-anchor", "end")
          //                 .text(ylabel) ;
          //
          //             var data_lines = svg.selectAll(".d3_xy_chart_line")
          //                 .data(datasets.map(function(d) {return d3.zip(d.x, d.y);}))
          //                 .enter().append("g")
          //                 .attr("class", "d3_xy_chart_line") ;
          //
          //             data_lines.append("path")
          //                 .attr("class", "line")
          //                 .attr("d", function(d) {return draw_line(d); })
          //                 .attr("stroke", function(_, i) {return color_scale(i);}) ;
          //
          //             data_lines.append("text")
          //                 .datum(function(d, i) { return {name: datasets[i].label, final: d[d.length-1]}; })
          //                 .attr("transform", function(d) {
          //                     return ( "translate(" + x_scale(d.final[0]) + "," +
          //                     y_scale(d.final[1]) + ")" ) ; })
          //                 .attr("x", 3)
          //                 .attr("dy", ".35em")
          //                 .attr("fill", function(_, i) { return color_scale(i); })
          //                 .text(function(d) { return d.name; }) ;
          //
          //         }) ;
          //     }
          //
          //     chart.width = function(value) {
          //         if (!arguments.length) return width;
          //         width = value;
          //         return chart;
          //     };
          //
          //     chart.height = function(value) {
          //         if (!arguments.length) return height;
          //         height = value;
          //         return chart;
          //     };
          //
          //     chart.xlabel = function(value) {
          //         if(!arguments.length) return xlabel ;
          //         xlabel = value ;
          //         return chart ;
          //     } ;
          //
          //     chart.ylabel = function(value) {
          //         if(!arguments.length) return ylabel ;
          //         ylabel = value ;
          //         return chart ;
          //     } ;
          //
          //     return chart;
          // }


// ========================================================graph5=============================================


          var height = 500,
              width = 1070,
              margin=30,
              usdData = [
                  {date: new Date(2015, 02, 19), rate: 61.34},
                  {date: new Date(2015, 02, 24), rate: 59.44},
                  {date: new Date(2015, 02, 28), rate: 57.72},
                  {date: new Date(2015, 03, 3), rate: 56.99},
                  {date: new Date(2015, 03, 8), rate: 55.33},
                  {date: new Date(2015, 03, 11), rate: 51.06},
              ],
              eurData = [
                  {date: new Date(2015, 02, 19), rate: 65.01},
                  {date: new Date(2015, 02, 24), rate: 64.15},
                  {date: new Date(2015, 02, 28), rate: 62.56},
                  {date: new Date(2015, 03, 3), rate: 61.69},
                  {date: new Date(2015, 03, 8), rate: 60.41},
                  {date: new Date(2015, 03, 11), rate: 54.27},
              ];

          var svg = d3.select(".graph5").append("svg")
              .attr("class", "axis")
              .attr("width", width)
              .attr("height", height);

          // длина оси X= ширина контейнера svg - отступ слева и справа
          var xAxisLength = width - 2 * margin;

          // длина оси Y = высота контейнера svg - отступ сверху и снизу
          var yAxisLength = height - 2 * margin;
          // находим максимальное значение для оси Y
          var maxValue = d3.max([d3.max(eurData, function(d) { return d.rate; }),
              d3.max(usdData, function(d) { return d.rate; })]);
          // находим минимальное значение для оси Y
          var minValue = d3.min([d3.min(eurData, function(d) { return d.rate; }),
              d3.min(usdData, function(d) { return d.rate; })]);

          // функция интерполяции значений на ось Х
          var scaleX = d3.time.scale() // от 1 января 2015 года до текущей даты
              .domain([d3.min(usdData, function(d) { return d.date; }),
                  d3.max(usdData, function(d) { return d.date; })])
              .range([0, xAxisLength]);

          // функция интерполяции значений на ось Y
          var scaleY = d3.scale.linear()
              .domain([maxValue, minValue])
              .range([0, yAxisLength]);
          // создаем ось X
          var xAxis = d3.svg.axis()
              .scale(scaleX)
              .orient("bottom")
              .tickFormat(d3.time.format('%e.%m'));
          // создаем ось Y
          var yAxis = d3.svg.axis()
              .scale(scaleY)
              .orient("left");

          // отрисовка оси Х
          svg.append("g")
              .attr("class", "x-axis")
              .attr("transform",  // сдвиг оси вниз и вправо
                  "translate(" + margin + "," + (height - margin) + ")")
              .call(xAxis);

          // отрисовка оси Y
          svg.append("g")
              .attr("class", "y-axis")
              .attr("transform", // сдвиг оси вниз и вправо на margin
                  "translate(" + margin + "," + margin + ")")
              .call(yAxis);

          // создаем набор вертикальных линий для сетки
          d3.selectAll("g.x-axis g.tick")
              .append("line") // добавляем линию
              .classed("grid-line", true) // добавляем класс
              .attr("x1", 0)
              .attr("y1", 0)
              .attr("x2", 0)
              .attr("y2", - (height - 2 * margin));

          // рисуем горизонтальные линии
          d3.selectAll("g.y-axis g.tick")
              .append("line")
              .classed("grid-line", true)
              .attr("x1", 0)
              .attr("y1", 0)
              .attr("x2", xAxisLength)
              .attr("y2", 0);
          createChart(usdData, "steelblue", "usd");
          createChart(eurData, "#FF7F0E", "euro");

          // обща функция для создания графиков
          function createChart (data, colorStroke, label){

// функция, создающая по массиву точек линии
              var line = d3.svg.line()
                  .x(function(d) { return scaleX(d.date)+margin; })
                  .y(function(d){return scaleY(d.rate)+margin;});

              var g = svg.append("g");
              g.append("path")
                  .attr("d", line(data))
                  .style("stroke", colorStroke)
                  .style("stroke-width", 2);

// добавляем отметки к точкам
              svg.selectAll(".dot "+ label)
                  .data(data)
                  .enter().append("circle")
                  .style("stroke", colorStroke)
                  .style("fill", "white")
                  .attr("class", "dot " + label)
                  .attr("r", 3.5)
                  .attr("cx", function(d) { return scaleX(d.date)+margin; })
                  .attr("cy", function(d) { return scaleY(d.rate)+margin; });
          };






      `

      console.log(d3)
  ]
