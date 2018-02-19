@app.controller 'LeadsSettingsController', [
    '$scope', '$timeout', 'AssignmentRule', 'Seller'
    ($scope,   $timeout,   AssignmentRule,   Seller) ->
        $scope.form = ''
        $scope.sellers = []
        $scope.rules = []
#        $scope.rules = [1..5].map (i) ->
#            {
#                name: 'Rule ' + i
#                countries: [1.._.random(2, 10)].map (i) -> 'Country ' + i
#                states: [1.._.random(2, 10)].map (i) -> 'State ' + i
#                users: [1.._.random(2, 10)].map (i) -> 'User ' + i
#            }
#        $scope.selectedRule = $scope.rules[0]

        Seller.query({id: 'all'}).$promise.then (data) ->
            $scope.sellers = data

        do getRules = ->
            AssignmentRule.get().then (data) ->
                console.log data
                $scope.rules = data

        $scope.selectRule = (rule) ->
            $scope.selectedRule = rule

        $scope.hideForm = (e) ->
            target = $(e.target)
            $timeout ->
                target.closest('.new-row').removeClass('visible')
            , 100

        $scope.deleteRule = (e, rule) ->
            e.stopPropagation()
            if confirm('Are you sure you want to delete this rule?')
                AssignmentRule.delete(id: rule.id).then ->
                    $scope.rules = _.reject $scope.rules, (item) -> item.id == rule.id

        $scope.deleteField = (field, value) ->
            rule = $scope.selectedRule
            if !rule then return
            params = id: rule.id
            params[field] = _.without rule[field], value
            AssignmentRule.update(params).then (updatedRule) ->
                _.extend rule, updatedRule

        $scope.addUser = (user) ->
            rule = $scope.selectedRule
            if !rule then return
            AssignmentRule.addUser(id: rule.id, user_id: user.id)

        $scope.removeUser = (user) ->
            rule = $scope.selectedRule
            if !rule then return
            AssignmentRule.removeUser(id: rule.id, user_id: user.id)

        $scope.submitForm = (e, type) ->
            rule = $scope.selectedRule
            switch type
                when 'rule'
                    AssignmentRule.save(name: $scope.form).then ->
                        getRules()
                when 'country'
                    if !rule then return
                    console.log rule
                    AssignmentRule.update(
                        id: rule.id
                        countries: [].concat $scope.form, rule.countries
                    ).then (updatedRule) ->
                        _.extend rule, updatedRule
                when 'state'
                    if !rule then return
                    AssignmentRule.update(
                        id: rule.id
                        states: [].concat $scope.form, rule.states
                    ).then (updatedRule) ->
                        _.extend rule, updatedRule

            $scope.hideForm(e)

        $scope.showForm = (e) ->
            $scope.form = ''
            target = $(e.target)
            target.parent().siblings('.new-row').addClass('visible').find('input').focus()
            return

]