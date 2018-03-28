@service.service 'Contract', [
    '$rootScope', '$resource', '$q',
    ($rootScope,   $resource,   $q) ->

        resource = $resource '/api/contracts/:id', {id: '@id'},
            update:
                method: 'PUT'
            filterValues:
                url: '/api/contracts/settings'
            assignContact:
                url: '/api/contracts/contract_contacts_attributes'
                method: 'PUT'


        this.all = (params) -> resource.query(params).$promise
        this.get = (params) -> resource.get(params).$promise
        this.create = (params) -> resource.save(params).$promise
        this.update = (params) -> resource.update(params).$promise
        this.delete = (params) -> resource.delete(params).$promise
        this.filterValues = (params) -> resource.filterValues(params).$promise
        this.assignContact = (params) -> resource.assignContact(params).$promise
        return
]
