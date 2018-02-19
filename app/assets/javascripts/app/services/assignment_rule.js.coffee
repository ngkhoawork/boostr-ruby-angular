@service.service 'AssignmentRule', [
    '$resource', '$q',
    ($resource,   $q) ->
        resource = $resource '/api/assignment_rules/:id', { id: '@id' },
            update:
                method: 'PUT'
            addUser:
                method: 'GET'
                url: '/api/assignment_rules/:id/add_user'
            removeUser:
                method: 'GET'
                url: '/api/assignment_rules/:id/remove_user'

        @get = (params) -> resource.query(params).$promise
        @save = (params) -> resource.save(params).$promise
        @update = (params) -> resource.update(params).$promise
        @delete = (params) -> resource.delete(params).$promise
        @addUser = (params) -> resource.addUser(params).$promise
        @removeUser = (params) -> resource.removeUser(params).$promise

        return
]
