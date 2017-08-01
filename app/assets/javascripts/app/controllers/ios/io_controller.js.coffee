@app.controller 'IOController',
    ['$scope', '$modal', '$filter', '$timeout', '$routeParams', '$location', '$q', 'IO', 'IOMember', 'ContentFee', 'User', 'CurrentUser', 'DisplayLineItem', 'Company', 'InfluencerContentFee'
    ( $scope,   $modal,   $filter,   $timeout,   $routeParams,   $location,   $q,   IO,   IOMember,   ContentFee,   User,   CurrentUser,   DisplayLineItem,   Company,   InfluencerContentFee) ->
            $scope.currentIO = {}
            $scope.activeTab = 'ios'
            $scope.currency_symbol = '$'
            $scope.selectedIORow = null
            $scope.budgets = []
            $scope.canEditIO = true
            $scope.isNaN = (val) -> isNaN val

            $scope.init = ->
                CurrentUser.get().$promise.then (user) ->
                    $scope.currentUser = user
                Company.get().$promise.then (company) ->
                    $scope.company = company
                    $scope.canEditIO = $scope.company.io_permission[$scope.currentUser.user_type]
                    console.log('$scope.canEditIO', $scope.canEditIO)
                IO.get($routeParams.id).then (io) ->
                    $scope.currentIO = io
                    if $scope.currentIO.influencer_content_fees
                        $scope.currentIO.total_influencer_gross = 0
                        $scope.currentIO.total_influencer_net = 0

                        _.each $scope.currentIO.influencer_content_fees, (influencer_content_fee) ->
                          $scope.currentIO.total_influencer_gross += parseFloat(influencer_content_fee.gross_amount_loc)
                        _.each $scope.currentIO.influencer_content_fees, (influencer_content_fee) ->
                          $scope.currentIO.total_influencer_net += parseFloat(influencer_content_fee.net_loc)
                    if io.currency
                        if io.currency.curr_symbol
                            $scope.currency_symbol = io.currency.curr_symbol

            $scope.showIOEditModal = (io) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/io_form.html'
                    size: 'md'
                    controller: 'IOEditController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        io: ->
                            io
                .result.then (updated_io) ->
                    if (updated_io)
                        $scope.init();

            $scope.showWarningModal = (message) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/deal_warning.html'
                    size: 'md'
                    controller: 'DealWarningController'
                    backdrop: 'static'
                    keyboard: true
                    resolve:
                        message: -> message
            $scope.showEditInfluencerContentFeeModal = (influencerContentFee)->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/influencer_content_fee_form.html'
                    size: 'md'
                    controller: 'InfluencerContentFeesEditController'
                    backdrop: 'static'
                    keyboard: true
                    resolve:
                        influencerContentFee: -> influencerContentFee
                        io: -> $scope.currentIO
            $scope.showNewInfluencerContentFeeModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/influencer_content_fee_form.html'
                    size: 'md'
                    controller: 'InfluencerContentFeesNewController'
                    backdrop: 'static'
                    keyboard: true
                    resolve:
                        io: -> $scope.currentIO
            $scope.updateInfluencerBudget = (influencerContentFee) ->
                if confirm('Are you sure you want to update content fee budget with "' +  influencerContentFee.influencer.name + '"?')
                    InfluencerContentFee.update_budget(io_id: $scope.currentIO.id, id: influencerContentFee.id, influencer_content_fee: influencerContentFee).then(
                        (data) ->
                            $scope.init()
                        (resp) ->
                            for key, error of resp.data.errors
                                $scope.errors[key] = error && error[0]
                    )
            $scope.deleteInfluencerContentFee = (influencerContentFee) ->
                if confirm('Are you sure you want to unassign "' +  influencerContentFee.influencer.name + '"?')
                    InfluencerContentFee.delete(io_id: $scope.currentIO.id, id: influencerContentFee.id).then(
                        (data) ->
                            $scope.init()
                        (resp) ->
                            for key, error of resp.data.errors
                                $scope.errors[key] = error && error[0]
                    )

            $scope.deleteIo = (io) ->
                if confirm('Are you sure you want to delete "' +  io.name + '"?')
                    IO.delete(io).then(
                        (data) ->
                            $location.path('/revenue')
                        (resp) ->
                            for key, error of resp.data.errors
                                $scope.errors[key] = error && error[0]
                    )

            $scope.showLinkExistingUser = ->
                User.query().$promise.then (users) ->
                    $scope.users = $filter('notIn')(users, $scope.currentIO.io_members, 'user_id')

            calcRestBudget = () ->
                sum = _.reduce($scope.budgets, (res, budget) ->
                    res += Number(budget.budget_loc) || 0
                , 0)
                $scope.budgets && $scope.budgets.rest = $scope.selectedIORow.budget_loc - sum

            $scope.showBudgetRow = (item, e)->
                budgetsRow = angular.element("[data-displayID='#{item.id}']")
                innerDiv = budgetsRow.children()
                angular.element('.display-line-budgets').outerHeight(0)
                if $scope.selectedIORow == item
                    $scope.selectedIORow = null
                else
                    $scope.selectedIORow = null
                    DisplayLineItem.get(item.id).then (budgets) ->
                        $scope.selectedIORow = item
                        $scope.budgets = budgets
                        calcRestBudget()
                        $timeout -> budgetsRow.height innerDiv.outerHeight()
                return

            $scope.addBudget = (budget, index) ->
                if $scope.selectedIORow
                    DisplayLineItem.add_budget(
                        id: $scope.selectedIORow.id
                        display_line_item_budget:
                            budget_loc: 0
                            month: budget.month
                    ).then (resp) ->
                        $scope.budgets[index] = resp

            $scope.createOrUpdateBudget = (budget, value, index) ->
                prevValue = budget.budget_loc
                if !(!isNaN(parseInt(value)) && isFinite(value)) || prevValue == value then return false
                defer = $q.defer()
                if $scope.selectedIORow && budget.budget_loc == undefined
                    DisplayLineItem.add_budget(
                        id: $scope.selectedIORow.id
                        display_line_item_budget:
                            budget_loc: value
                            month: budget.month
                    ).then(
                        (resp) ->
                            if resp.budget_loc == 0
                                $scope.showWarningModal "Zero will be credited for #{resp.month || 'this month'}. To not credit zero click ❌ to delete"
                            $scope.budgets[index] = resp
                            calcRestBudget()
                            defer.resolve()
                        (err) ->
                            console.log 'CREATE ERROR', err
                            budget.budget_loc = prevValue
                            defer.reject()
#                        budget.budget_loc = budget.old_budget
                    )
                else
                    DisplayLineItem.update_budget(
                        id: budget.id
                        display_line_item_budget:
                            budget_loc: value
                    ).then(
                        (resp) ->
#                            budget.budget_loc = parseInt resp.budget_loc
                            if budget.budget_loc == 0
                                $scope.showWarningModal "Zero will be credited for #{budget.month || 'this month'}. To not credit zero click ❌ to delete"
                            calcRestBudget()
                            defer.resolve()
                        (err) ->
                            console.log 'UPDATE ERROR', err
                            budget.budget_loc = prevValue
                            defer.reject()
                    )
                defer

            $scope.deleteBudget = (budget, e) ->
                e.stopPropagation()
                DisplayLineItem.delete_budget(id: budget.id).then (resp) ->
                    budget.budget_loc = undefined
                    calcRestBudget()

            $scope.linkExistingUser = (item) ->
                $scope.userToLink = undefined
                IOMember.create(
                    io_id: $scope.currentIO.id,
                    io_member: {
                        user_id: item.id,
                        share: 0,
                        from_date: $scope.currentIO.start_date,
                        to_date: $scope.currentIO.end_date,
                        values: []
                    }).then (io) ->
                        $scope.currentIO = io

            $scope.setActiveTab = (type) ->
                $scope.activeTab = type

            $scope.isActiveTab = (type) ->
                return $scope.activeTab == type

            $scope.go = (path) ->
                $location.path(path)

            #TODO - set as ngChange in custom-editable directive
            $scope.updateContentFeeAndBudget = (content_fee) ->
                content_fee.budget_loc = 0
                _.each content_fee.content_fee_product_budgets, (cfpb) ->
                    content_fee.budget_loc += Math.round(Number(cfpb.budget_loc))
                $scope.updateContentFee(content_fee)

            $scope.updateContentFee = (data) ->
                $scope.errors = {}
                ContentFee.update(id: data.id, io_id: $scope.currentIO.id, content_fee: data).then(
                    (io) ->
                        $scope.currentIO = io
                    (resp) ->
                        for key, error of resp.data.errors
                            $scope.errors[key] = error && error[0]
                )
            $scope.updateIOMember = (data) ->
                IOMember.update(id: data.id, io_id: $scope.currentIO.id, io_member: data).then (io) ->
                    $scope.currentIO = io

            $scope.deleteMember = (io_member) ->
                if confirm('Are you sure you want to delete "' + io_member.name + '"?')
                    IOMember.delete(id: io_member.id, io_id: $scope.currentIO.id).then (io) ->
                        $scope.currentIO = io

            $scope.updateIO = ->
                $scope.errors = {}
                IO.update(id: $scope.currentIO.id, io: $scope.currentIO).then(
                    (io) ->
                        $scope.currentIO = io
                    (resp) ->
                        for key, error of resp.data.errors
                            $scope.errors[key] = error && error[0]
                )
            $scope.$on 'updated_influencer_content_fees', ->
                $scope.init()
            $scope.init()
    ]
