@app.controller 'AdvertisersChartController',
    ['$scope', '$document'
        ($scope, $document) ->
            $scope.datePicker = {
                startDate: null
                endDate: null
            }

            $scope.datePickerApply = () ->
                input = $document.find('#advert-date-picker')
                input.attr('size', input.val().length)
                console.log('SELECTED DATE: ', $scope.datePicker)


    ]