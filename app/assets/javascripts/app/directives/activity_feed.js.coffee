app.directive 'activityFeed',
['$modal', '$sce', '$routeParams', 'Activity', 'ActivityType', 'CustomFieldNames'
( $modal,   $sce, $routeParams,  Activity,   ActivityType, CustomFieldNames ) ->
    restrict: 'E'
    replace: true
    scope:
        object: '='
        type: '@'
    templateUrl: 'directives/activity_feed.html'
    link: ($scope, element) ->

            activityTypes = ['deal', 'account', 'contact', 'publisher'] #AVAILABLE TYPES
            if !_.contains activityTypes, $scope.type
                element.remove()
                console.error new Error("Wrong type \"#{$scope.type}\" passed in Activity feed directive")

            $scope.activities = []
            $scope.types = []
            $scope.isLoading = false
            $scope.$watch 'object', (object) ->
                if object && object.id then init()

            formOptions = {}
            resource = -> {}

            init = ->
                switch $scope.type
                    when 'deal'
                        resource = -> Activity.all(deal_id: $routeParams.id)
                    when 'contact'
                        resource = -> Activity.all(contact_id: $routeParams.id)
                    when 'account'
                        resource = -> Activity.getAccountActivity(id: $scope.object.id)
                    when 'publisher'
                        resource = -> Activity.getPublishersActivity(id: $scope.object.id)

                formOptions =
                    type: $scope.type
                    data: $scope.object
                ActivityType.all().then (activityTypes) -> $scope.types = activityTypes
                loadActivityCustomFields()

        loadActivityCustomFields = ->
          CustomFieldNames.all({subject_type: 'activity', show_on_modal: true}).then (customFieldNames) ->
            $scope.customFieldNames = customFieldNames
            loadActivities()

            loadActivities = ->
                resource().then (activities) ->
                    $scope.activities = activities

            $scope.getHtml = (html) ->
                $sce.trustAsHtml(html)

            $scope.showNewActivityModal = ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/activity_new_form.html'
                    size: 'md'
                    controller: 'ActivityNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        activity: -> null
                        options: -> formOptions

            $scope.showActivityEditModal = (activity) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/activity_new_form.html'
                    size: 'md'
                    controller: 'ActivityNewController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        activity: -> activity
                        options: -> formOptions

            $scope.showEmailsModal = (activity) ->
                $scope.modalInstance = $modal.open
                    templateUrl: 'modals/activity_emails.html'
                    size: 'lg'
                    controller: 'ActivityEmailsController'
                    backdrop: 'static'
                    keyboard: false
                    resolve:
                        activity: -> activity

            $scope.isTextHasTags = (str) -> /<[a-z][\s\S]*>/i.test(str)

            $scope.deleteActivity = (activity) ->
                if confirm('Are you sure you want to delete the activity?')
                    Activity.delete activity

            $scope.$on 'updated_activities', loadActivities

            $scope.$on 'openContactModal', ->
                $modal.open
                    templateUrl: 'modals/contact_form.html'
                    controller: 'ContactsNewController'
                    size: 'md'
                    resolve:
                        contact: -> {}
                        options: -> {}

            $scope.$on 'dashboard.openAccountModal', ->
                $modal.open
                    templateUrl: 'modals/client_form.html'
                    controller: 'AccountsNewController'
                    size: 'md'
                    backdrop: 'static'
                    resolve:
                        client: -> {}
                        options: -> {}

]