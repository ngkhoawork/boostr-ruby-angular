@app.controller "ContactDetailAssignController",
    ['$scope', '$rootScope', '$modal', '$modalInstance', 'Contact', 'contact'
    ( $scope,   $rootScope,   $modal,   $modalInstance,   Contact,   contact ) ->

            $scope.clients = []
            $scope.searchText = ""

            ($scope.searchObj = (name = '') ->
                Contact.get_advertisers(
                    id: contact.id
                    name: name
                    per: 10
                ).$promise.then (data) ->
                    $scope.clients = data
            )()

            $scope.assignClient = (client) ->
               Contact.assign_account(
                   id: contact.id
                   client_id: client.id
               ).$promise.then (resp) ->
                   $rootScope.$broadcast 'contact_client_assigned'
                   $scope.clients = _.without $scope.clients, _.findWhere($scope.clients, id: client.id)

            $scope.cancel = ->
                $modalInstance.close()

            $scope.openAccountModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/client_form.html'
                    size: 'md'
                    controller: 'AccountsNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        client: -> {}
                        options: -> {}
    ]
