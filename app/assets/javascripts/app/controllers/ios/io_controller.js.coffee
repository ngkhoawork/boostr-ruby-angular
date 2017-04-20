@app.controller 'IOController',
    ['$scope', '$modal', '$filter', '$timeout', '$routeParams', '$location', '$q', 'IO', 'IOMember', 'ContentFee', 'User', 'CurrentUser', 'DisplayLineItem'
    ( $scope,   $modal,   $filter,   $timeout,   $routeParams,   $location,   $q,   IO,   IOMember,   ContentFee,   User,   CurrentUser,   DisplayLineItem) ->
            $scope.currentIO = {}
            $scope.activeTab = 'ios'
            $scope.currency_symbol = '$'
            $scope.activeBudgetsRow = null
            $scope.budgets = []
            $scope.isNaN = (val) -> isNaN val

            $scope.init = ->
                CurrentUser.get().$promise.then (user) ->
                    $scope.currentUser = user
                IO.get($routeParams.id).then (io) ->

                    $scope.currentIO = io
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

            $scope.deleteIo = (io) ->
                if confirm('Are you sure you want to delete "' +  io.name + '"?')
                    IO.delete io, ->
                        $location.path('/revenue')

            $scope.showLinkExistingUser = ->
                User.query().$promise.then (users) ->
                    $scope.users = $filter('notIn')(users, $scope.currentIO.io_members, 'user_id')

            $scope.showBudgetRow = (item, e)->
                currentRow = angular.element(e.target).closest('tr')
                rowOffset = currentRow.offset()
                budgetsRow = angular.element('#display-line-budgets')
                wrapper = angular.element('.display-line-table-wrapper')
                offset =
                    top: rowOffset.top + currentRow.height()
                    left: wrapper.offset().left
                budgetsRow.offset(offset)
                if $scope.activeBudgetsRow == item
                    $scope.activeBudgetsRow = null
                    budgetsRow.toggleClass 'hide-budgets-row'
                else
                    $scope.activeBudgetsRow = null
                    budgetsRow.addClass 'hide-budgets-row'
                    DisplayLineItem.get(item.id).then (data) ->
                        $scope.activeBudgetsRow = item
                        $scope.budgets = data
                        budgetsRow.removeClass 'hide-budgets-row'
#                    budgetsRow.addClass 'hide-budgets-row'
#                    $timeout () ->
#                    , 500
                return

            $scope.addBudget = (budget, index) ->
                if $scope.activeBudgetsRow
                    DisplayLineItem.add_budget(
                        id: $scope.activeBudgetsRow.id
                        display_line_item_budget:
                            budget_loc: 0
                            month: budget.month
                    ).then (resp) ->
                        $scope.budgets[index] = resp

            $scope.updateBudget = (budget) ->
                DisplayLineItem.update_budget(
                    id: budget.id
                    display_line_item_budget:
                        budget_loc: budget.budget_loc
                ).then (resp) ->
                    budget.budget_loc = resp.budget_loc

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
            $scope.init()
    ]
