@app.controller 'LeadsSettingsController', [
    '$scope', '$timeout', 'AssignmentRule', 'Seller'
    ($scope,   $timeout,   AssignmentRule,   Seller) ->
        $scope.form = ''
        $scope.sellers = []
        $scope.rules = []
        positions = {}
        $scope.selectedRule = null

        Seller.query({id: 'all'}).$promise.then (data) ->
            $scope.sellers = data

        do getRules = ->
            AssignmentRule.get().then (data) ->
                positions = getPositions()
                $scope.rules = data
                $scope.selectedRule = $scope.selectedRule || data[0]

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
            AssignmentRule.addUser(id: rule.id, user_id: user.id).then (updatedRule) ->
                _.extend rule, updatedRule

        $scope.removeUser = (user) ->
            rule = $scope.selectedRule
            if !rule then return
            AssignmentRule.removeUser(id: rule.id, user_id: user.id).then (updatedRule) ->
                _.extend rule, updatedRule

        $scope.submitForm = (e, type) ->
            if !$scope.form.trim() then return $scope.hideForm(e)
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
                        countries: _.union [$scope.form], rule.countries
                    ).then (updatedRule) ->
                        _.extend rule, updatedRule
                when 'state'
                    if !rule then return
                    AssignmentRule.update(
                        id: rule.id
                        states: _.union [$scope.form], rule.states
                    ).then (updatedRule) ->
                        _.extend rule, updatedRule

            $scope.hideForm(e)

        $scope.showForm = (e) ->
            $scope.form = ''
            target = $(e.target)
            target.parent().siblings('.new-row').addClass('visible').find('input').focus()
            return

        getPositions = ->
            _positions = {}
            _.each $scope.rules, (t, i) -> _positions[t.id] = i + 1
            _positions

        $scope.onRuleMoved = (ruleIndex) ->
            $scope.rules.splice(ruleIndex, 1)
            newPositions = getPositions()
            if _.isEqual positions, newPositions then return
            changes = _.omit newPositions, (val, key) -> positions[key] == val
            AssignmentRule.updatePositions(positions: changes)
            positions = newPositions

]