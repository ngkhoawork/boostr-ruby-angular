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
          var height = 500,
              width = 1070,
              margin=30,
              offset = 50,
              usdData = [
                  {x:1, rate: 42},
                  {x:2, rate: 50},
                  {x:3, rate: 10},
                  {x:4, rate: 50},

              ],
              eurData = [
                  {x:1, rate: 42},
                  {x:2, rate: 4},
                  {x:3, rate: 15},
                  {x:4, rate: 55},
              ],
              tData = [
                  {x:1, rate: 37},
                  {x:2, rate: 41},
                  {x:3, rate: 22},
                  {x:4, rate: 6},
              ];;

          var svg = d3.select(".graph").append("svg")
              .attr("class", "axis")
              .attr("width", width)
              .attr("height", height);

          // длина оси X= ширина контейнера svg - отступ слева и справа
          var xAxisLength = width - 2 * margin;

          // длина оси Y = высота контейнера svg - отступ сверху и снизу
          var yAxisLength = height - 2 * margin;
          // находим максимальное значение для оси Y
          var maxValue = 80;
          // находим минимальное значение для оси Y
          var minValue = 0;

          // функция интерполяции значений на ось Y
          var scaleY = d3.scale.linear()
              .domain([maxValue, minValue])
              .range([0, yAxisLength]);



          var scaleX = d3.scale.linear()
              .domain([0, 4])
              .range([0, xAxisLength]);



          var xAxis = d3.svg.axis()
              .scale(scaleX)
              .orient("bottom")
              .ticks(4);

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
          createChart(tData, "#914CAF", "euro");

          // обща функция для создания графиков
          function createChart (data, colorStroke, label){

// функция, создающая по массиву точек линии
              var line = d3.svg.line()
                  .interpolate("monotone")
                  .x(function(d) { return scaleX(d.x)+margin; })
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
                  .style("fill", colorStroke)
                  .attr("class", "dot " + label)
                  .attr("r",  function(d) {return d.rate/6;})
                  .transition().duration(2000)
                  .attr("cx", function(d) { return scaleX(d.x)+margin; })
                  .attr("cy", function(d) { return scaleY(d.rate)+margin; });
          };

      `

      console.log(d3)
  ]
