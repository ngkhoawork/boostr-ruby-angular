@app.controller 'DealsController',
    ['$scope',
        ($scope) ->
            $scope.selectedDeal = null
            $scope.columnNames = [
                'PROSPECTING'
                'DISCUSS REQUIREMENTS'
                'PROPOSAL'
                'NEGOTIATION'
            ]
            $scope.columns = (() ->
                c = []
                for i in $scope.columnNames
                    c.push []
                c
            )()

            for i in [1...10]
                $scope.columns[Math.round(Math.random() * 3)].push(
                    {name: 'Item ' + i, company: 'Company ' + i, seller: 'John Seller', revenue: i}
                )



            document.addEventListener('keydown', (e) ->
                if e.code is 'Space' then console.dir($scope.columns)
            )
    ]