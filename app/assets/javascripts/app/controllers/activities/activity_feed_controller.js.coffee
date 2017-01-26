@app.controller "ActivityFeedController",
    ['$scope', '$rootScope', '$modal', 'Activity', 'ActivityType', 'Deal', 'Client', 'Contact', 'Reminder', '$http'
        ($scope, $rootScope, $modal, Activity, ActivityType, Deal, Client, Contact, Reminder, $http) ->

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
                            null

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
                            null
    ]