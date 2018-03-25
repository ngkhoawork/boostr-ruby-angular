@app.controller 'ContractsController', [
    '$scope', '$modal', '$timeout', 'Contract'
    ($scope,   $modal,   $timeout,   Contract) ->

        $scope.contracts = []
        $scope.isLoading = false
        $scope.allContractsLoaded = false
        $scope.search = ''
        page = 1
        perPage = 10

#=======================================================================================================================
        generateContract = (name) ->
            testForm =
                deal_id: [31322, 21302, 21074][_.random(0, 2)]
                publisher_id: [1, 2, 3][_.random(0, 2)]
                advertiser_id: [15880, 16302, 753][_.random(0, 2)]
                agency_id: [44912, 6337, 16440][_.random(0, 2)]
                type_id: [1913, 1914, 1915][_.random(0, 2)]
                status_id: [1928, 1929, 1930][_.random(0, 2)]
                name: name
                description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Adipisci alias aliquam architecto assumenda corporis deleniti ea eius esse, eveniet laudantium mollitia necessitatibus nostrum officiis perferendis porro possimus quasi, quibusdam quod quos reiciendis, sequi suscipit unde veritatis voluptas voluptates? Animi, aspernatur commodi cum explicabo ipsam non quisquam? Aperiam at corporis dicta, distinctio dolorem, error esse fuga ipsa laboriosam officiis recusandae repudiandae sit sunt voluptate, voluptates. Accusantium aliquid aperiam aspernatur assumenda aut deserunt doloremque eaque enim eos ex exercitationem explicabo harum illum impedit incidunt iste itaque molestiae nesciunt nihil omnis, quam quis, repellendus soluta totam veniam veritatis vero voluptatum. Architecto atque consectetur dolor dolorum hic, nam officiis pariatur quaerat. Corporis doloribus esse explicabo fuga ipsam recusandae repellat. Adipisci, nostrum quae quo ratione sint ullam vero! Aperiam aut debitis deserunt, eveniet, facere fugit maiores molestiae praesentium reiciendis similique totam vitae. Dolorum modi odio perspiciatis quas quidem sapiente. Aliquid animi debitis ducimus eaque error magnam maxime, molestiae nam obcaecati officia quas tempore ullam vero? Aperiam consequatur, eaque earum fugit impedit ipsa, ipsam itaque nulla officiis quos sint veritatis? Blanditiis dicta quia repellendus sed similique, ut? Atque, beatae blanditiis consectetur debitis error esse, eum fugit ipsam maiores minus non, nulla optio quod sapiente sed temporibus totam. Aliquid debitis doloribus, ea est excepturi facilis modi neque saepe veniam voluptatibus. Adipisci aut, corporis cum dolore eius enim facere facilis itaque labore minima nobis numquam omnis perspiciatis quisquam quos recusandae reiciendis sint ullam vitae voluptate! Aliquam aliquid aperiam assumenda culpa dignissimos eaque esse fugit illo, inventore minus necessitatibus nemo nobis non nulla optio quia voluptatibus! Ab aliquid amet, animi consectetur cum delectus deleniti dolorem earum facere fuga fugiat modi officiis reiciendis repellat reprehenderit sunt vel. A animi architecto assumenda atque autem, culpa eligendi excepturi illo in, molestias nemo nihil perferendis, quaerat quas qui soluta voluptas voluptatem! Id, minus.'
                start_date: moment().add(_.random(1, 5), 'd')
                end_date: moment().add(_.random(6, 10), 'd')
                amount: _.random(100, 1000)
                restricted: Boolean(_.random(0, 1))
                auto_renew: Boolean(_.random(0, 1))
                auto_notifications: Boolean(_.random(0, 1))
                curr_cd: ['EUR', 'GBP', 'CAD'][_.random(0, 2)]

#        [1..30].map (i) -> Contract.create(generateContract('Contract ' + i))
#=======================================================================================================================

        $scope.showContractModal = ->
            $modal.open
                templateUrl: 'contracts/contract_form.html'
                size: 'md'
                controller: 'ContractFormController'

        $scope.showContractModal()

        getContracts = ->
            $scope.isLoading = true
            params =
                per: perPage
                page: page
            Contract.get(params).then (contracts) ->
                $scope.allContractsLoaded = !contracts || contracts.length < perPage
                if page++ > 1
                    $scope.contracts = $scope.contracts.concat(contracts)
                else
                    $scope.contracts = contracts
                $scope.isLoading = false
                $timeout -> $scope.$emit 'lazy:scroll'

        $scope.loadMoreContracts = ->
            if !$scope.allContractsLoaded then getContracts()

        getContracts()
#        Contract.create(testForm)


]
