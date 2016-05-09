#= require support/spec_helper

describe "ClientsNewController", ->

  beforeEach ->
    modalInstance =
      close: jasmine.createSpy('modalInstance.close')
      dismiss: jasmine.createSpy('modalInstance.dismiss')
      result:
        then: jasmine.createSpy('modalInstance.result.then')

    @controller('ClientsNewController', { $scope: @scope, $modalInstance: modalInstance, client: {} })

  describe 'submitting the create form', ->

    it 'calls save on a Client', ->
      @scope.client = {
        name: 'Proctor'
        address:
          city: 'Boise'
          state: 'ID'
      }

      @httpBackend.expectGET('/api/fields?subject=Client').respond([])
      @httpBackend.expectPOST('/api/clients').respond({ name: 'Proctor'})
      expect(@scope.submitForm()).toBeTruthy()
      @httpBackend.flush()
