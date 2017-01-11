@app.controller 'DealsController',
    ['$rootScope', '$scope', '$modal', '$filter', '$routeParams', '$q', '$location', '$window', 'Deal', 'Stage', 'Contact',
        ($rootScope, $scope, $modal, $filter, $routeParams, $q, $location, $window, Deal, Stage, Contact) ->
            $scope.selectedDeal = null
            $scope.stagesById = {}
            $scope.columnNames = [
                'Prospecting'
                'Discuss Requirements'
                'Proposal'
                'Negotiation'
                'Verbal Commit'
                'Test1'
                'Test2'
                'Test3'
            ]
            $scope.columns = []

#            for i in [1...30]
#                $scope.columns[Math.round(Math.random() * 3)].push(
#                    {name: 'Item ' + i, company: 'Company ' + i, seller: 'John Seller', revenue: i}
#                )



            document.addEventListener('keydown', (e) ->
                if e.code is 'Space' then console.dir($scope.columns)
            )

            $q.all({ deals: Deal.all(), stages: Stage.query().$promise }).then (data) ->
                $scope.deals = data.deals
                $scope.stages = data.stages
                $scope.stages.forEach (stage, i) ->
                    stage.index = i
                    $scope.stagesById[stage.id] = stage
                    $scope.columns.push []
                $scope.deals.forEach (deal) ->
                    console.log(deal.next_steps)
                    index = $scope.stagesById[deal.stage_id].index
                    $scope.columns[index].push deal
                console.log($scope.deals)
                console.log($scope.stages)
                console.log($scope.stagesById)

            $scope.onDealMove = (columnIndex, dealIndex) ->
                deal = console.log($scope.columns[columnIndex][dealIndex])
                $scope.columns[columnIndex].splice(dealIndex, 1)
                console.log(deal)

            $scope.onDrop = (deal, newStage) ->
                console.log(deal, newStage)
                deal

            $scope.calcWeighted = (deals) ->
                weighted = 0
                deals.forEach (deal) ->
                    weighted += parseInt(deal.budget) || 0
                weighted

            $scope.calcUnweighted = (deals, stage) ->
                unweighted = 0
                mod = if stage.probability is 0 then 0 else stage.probability / 100
                deals.forEach (deal) ->
                    unweighted += (parseInt(deal.budget) || 0) * mod
                unweighted


    ]