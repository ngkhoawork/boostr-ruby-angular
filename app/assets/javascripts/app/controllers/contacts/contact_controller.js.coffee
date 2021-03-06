@app.controller 'ContactController',
    ['$scope', '$modal', '$location', '$routeParams', '$http', '$sce', 'Contact', 'Reminder', 'ContactCfName', 'ClientContact'
    ( $scope,   $modal,   $location,   $routeParams,   $http,   $sce,   Contact,   Reminder,   ContactCfName,   ClientContact ) ->

        $scope.currentContact = null
        $scope.types = []
        $scope.contactCfNames = []
        $scope.relatedAccounts = []
        $scope.activitiesOrder = '-happened_at'
        $scope._scope = -> this

        (getContact = ->
            Contact.getContact($routeParams.id).then (contact) ->
                $scope.currentContact = contact
        )()

        (getRelated = ->
            Contact.get_related(id: $routeParams.id).$promise.then (data) ->
                $scope.relatedAccounts = data
        )()

        ContactCfName.all().then (contactCfNames) ->
            $scope.contactCfNames = contactCfNames

        $scope.concatAddress = (address) ->
            row = []
            if address
                if address.city then row.push address.city
                if address.state then row.push address.state
                if address.zip then row.push address.zip
                if address.country then row.push address.country
            row.join(', ')

        $scope.unassignClient = (client) ->
            if confirm('Are you sure you want to unassign "' + client.name + '"?')
                Contact.unassign_account(
                    id: $scope.currentContact.id
                    client_id: client.id
                ).$promise.then getRelated

        $scope.updateContact = ->
            contact = $scope.currentContact
            if !contact then return console.error 'no current contact'
            if contact.job_level && contact.job_level.id
                jobLevelValue = _.findWhere contact.values, field_id: contact.job_level.field_id
                if jobLevelValue
                    jobLevelValue.option_id = contact.job_level.id
                else
                    contact.values = [
                        {
                            option_id: contact.job_level.id
                            field_id: contact.job_level.field_id
                        }
                    ].concat(contact.values || [])
            Contact._update(id: contact.id, contact: contact)

        $scope.showModal = ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/contact_form.html'
                size: 'md'
                controller: 'ContactsNewController'
                backdrop: 'static'
                keyboard: false
                resolve:
                    contact: -> {}
                    options: -> {}

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

        $scope.showAssignModal = (contact) ->
            $scope.modalInstance = $modal.open
                templateUrl: 'modals/contact_assign_form.html'
                size: 'md'
                controller: 'ContactDetailAssignController'
                backdrop: 'static'
                keyboard: false
                resolve:
                    contact: -> contact

        $scope.deleteContact = (contact) ->
            if confirm('Are you sure you want to delete "' + contact.name + '"?')
                Contact.delete({id: contact.id}, (res) ->
                    $location.path('/contacts')
                , (err) ->
                    console.log (err)
                )

        $scope.updateClientContactStatus = (clientContact, bool) ->
            ClientContact.update_status(
                id: clientContact.id
                client_id: clientContact.client_id
                is_active: bool
            ).$promise.then (resp) ->
                clientContact.is_active = resp.is_active


        (initReminder = ->
            $scope.reminder = {
                name: '',
                comment: '',
                completed: false,
                remind_on: '',
                remindable_id: $routeParams.id,
                remindable_type: 'Contact' # "Activity", "Client", "Contact", "Deal"
                _date: new Date(),
                _time: new Date()
            }

            $scope.reminderOptions = {
                showReminder: false
                editMode: false,
                errors: {},
                buttonDisabled: false,
                showMeridian: true
            }



#            Reminder.get($scope.reminder.remindable_id, $scope.reminder.remindable_type).then (reminder) ->
            $http.get('/api/remindable/'+ $scope.reminder.remindable_id + '/' + $scope.reminder.remindable_type)
                .then (respond) ->
                    if (respond && respond.data && respond.data.length)
                        _.each respond.data, (reminder) ->
                            if (reminder && reminder.id && reminder && reminder.id && !reminder.completed && !reminder.deleted_at)
                                $scope.reminder.id = reminder.id
                                $scope.reminder.name = reminder.name
                                $scope.reminder.comment = reminder.comment
                                $scope.reminder.completed = reminder.completed
                                $scope.reminder._date = new Date(reminder.remind_on)
                                $scope.reminder._time = new Date(reminder.remind_on)
                                $scope.reminderOptions.editMode = true
        )()

        $scope.submitReminderForm = () ->
            $scope.reminderOptions.errors = {}
            $scope.reminderOptions.buttonDisabled = true
            if !($scope.reminder && $scope.reminder.name)
                $scope.reminderOptions.buttonDisabled = false
                $scope.reminderOptions.errors['Name'] = "can't be blank."
            if !($scope.reminder && $scope.reminder._date)
                $scope.reminderOptions.buttonDisabled = false
                $scope.reminderOptions.errors['Date'] = "can't be blank."
            if !($scope.reminder && $scope.reminder._time)
                $scope.reminderOptions.buttonDisabled = false
                $scope.reminderOptions.errors['Time'] = "can't be blank."
            if !$scope.reminderOptions.buttonDisabled
                return

            reminder_date = new Date($scope.reminder._date)
            if $scope.reminder._time != undefined
                reminder_time = new Date($scope.reminder._time)
                reminder_date.setHours(reminder_time.getHours(), reminder_time.getMinutes(), 0, 0)
            $scope.reminder.remind_on = reminder_date
            if ($scope.reminderOptions.editMode)
                Reminder.update(id: $scope.reminder.id, reminder: $scope.reminder).then (reminder) ->
                    $scope.reminderOptions.buttonDisabled = false
                    $scope.showReminder = false;
                    $scope.reminder = reminder
                    $scope.reminder._date = new Date($scope.reminder.remind_on)
                    $scope.reminder._time = new Date($scope.reminder.remind_on)
                    $scope.reminderOptions.editMode = true
                , (err) ->
                    $scope.reminderOptions.buttonDisabled = false
            else
                Reminder.create(reminder: $scope.reminder).then (reminder) ->
                    $scope.reminderOptions.buttonDisabled = false
                    $scope.showReminder = false;
                    $scope.reminder = reminder
                    $scope.reminder._date = new Date($scope.reminder.remind_on)
                    $scope.reminder._time = new Date($scope.reminder.remind_on)
                    $scope.reminderOptions.editMode = true
                , (err) ->
                    $scope.reminderOptions.buttonDisabled = false

        $scope.isUrlValid = (url) ->
            regexp = /^(https?:\/\/)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?/
            regexp.test url

        $scope.getUrlHostname = (url) ->
            a = document.createElement 'a'
            a.href = $scope.fixUrl url
            a.hostname

        $scope.fixUrl = (url) ->
            if url && url.search('//') == -1 then return '//' + url else url     

        $scope.$on 'updated_contacts', getContact
        $scope.$on 'contact_client_assigned', getRelated
        $scope.$on 'updated_reminders', initReminder
    ]
