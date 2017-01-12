@app.controller 'DealsController',
    ['$rootScope', '$document', '$scope', '$modal', '$q', '$location', 'Deal', 'Stage', '$timeout',
        ($rootScope, $document, $scope, $modal, $q, $location, Deal, Stage, $timeout) ->
            $scope.selectedDeal = null
            $scope.stagesById = {}
            $scope.columns = []

            $scope.updateColumnsHeight = ->
                blocks = $document.find('.deal-block')
                blockHeight = (blocks && blocks[0] && blocks[0].offsetHeight)
                console.log(blockHeight)
                columns = $document.find('.column-body')
                maxLength = 0
                $scope.columns.forEach (column) ->
                    if column.length > maxLength
                        maxLength = column.length
                console.log(maxLength)
                columns.each () ->
                    @style.height = (maxLength * (blockHeight + 10) + 20) + 'px'
                return true

            $q.all({ deals: Deal.all(), stages: Stage.query().$promise }).then (data) ->
                $scope.deals = data.deals
                $scope.stages = data.stages
                $scope.stages.forEach (stage, i) ->
                    stage.index = i
                    $scope.stagesById[stage.id] = stage
                    $scope.columns.push []
                $scope.deals.forEach (deal) ->
                    if deal.deal_members && deal.deal_members.length
                        deal.members = deal.deal_members.map (member) -> member.name
                    index = $scope.stagesById[deal.stage_id].index
                    $scope.columns[index].push deal
                console.log($scope.deals)
                console.log($scope.stages)
                console.log($scope.stagesById)
                $timeout $scope.updateColumnsHeight, 100

            $scope.onDealMove = (columnIndex, dealIndex) ->
                deal = console.log($scope.columns[columnIndex][dealIndex])
                $scope.columns[columnIndex].splice(dealIndex, 1)
                console.log(deal)

            $scope.onDrop = (deal, newStage) ->
#                updateColumnsHeight()
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

            $scope.showNewDealModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/deal_form.html'
                    size: 'md'
                    controller: 'DealsNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        deal: ->
                            {}

    ]