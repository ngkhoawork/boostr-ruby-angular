@app.controller "ContractFormController", [
    '$scope', '$modalInstance', '$location', 'Contract', 'Deal', 'Client', 'Publisher', 'Currency', 'Field', 'HoldingCompany', 'contract'
    ($scope,   $modalInstance,   $location,   Contract,   Deal,   Client,   Publisher,   Currency,   Field,   HoldingCompany,   contract) ->

        $scope.formType = if contract then 'Edit' else 'New'
        $scope.submitText = if contract then 'Save' else 'Create'
        $scope.currencies = []
        $scope.types = []
        $scope.statuses = []
        $scope.holdingCompanies = []
        $scope.form =
            restricted: false
            auto_renew: false
            auto_notifications: false

        if contract
            console.log contract
            $scope.form = contract
            $scope.form.curr_cd = contract.currency.curr_cd if contract.currency
            $scope.form.type_id = contract.type.id if contract.type
            $scope.form.status_id = contract.status.id if contract.status
            $scope.form.holding_company_id = contract.holding_company.id if contract.holding_company

        $scope.cancel = ->
            $modalInstance.dismiss()

        $scope.submitForm = ->
            $scope.errors = {}
            fields = ['name', 'type_id']

            fields.forEach (key) ->
                field = $scope.form[key]
                switch key
                    when 'name'
                        if !field then return $scope.errors[key] = 'Name is required'
                    when 'type_id'
                        if !field then return $scope.errors[key] = 'Type is required'

            return if !_.isEmpty $scope.errors

            form = _.clone $scope.form
            form.deal_id = form.deal.id if form.deal
            form.advertiser_id = form.advertiser.id if form.advertiser
            form.agency_id = form.agency.id if form.agency
            form.publisher_id = form.publisher.id if form.publisher
            form = _.omit form, 'deal', 'advertiser', 'agency', 'publisher'
            if contract
                Contract.update(form).then (contract) ->
                    $modalInstance.close(contract)
            else
                Contract.create(form).then (contract) ->
                    $modalInstance.close(contract)
                    $location.path("/contracts/#{contract.id}")

        Currency.active_currencies().then (data) ->
            $scope.currencies = data

        fields = {}
        Field.defaults(fields, 'Contract').then ->
            $scope.types = Field.field(fields, 'Type').options
            $scope.statuses = Field.field(fields, 'Status').options

        $scope.searchDeals = (str) ->
            Deal.all({name: str}).then (deals) ->
                deals

        $scope.searchClients = (str, type) ->
            q =
                search: str
                filter: 'all'
            if type is 'advertiser' then q.client_type_id = $scope.Advertiser
            if type is 'agency' then q.client_type_id = $scope.Agency
            Client.query(q).$promise.then (clients) ->
                clients

        $scope.searchPublishers = (str) ->
            Publisher.publishersList(q: str).then (publishers) -> publishers

        HoldingCompany.all().then (holdingCompanies) ->
            $scope.holdingCompanies = holdingCompanies
]
