@app.controller "ContractAssignContactController", [
    '$scope', '$rootScope', '$modal', '$modalInstance', '$filter', 'Contact', 'Contract', 'contract'
    ($scope,   $rootScope,   $modal,   $modalInstance,   $filter,   Contact,   Contract,   contract) ->

        $scope.formType = "Edit"
        $scope.submitText = "Update"
        $scope.searchText = ""
        Contact.all1({per: 10}).then (contacts) ->
            $scope.contacts = contacts

        searchTimeout = null;
        $scope.searchObj = (name) ->
            if searchTimeout
                clearTimeout(searchTimeout)
                searchTimeout = null
            searchTimeout = setTimeout(
                -> $scope.searchContacts(name)
                350
            )

        $scope.searchContacts = (name) ->

            Contact.all1({q: name, per: 10}).then (contacts) ->
                $scope.contacts = contacts

        $scope.checkContact = (contact) ->
            for contractContact in contract.contract_contacts
                if contractContact.contact.id is contact.id then return true
            return false

        $scope.addContact = (contact) ->
            Contract.update
                id: contract.id
                contract: {contract_contacts_attributes: [contact_id: contact.id]}
            .then (data) -> _.extend contract, data

        $scope.cancel = ->
            $modalInstance.close()

        $scope.$on 'newContact', (e, contact) ->
            Contact.all1({per: 10}).then (contacts) ->
                $scope.contacts = contacts


        $scope.createContact = () ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/contact_form.html'
                size: 'md'
                controller: 'ContactsNewController'
                backdrop: 'static'
                keyboard: false
                resolve:
                    contact: -> {}
]
