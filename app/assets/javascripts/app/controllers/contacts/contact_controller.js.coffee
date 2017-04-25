@app.controller 'ContactController',
    ['$scope', '$modal', '$location', '$routeParams', 'Contact', 'Activity', 'Reminder'
    ( $scope,   $modal,   $location,  $routeParams,   Contact,   Activity,   Reminder ) ->

        $scope.currentContact = null
        loadActivities = (contact_id) ->
            Activity.all(contact_id: contact_id).then (activities) ->
                console.log activities
                $scope.currentActivities = activities
                $scope.activities = activities

        init = ->
            Contact.getContact($routeParams.id).then (contact) ->
                console.log $scope.currentContact = contact
            loadActivities($routeParams.id)
        init()

        $scope.showModal = ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/contact_form.html'
                size: 'md'
                controller: 'ContactsNewController'
                backdrop: 'static'
                keyboard: false
                resolve:
                    contact: ->
                        {}

        $scope.showEditModal = (contact) ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/contact_form.html'
                size: 'md'
                controller: 'ContactsEditController'
                backdrop: 'static'
                keyboard: false
                resolve:
                    contact: ->
                        angular.copy contact

        $scope.showNewActivityModal = ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/activity_new_form.html'
                size: 'md'
                controller: 'ActivityNewController'
                backdrop: 'static'
                keyboard: false
                resolve:
                    activity: ->
                        null
                    options: ->
                        type: 'contact'
                        data: $scope.currentContact
                        isAdvertiser: $scope.currentContact.primary_client_json.client_type_id == $scope.Advertiser

        $scope.showActivityEditModal = (activity) ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/activity_new_form.html'
                size: 'md'
                controller: 'ActivityNewController'
                backdrop: 'static'
                keyboard: false
                resolve:
                    activity: ->
                        activity
                    options: ->
                        type: 'contact'
                        data: $scope.currentContact
                        isAdvertiser: $scope.currentContact.primary_client_json.client_type_id == $scope.Advertiser

        $scope.showEmailsModal = (activity) ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/activity_emails.html'
                size: 'lg'
                controller: 'ActivityEmailsController'
                backdrop: 'static'
                keyboard: false
                resolve:
                    activity: ->
                        activity

        $scope.deleteContact = (contact) ->
            if confirm('Are you sure you want to delete "' + contact.name + '"?')
                Contact.delete({id: contact.id}, (res) ->
                    console.log 'DELETED'
                    $location.path('/contacts')
                , (err) ->
                    console.log (err)
                )

        $scope.deleteActivity = (activity) ->
            if confirm('Are you sure you want to delete the activity?')
                Activity.delete activity, ->
                    $scope.$emit('updated_current_contact')


        $scope.concatAddress = (address) ->
            row = []
            if address
                if address.city then row.push address.city
                if address.state then row.push address.state
                if address.zip then row.push address.zip
                if address.country then row.push address.country
            row.join(', ')

        $scope.$on 'updated_activities', ->
            loadActivities($scope.currentContact.id)

        $scope.$on 'updated_contacts', ->
            init()
    ]
