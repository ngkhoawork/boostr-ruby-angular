@app.controller 'ContractsController', [
    '$scope'
    ($scope) ->

        $scope.contracts = [1..10].map (i) ->
            {
                id: i
                name: 'Contract ' + ('0' + i).slice(-2)
                type: 'Type ' + ('0' + i).slice(-2)
                restricted: Boolean _.random(0, 1)
                status: ['Open', 'Close', 'Pending'][_.random(0, 2)]
                advertiser: 'Advertiser ' + ('0' + i).slice(-2)
                agency: 'Agency ' + ('0' + i).slice(-2)
                deal: 'Deal ' + ('0' + i).slice(-2)
            }

]
