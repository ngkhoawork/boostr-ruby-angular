@app.controller 'LeadsReassignController', [
    '$scope', '$modalInstance', '$sce', 'Leads', 'lead'
    ($scope,   $modalInstance,   $sce,   Leads,   lead) ->
        console.log lead
        $scope.users = []

        Leads.users().then (users) ->
            $scope.users = users

        $scope.cancel = ->
            $modalInstance.close()


]
