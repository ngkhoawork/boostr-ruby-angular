#= require support/spec_helper

describe "ClientsEditController", ->

  beforeEach ->
    modalInstance =
      close: jasmine.createSpy('modalInstance.close')
      dismiss: jasmine.createSpy('modalInstance.dismiss')
      result:
        then: jasmine.createSpy('modalInstance.result.then')

    @controller('ClientsEditController', { $scope: @scope, $modalInstance: modalInstance })

  describe 'submitting the update form', ->

    it 'calls update on a Client', ->
      @scope.client = {
        name: 'Proctor'
        address:
          city: 'Boise'
          state: 'ID'
      }

      @httpBackend.expectPUT('/api/clients').respond({ name: @scope.client.name})
      expect(@scope.submitForm()).toBeTruthy()
      @httpBackend.flush()
