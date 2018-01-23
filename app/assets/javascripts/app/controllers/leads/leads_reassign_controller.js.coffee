@app.controller 'LeadsReassignController', [
    '$scope', '$modalInstance', '$sce', 'Leads', 'lead'
    ($scope,   $modalInstance,   $sce,   Leads,   lead) ->

        $scope.form =
            selectedUser: null
        $scope.users = []

        Leads.users().then (users) ->
            $scope.users = users

        $scope.cancel = ->
            $modalInstance.close()

        $scope.assign = (user) ->
            return if _.isNull user
            params = {id: lead.id}
            params.user_id = user.id if user
            Leads.reassign(params).then ->
                $scope.cancel()

]
