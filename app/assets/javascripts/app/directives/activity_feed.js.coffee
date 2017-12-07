app.directive 'activityFeed',
['$modal', '$sce', 'Activity', 'ActivityType'
( $modal,   $sce,   Activity,   ActivityType ) ->
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
#                when 'deal'
#                when 'contact'
#                when 'account'
                when 'publisher'
                    resource = -> Activity.getPublishersActivity(id: $scope.object.id)
                    formOptions =
                        type: $scope.type
                        data: $scope.object

            ActivityType.all().then (activityTypes) -> $scope.types = activityTypes
            loadActivities()

        loadActivities = ->
            resource().then (activities) -> $scope.activities = activities

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

        $scope.deleteActivity = (activity) ->
            if confirm('Are you sure you want to delete the activity?')
                Activity.delete activity

        $scope.$on 'updated_activities', loadActivities
]