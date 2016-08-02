@app.controller 'SalesExecutionDashboardController',
  ['$scope', '$q', 'Team', 'SalesExecutionDashboard',
    ($scope, $q, Team, SalesExecutionDashboard) ->

      $scope.isDisabled = false
      $scope.selectedMember = null
      $scope.productPipelineChoice = 'weighted'
      $scope.optionsProductPipeline = {
        chart: {
          type: 'multiBarHorizontalChart',
          margin: {
            top: 30,
            right: 0,
            bottom: 30,
            left: 120
          },
          height: 200,
          x: (d) =>
            return d.label
          ,
          y: (d) =>
            return d.value
          ,

          #yErr: function(d){ return [-Math.abs(d.value * Math.random() * 0.3), Math.abs(d.value * Math.random() * 0.3)] },
          showControls: false,
          stacked: true,
          showValues: true,
          duration: 500,
          xAxis: {
            showMaxMin: false
            tickFormat: (d) =>
              return if d.length > 14 then d.substr(0, 14) + '...' else d + '   '
          },
          yAxis: {
            showMaxMin: false,
            tickFormat: (d) =>
              return if d > 10000 then '$' + d3.format(',.0f')(d/1000) + "k" else '$' + d3.format(',')(d)
          }
        }
      }

      $scope.init = () =>
        Team.all(all_teams: true).then (teams) ->
          all_members = []
          _.each teams, (team) ->
            all_members = all_members.concat(team.members)
#          $scope.teams = teams
          $scope.teams = [{
            id: 0,
            name:'All Teams',
            children: teams,
            members: all_members,
            members_count: all_members.length
          }]

          data = calculateKPIsForTeam($scope.teams[0])
          $scope.allAverageWinRate = data.averageWinRate
          $scope.allAverageCycleTime = data.averageCycleTime
          $scope.allAverageDealSize = data.averageDealSize

          $scope.selectedTeam = $scope.teams[0]

          $scope.chartProductPipe = {
            labels: ["January", "February", "March", "April", "May", "June", "July"],
            datasets: [
              {
                label: "My First dataset",
                fillColor: "rgba(220,220,220,0.5)",
                strokeColor: "rgba(220,220,220,0.8)",
                highlightFill: "rgba(220,220,220,0.75)",
                highlightStroke: "rgba(220,220,220,1)",
                data: [65, 59, 80, 81, 56, 55, 40]
              },
              {
                label: "My Second dataset",
                fillColor: "rgba(151,187,205,0.5)",
                strokeColor: "rgba(151,187,205,0.8)",
                highlightFill: "rgba(151,187,205,0.75)",
                highlightStroke: "rgba(151,187,205,1)",
                data: [28, 48, 40, 19, 86, 27, 90]
              }
            ]
          }

          $scope.chartBarOptions = {
            responsive: false,
            segmentShowStroke: true,
            segmentStrokeColor: '#fff',
            segmentStrokeWidth: 2,
            percentageInnerCutout: 70,
            animationSteps: 100,
            animationEasing: 'easeOutBounce',
            animateRotate: true,
            animateScale: false,
            scaleLabel: '<%= parseFloat(value).formatMoney() %>',
            legendTemplate : '<ul class="tc-chart-js-legend"><li class="legend_quota"><span class="swatch"></span>Quota</li><% for (var i=datasets.length-1; i>=0; i--){%><li class="legend_<%= datasets[i].label.replace(\'%\', \'\') %>"><span class="swatch" style="background-color:<%= datasets[i].fillColor %>"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>',
            multiTooltipTemplate: '<%= value.formatMoney() %>',
            tooltipTemplate: '<%= label %>: <%= value.formatMoney() %>',
            tooltipHideZero: true
          }

          $scope.chartProductPipeOption = {
            scaleBeginAtZero : true,
            scaleShowGridLines : true,
            scaleGridLineColor : "rgba(0,0,0,0.05)",
            scaleGridLineWidth : 1,
            animationSteps: 100,
            animationEasing: 'easeOutBounce',
            animateRotate: true,
            animateScale: false,
            barShowStroke : true,
            barStrokeWidth : 2,
            barValueSpacing : 5,
            relativeBars : false,
            tooltipHideZero: false
          }

          $scope.options = {
            chart: {
              type: 'historicalBarChart',
              height: 450,
              margin : {
                top: 20,
                right: 20,
                bottom: 65,
                left: 50
              },
              x: (d) =>
                return d[0]
              ,
              y: (d) =>
                return d[1]/100000
              ,
              showValues: true,
              valueFormat: (d) =>
                return d3.format(',.1f')(d);
              ,
              duration: 100,
              xAxis: {
                axisLabel: 'X Axis',
                tickFormat: (d) =>
                  return d3.time.format('%x')(new Date(d))
              },
              rotateLabels: 30,
              showMaxMin: false
            },
            yAxis: {
              axisLabel: 'Y Axis',
              axisLabelDistance: -10,
              tickFormat: (d) =>
                return d3.format(',.1f')(d)
            },
            tooltip: {
              keyFormatter: (d) =>
                return d3.time.format('%x')(new Date(d))
            },
            zoom: {
              enabled: true,
              scaleExtent: [1, 10],
              useFixedDomain: false,
              useNiceScale: false,
              horizontalOff: false,
              verticalOff: true,
              unzoomEventType: 'dblclick.zoom'
            }
          }

          $scope.data = [
            {
              "key" : "Quantity" ,
              "bar": true,
              "values" : [ [ 1136005200000 , 1271000.0] , [ 1138683600000 , 1271000.0] , [ 1141102800000 , 1271000.0] , [ 1143781200000 , 0] , [ 1146369600000 , 0] , [ 1149048000000 , 0] , [ 1151640000000 , 0] , [ 1154318400000 , 0] , [ 1156996800000 , 0] , [ 1159588800000 , 3899486.0] , [ 1162270800000 , 3899486.0] , [ 1164862800000 , 3899486.0] , [ 1167541200000 , 3564700.0] , [ 1170219600000 , 3564700.0] , [ 1172638800000 , 3564700.0] , [ 1175313600000 , 2648493.0] , [ 1177905600000 , 2648493.0] , [ 1180584000000 , 2648493.0] , [ 1183176000000 , 2522993.0] , [ 1185854400000 , 2522993.0] , [ 1188532800000 , 2522993.0] , [ 1191124800000 , 2906501.0] , [ 1193803200000 , 2906501.0] , [ 1196398800000 , 2906501.0] , [ 1199077200000 , 2206761.0] , [ 1201755600000 , 2206761.0] , [ 1204261200000 , 2206761.0] , [ 1206936000000 , 2287726.0] , [ 1209528000000 , 2287726.0] , [ 1212206400000 , 2287726.0] , [ 1214798400000 , 2732646.0] , [ 1217476800000 , 2732646.0] , [ 1220155200000 , 2732646.0] , [ 1222747200000 , 2599196.0] , [ 1225425600000 , 2599196.0] , [ 1228021200000 , 2599196.0] , [ 1230699600000 , 1924387.0] , [ 1233378000000 , 1924387.0] , [ 1235797200000 , 1924387.0] , [ 1238472000000 , 1756311.0] , [ 1241064000000 , 1756311.0] , [ 1243742400000 , 1756311.0] , [ 1246334400000 , 1743470.0] , [ 1249012800000 , 1743470.0] , [ 1251691200000 , 1743470.0] , [ 1254283200000 , 1519010.0] , [ 1256961600000 , 1519010.0] , [ 1259557200000 , 1519010.0] , [ 1262235600000 , 1591444.0] , [ 1264914000000 , 1591444.0] , [ 1267333200000 , 1591444.0] , [ 1270008000000 , 1543784.0] , [ 1272600000000 , 1543784.0] , [ 1275278400000 , 1543784.0] , [ 1277870400000 , 1309915.0] , [ 1280548800000 , 1309915.0] , [ 1283227200000 , 1309915.0] , [ 1285819200000 , 1331875.0] , [ 1288497600000 , 1331875.0] , [ 1291093200000 , 1331875.0] , [ 1293771600000 , 1331875.0] , [ 1296450000000 , 1154695.0] , [ 1298869200000 , 1154695.0] , [ 1301544000000 , 1194025.0] , [ 1304136000000 , 1194025.0] , [ 1306814400000 , 1194025.0] , [ 1309406400000 , 1194025.0] , [ 1312084800000 , 1194025.0] , [ 1314763200000 , 1244525.0] , [ 1317355200000 , 475000.0] , [ 1320033600000 , 475000.0] , [ 1322629200000 , 475000.0] , [ 1325307600000 , 690033.0] , [ 1327986000000 , 690033.0] , [ 1330491600000 , 690033.0] , [ 1333166400000 , 514733.0] , [ 1335758400000 , 514733.0]]
            }]

      updateProductPipelineData = () =>
        if ($scope.productPipelineChoice == "weighted")
          $scope.dataProductPipeline = $scope.productPipelineData.weighted
        else
          $scope.dataProductPipeline = $scope.productPipelineData.unweighted

      calculateKPIs = () =>
        $scope.averageWinRate = 0
        $scope.averageCycleTime = 0
        $scope.averageDealSize = 0

        if ($scope.selectedMember == null && $scope.selectedTeam && $scope.selectedTeam.members.length > 0)
          data = calculateKPIsForTeam($scope.selectedTeam)
          $scope.averageWinRate = data.averageWinRate
          $scope.averageCycleTime = data.averageCycleTime
          $scope.averageDealSize = data.averageDealSize
        else if ($scope.selectedMember)
          calculateKPIsForMember()

        SalesExecutionDashboard.all("member_ids[]": $scope.selectedMemberList).then (data) ->
          $scope.topDeals = data[0].top_deals
          maxValue = data[0].week_pipeline_data
          maxValue = _.max(_.map data[0].week_pipeline_data, (item) =>
            return item.value
          )

          $scope.chartWeekPipeMovement = _.map data[0].week_pipeline_data, (item) =>
            item.styles = {'width': item.value / maxValue * 100 + "%", 'background-color': item.color}
            return item

          $scope.productPipelineData = data[0].product_pipeline_data
          updateProductPipelineData()

      calculateKPIsForTeam = (team) =>
        if team.members.length > 0
          win_rate_count = 0
          cycle_time_count = 0
          deal_size_count = 0
          averageWinRate = 0
          averageCycleTime = 0
          averageDealSize = 0

          _.each team.members, (item) =>
            if (item.win_rate > 0)
              averageWinRate = averageWinRate + parseFloat(item.win_rate)
              win_rate_count = win_rate_count + 1

            if (item.cycle_time > 0)
              averageCycleTime = averageCycleTime + parseFloat(item.cycle_time)
              cycle_time_count = cycle_time_count + 1

            if (item.average_deal_size > 0)
              averageDealSize = averageDealSize + parseFloat(item.average_deal_size)
              deal_size_count = deal_size_count + 1

          if win_rate_count > 0
            averageWinRate = Number((averageWinRate / win_rate_count * 100).toFixed(0))
          if cycle_time_count > 0
            averageCycleTime = Number((averageCycleTime / cycle_time_count).toFixed(0))
          if deal_size_count > 0
            averageDealSize = Number((averageDealSize / deal_size_count / 1000).toFixed(0))

          return {averageWinRate: averageWinRate, averageCycleTime: averageCycleTime, averageDealSize: averageDealSize}

      calculateKPIsForMember = () =>
        if $scope.selectedMember
          $scope.averageWinRate = (if ($scope.selectedMember.win_rate > 0) then Number(($scope.selectedMember.win_rate * 100).toFixed(0)) else 0)
          $scope.averageCycleTime = (if ($scope.selectedMember.cycle_time > 0) then Number(($scope.selectedMember.cycle_time).toFixed(0)) else 0)
          $scope.averageDealSize = (if ($scope.selectedMember.average_deal_size > 0) then Number(($scope.selectedMember.average_deal_size / 1000).toFixed(0)) else 0)

      $scope.$watch('selectedTeam', () =>
        if ($scope.selectedTeam)
          $scope.selectedMember = null
          $scope.selectedMemberList = _.map $scope.selectedTeam.members, (item) =>
            return item.id
          calculateKPIs()
      , true);

      $scope.changeMember=(value) =>
        $scope.selectedMember = value
        $scope.selectedMemberList = [$scope.selectedMember.id]
        calculateKPIs()

      $scope.changeProductPipelineChoice=(value) =>
        $scope.productPipelineChoice = value
        updateProductPipelineData()

      $scope.init()
  ]
