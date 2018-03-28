app.directive 'relatedContracts', [
    '$modal', '$routeParams', 'Contract'
    ($modal,   $routeParams,   Contract) ->
        restrict: 'E'
        replace: true
        scope:
            type: '@'
        templateUrl: 'directives/related_contracts.html'
        link: ($scope, element) ->
            $scope.contracts = []
            params = {}

            switch $scope.type
                when 'deal' then params.deal_id = $routeParams.id
                when 'account' then params.client_id = $routeParams.id
                when 'publisher' then params.publisher_id = $routeParams.id

            Contract.all(params).then (contracts) ->
                $scope.contracts = contracts
]