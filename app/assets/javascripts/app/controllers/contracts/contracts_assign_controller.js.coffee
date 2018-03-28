@app.controller "ContractAssignContactController", [
    '$scope', '$rootScope', '$modal', '$modalInstance', '$filter', 'Contact', 'Contract', 'contract'
    ($scope,   $rootScope,   $modal,   $modalInstance,   $filter,   Contact,   Contract,  contract) ->
        console.log contract
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
            _.findWhere(contract.contract_contacts, id: contact.id)

        $scope.addContact = (contact) ->
            Contract.assignContact(id: contract.id, contact_id: contact.id)

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
                    contact: ->
                        {}
]
