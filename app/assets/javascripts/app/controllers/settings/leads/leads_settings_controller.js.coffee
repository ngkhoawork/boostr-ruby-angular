@app.controller 'LeadsSettingsController', [
    '$scope', '$timeout', 'AssignmentRule', 'User'
    ($scope,   $timeout,   AssignmentRule,   User) ->
        $scope.form = ''
        $scope.users = []
        $scope.rules = []
        $scope.fieldTypes = []
        positions = {}
        selectedType = null
        $scope.selectedRule = null
        $scope.defaultRule = null

        User.query().$promise.then (data) ->
            $scope.users = data

        AssignmentRule.fieldType()
            .then (types) -> $scope.fieldTypes = types.field_types
            .catch (err) -> console.error err

        (getRules = (selectedName) ->
            AssignmentRule.get().then (data) ->
                $scope.rules = _.reject data, (rule) -> rule.default
                $scope.defaultRule = _.findWhere data, {default: true}
                positions = getPositions()
                $scope.selectedRule = _.findWhere($scope.rules, {name: selectedName}) ||
                    $scope.selectedRule ||
                    $scope.rules[0] ||
                    $scope.defaultRule
        )()

        $scope.decorateType = (type) ->
            switch type
                when 'country' then 'Country'
                when 'source_url' then 'Source URL'
                when 'product_name' then 'Product'
                else type

        $scope.selectRule = (rule) ->
            $scope.selectedRule = rule

        $scope.hideForm = (e) ->
            target = $(e.target)
            $scope.form = ''
            target.closest('.new-row').removeClass('visible')
            return

        $scope.deleteRule = (e, rule) ->
            e.stopPropagation()
            if confirm('Are you sure you want to delete this rule?')
                AssignmentRule.delete(id: rule.id).then ->
                    $scope.rules = _.reject $scope.rules, (item) -> item.id == rule.id
                    if rule == $scope.selectedRule
                        $scope.selectedRule = $scope.rules[0] || $scope.defaultRule

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
            form = $scope.form
            switch type
                when 'rule'
                    AssignmentRule.save(name: form, field_type: selectedType).then ->
                        getRules(form)
                when 'criteria_1'
                    if !rule then return
                    AssignmentRule.update(
                        id: rule.id
                        criteria_1: _.union [form], rule.criteria_1
                    ).then (updatedRule) ->
                        _.extend rule, updatedRule
                when 'criteria_2'
                    if !rule then return
                    AssignmentRule.update(
                        id: rule.id
                        criteria_2: _.union [form], rule.criteria_2
                    ).then (updatedRule) ->
                        _.extend rule, updatedRule

            $scope.hideForm(e)

        $scope.updateField = (type, rule) ->
            if !rule then return
            params = {id: rule.id}
            switch type
                when 'rule'
                    params.name = rule.name
                when 'criteria_1'
                    params.criteria_1 = _.reject rule.criteria_1, (item) -> !item.trim()
                when 'criteria_2'
                    params.criteria_2 = _.reject rule.criteria_2, (item) -> !item.trim()
            AssignmentRule.update(params).then (updatedRule) ->
                _.extend rule, updatedRule

        $scope.showForm = (e, form) ->
            $scope.form = form || ''
            target = $(e.target)
            target.closest('.rules-column').find('.new-row').addClass('visible').find('input').focus()
            return

        $scope.selectType = (event, type) ->
            selectedType = type
            $scope.showForm(event)

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
            $scope.selectedRule = _.findWhere $scope.rules, id: $scope.selectedRule.id
            positions = newPositions

]
