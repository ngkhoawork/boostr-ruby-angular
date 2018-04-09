@app.controller 'AdvertiserAssignPmpController',
  ['$scope', '$modalInstance', 'object', 'Client', 'PMP', '$modal',
    ( $scope,   $modalInstance,   object,   Client,   PMP,   $modal) ->
      if object.ssp_advertiser != null
        $scope.searchText = object.ssp_advertiser.name
      else
        $scope.searchText = ''
      $scope.object = object
      $scope.clients = []
      $scope.bulkUpdate = false

      init = () ->
        $scope.searchObj()

      $scope.searchObj = () ->
        Client.fuzzy_search(search: $scope.searchText).$promise.then (clients) ->
          $scope.clients = clients

      $scope.assign = (client) ->
        if $scope.bulkUpdate && object.ssp_advertiser != null
          $scope.modalInstance = $modal.open
            templateUrl: 'modals/advertiser_assign_warning.html'
            size: 'md'
            controller: 'AdvertiserAssignWarningController'
            backdrop: 'static'
            keyboard: false
            resolve:
              message: -> "This action will assign advertiser - \"#{client.name}\" to all no-matching records which have same SSP advertiser - \"#{object.ssp_advertiser.name}\". Are you sure about this?"
          .result.then () ->
            PMP.bulkAssignAdvertiser(ssp_advertiser_id: object.ssp_advertiser.id, client_id: client.id).then (result) ->
              $modalInstance.close(result)
        else
          PMP.assignAdvertiser(id: object.id, client_id: client.id).then (result) ->
            $modalInstance.close([result.id])


      $scope.create = () ->
        $scope.modalInstance = $modal.open
          templateUrl: 'modals/client_form.html'
          size: 'md'
          controller: 'AccountsNewController'
          backdrop: 'static'
          keyboard: false
          resolve:
            client: ->
              {}
        .result.then (client) ->
          if client
            $scope.assign(client)

      $scope.cancel = ->
        $modalInstance.dismiss()

      init()
  ]
