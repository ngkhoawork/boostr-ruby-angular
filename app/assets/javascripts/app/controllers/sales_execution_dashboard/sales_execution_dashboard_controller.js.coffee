@app.controller 'SalesExecutionDashboardController',
  ['$scope', '$q', 'Team', 'SalesExecutionDashboard',
    ($scope, $q, Team, SalesExecutionDashboard) ->

      $scope.isDisabled = false;

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
          $scope.activeItem = {
            id: 0
          }

      calculateKPIs = () =>
        $scope.averageWinRate = 0
        $scope.averageCycleTime = 0
        $scope.averageDealSize = 0

        $scope.minWinRate = 0
        $scope.minCycleTime = 0
        $scope.minDealSize = 0

        $scope.maxWinRate = 0
        $scope.maxCycleTime = 0
        $scope.maxDealSize = 0
        if ($scope.selectedMember == null && $scope.selectedTeam)
          calculateKPIsForTeam()
        else if ($scope.selectedMember)
          calculateKPIsForMember()

        SalesExecutionDashboard.all("member_ids[]": $scope.selectedMemberList).then (data) ->
          $scope.topDeals = data[0].top_deals
          $scope.chartWeekPipeMovement = {
            labels: ["Pipeline Added", "Pipeline Won", "Pipeline Lost"],
            datasets: [
              {
                label: "My First dataset",
                backgroundColor: [
                  'rgba(255, 99, 132, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(255, 159, 64, 0.2)'
                ],
                borderColor: [
                  'rgba(255,99,132,1)',
                  'rgba(54, 162, 235, 1)',
                  'rgba(255, 159, 64, 1)'
                ],
                fillColor: 'rgba(151,187,205,0.5)',
                strokeColor: 'rgba(151,187,205,0.8)',
                highlightFill: 'rgba(151,187,205,0.75)',
                highlightStroke: 'rgba(151,187,205,1)',
                borderWidth: 1,
                data: [data[0].week_pipeline_data.pipeline_added, data[0].week_pipeline_data.pipeline_won, data[0].week_pipeline_data.pipeline_lost],
              }
            ]
          }

          $scope.chartWeekPipeMovementOptions = {
            scales: {
              xAxes: [{
                stacked: true
              }],
              yAxes: [{
                stacked: true
              }]
            }
          }
#
#          {
#            responsive: true,
#            scaleBeginAtZero : true,
#            scaleShowGridLines : true,
#            scaleGridLineColor : "rgba(0,0,0,.05)",
#            scaleGridLineWidth : 1,
#            barShowStroke : true,
#            barStrokeWidth : 2,
#            barValueSpacing : 5,
#            barDatasetSpacing : 1
#          };
          console.log($scope)


      calculateKPIsForTeam = () =>
        if $scope.selectedTeam.members.length > 0
          $scope.minWinRate = (if ($scope.selectedTeam.members[0].win_rate > 0) then $scope.selectedTeam.members[0].win_rate else 0)
          $scope.minCycleTime = (if ($scope.selectedTeam.members[0].cycle_time > 0) then $scope.selectedTeam.members[0].cycle_time else 0)
          $scope.minDealSize = (if ($scope.selectedTeam.members[0].average_deal_size > 0) then $scope.selectedTeam.members[0].average_deal_size else 0)

          $scope.maxWinRate = (if ($scope.selectedTeam.members[0].win_rate > 0) then $scope.selectedTeam.members[0].win_rate else 0)
          $scope.maxCycleTime = (if ($scope.selectedTeam.members[0].cycle_time > 0) then $scope.selectedTeam.members[0].cycle_time else 0)
          $scope.maxDealSize = (if ($scope.selectedTeam.members[0].average_deal_size > 0) then $scope.selectedTeam.members[0].average_deal_size else 0)

          _.each $scope.selectedTeam.members, (item) =>
            $scope.averageWinRate += (if (item.win_rate > 0) then parseFloat(item.win_rate) else 0)
            $scope.averageCycleTime += (if (item.cycle_time > 0) then parseFloat(item.cycle_time) else 0)
            $scope.averageDealSize += (if (item.average_deal_size > 0) then parseFloat(item.average_deal_size) else 0)

            if (item.win_rate > 0)
              if (item.win_rate < $scope.minWinRate)
                $scope.minWinRate = item.win_rate
              if (item.win_rate > $scope.maxWinRate)
                $scope.maxWinRate = item.win_rate

            if (item.cycle_time > 0)
              if (item.cycle_time < $scope.minCycleTime)
                $scope.minCycleTime = item.cycle_time
              if (item.cycle_time > $scope.maxCycleTime)
                $scope.maxCycleTime = item.cycle_time

            if (item.average_deal_size > 0)
              if (item.average_deal_size < $scope.minDealSize)
                $scope.minDealSize = item.average_deal_size
              if (item.average_deal_size > $scope.maxDealSize)
                $scope.maxDealSize = item.average_deal_size

          if $scope.selectedTeam.members.length > 0
            $scope.averageWinRate = Number(($scope.averageWinRate / $scope.selectedTeam.members.length * 100).toFixed(0))
            $scope.averageCycleTime = Number(($scope.averageCycleTime / $scope.selectedTeam.members.length).toFixed(0))
            $scope.averageDealSize = Number(($scope.averageCycleTime / $scope.selectedTeam.members.length / 1000).toFixed(0))

            $scope.maxWinRate = Number(($scope.maxWinRate * 100).toFixed(0))
            $scope.maxCycleTime = Number(($scope.maxCycleTime).toFixed(0))
            $scope.maxDealSize = Number(($scope.maxDealSize / 1000).toFixed(0))

            $scope.minWinRate = Number(($scope.minWinRate).toFixed(0))
            $scope.minCycleTime = Number(($scope.minCycleTime).toFixed(0))
            $scope.minDealSize = Number(($scope.minDealSize / 1000).toFixed(0))
#          console.log($scope)

      calculateKPIsForMember = () =>
        if $scope.selectedMember
          $scope.minWinRate = (if ($scope.selectedMember.win_rate > 0) then Number(($scope.selectedMember.win_rate * 100).toFixed(0)) else 0)
          $scope.minCycleTime = (if ($scope.selectedMember.cycle_time > 0) then Number(($scope.selectedMember.cycle_time).toFixed(0)) else 0)
          $scope.minDealSize = (if ($scope.selectedMember.average_deal_size > 0) then Number(($scope.selectedMember.average_deal_size / 1000).toFixed(0)) else 0)

          $scope.maxWinRate = (if ($scope.selectedMember.win_rate > 0) then Number(($scope.selectedMember.win_rate * 100).toFixed(0)) else 0)
          $scope.maxCycleTime = (if ($scope.selectedMember.cycle_time > 0) then Number(($scope.selectedMember.cycle_time).toFixed(0)) else 0)
          $scope.maxDealSize = (if ($scope.selectedMember.average_deal_size > 0) then Number(($scope.selectedMember.average_deal_size / 1000).toFixed(0)) else 0)

          $scope.averageWinRate = (if ($scope.selectedMember.win_rate > 0) then Number(($scope.selectedMember.win_rate * 100).toFixed(0)) else 0)
          $scope.averageCycleTime = (if ($scope.selectedMember.cycle_time > 0) then Number(($scope.selectedMember.cycle_time).toFixed(0)) else 0)
          $scope.averageDealSize = (if ($scope.selectedMember.average_deal_size > 0) then Number(($scope.selectedMember.average_deal_size / 1000).toFixed(0)) else 0)

      $scope.changeTeam=(value) =>
        if (value)
          $scope.selectedTeam = value
          $scope.selectedMember = null
          $scope.selectedMemberList = _.map $scope.selectedTeam.members, (item) =>
            return item.id
          calculateKPIs()



      $scope.changeMember=(value) =>
        $scope.selectedMember = value
        $scope.selectedMemberList = [value.id]
        calculateKPIs()
      $scope.init()
  ]
