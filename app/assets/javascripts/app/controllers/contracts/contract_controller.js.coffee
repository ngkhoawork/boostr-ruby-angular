@app.controller 'ContractController', [
    '$scope', '$modal', '$filter', '$routeParams', '$location', 'Contract', 'Contact', 'Field', 'Currency', 'User'
    ($scope,   $modal,   $filter,   $routeParams,   $location,   Contract,   Contact,   Field,   Currency,   User) ->
        $scope.contract = {}
        $scope.currencies = []
        $scope.users = []
        $scope.contactRoles = []
        $scope.memberRoles = []
        $scope.termNames = []
        $scope.termTypes = []
        $scope.isRestricted = false
        $scope.isContractLoaded = false

        Currency.active_currencies().then (data) ->
            $scope.currencies = data

        fields = {}
        Field.defaults(fields, 'Contract').then ->
            $scope.contactRoles = _.sortBy Field.field(fields, 'Contact Role').options, 'name'
            $scope.memberRoles = _.sortBy Field.field(fields, 'Member Role').options, 'name'
            $scope.termNames = _.sortBy Field.field(fields, 'Special Term Name').options, 'name'
            $scope.termTypes = _.sortBy Field.field(fields, 'Special Term Type').options, 'name'

        Contract.get(id: $routeParams.id).then (contract) ->
            $scope.contract = contract
            $scope.isContractLoaded = true
            $scope.showEalertModal(contract)
        , (err) ->
            $scope.isRestricted = err.status is 403
            $scope.isContractLoaded = true

        $scope.updateContract = ->
            Contract.update(id: $scope.contract.id, contract: $scope.contract)

        updateAttrs = (data) ->
            Contract.update
                id: $scope.contract.id
                contract: data
            .then (data) -> _.extend $scope.contract, data

        $scope.addContact = (contract) ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/contact_add_form.html'
                controller: 'ContractAssignContactController'
                size: 'md'
                backdrop: 'static'
                resolve:
                    contract: -> contract

        $scope.showEditModal = (contract) ->
            $modal.open
                templateUrl: 'contracts/contract_form.html'
                controller: 'ContractFormController'
                size: 'md'
                backdrop: 'static'
                resolve:
                    contract: -> angular.copy contract
            .result.then (contract) ->
                _.extend $scope.contract, contract

        $scope.showContactEditModal = (contact) ->
            Contact.getContact(contact.contact_id).then (data) ->
                $modal.open
                    templateUrl: 'modals/contact_form.html'
                    controller: 'ContactsEditController'
                    size: 'md'
                    backdrop: 'static'
                    resolve:
                        contact: -> data
                .result.then (data) ->
                    contact.contact_client_name = data.primary_client_json && data.primary_client_json.name
                    contact.contact_email = data.address && data.address.email
                    contact.contact_name = data.name
                    contact.contact_position = data.position

        $scope.updateTerm = (term, key, value) ->
            updateAttrs
                special_terms_attributes: [{
                    id: term.id
                    "#{key}": value
                }]

        $scope.deleteTerm = (term) ->
            if confirm('Are you sure you want to delete special term?')
                updateAttrs
                    special_terms_attributes: [{id: term.id, _destroy: true}]

        $scope.updateContactRole = (contact, role) ->
            updateAttrs
                contract_contacts_attributes: [{
                    id: contact.id
                    role_id: (role && role.id) || null
                }]

        $scope.unassignContact = (contact) ->
            if confirm('Are you sure you want to unassign "' + contact.contact_name + '"?')
                updateAttrs
                    contract_contacts_attributes: [{id: contact.id, _destroy: true}]

        $scope.deleteContract = (contract) ->
            if confirm('Are you sure you want to delete "' + contract.name + '"?')
                Contract.delete(id: contract.id).then (res) ->
                    $location.path('/contracts')
                , (err) ->
                    console.log (err)

        $scope.showLinkExistingUser = ->
            User.query().$promise.then (users) ->
                $scope.users = $filter('notIn')(users, $scope.contract.contract_members, 'user_id')

        $scope.updateMemberRole = (member, role) ->
            updateAttrs
                contract_members_attributes: [{
                    id: member.id
                    role_id: (role && role.id) || null
                }]

        $scope.unassignMember = (member) ->
            if confirm('Are you sure you want to unassign "' + member.user_name + '"?')
                updateAttrs
                    contract_members_attributes: [{id: member.id, _destroy: true}]

        $scope.linkExistingUser = (item) ->
            updateAttrs
                contract_members_attributes: [user_id: item.id]

        $scope.showSpecialTermModal = (contract) ->
            $modal.open
                templateUrl: 'contracts/contract_special_term_form.html'
                controller: 'ContractSpecialTermController'
                size: 'md'
                backdrop: 'static'
                resolve:
                    contract: -> contract

        $scope.showEalertModal = (contract) ->
            $modal.open
                templateUrl: 'contracts/contract_ealert_form.html'
                controller: 'ContractsEalertController'
                size: 'lg'
                backdrop: 'static'
                resolve:
                    contract: ->
                        angular.copy contract
            .result.then ->
                $scope.ealertReminder = false

]
