#= require support/spec_helper

describe "ContactsEditController", ->

  beforeEach ->
    modalInstance =
      close: jasmine.createSpy('modalInstance.close')
      dismiss: jasmine.createSpy('modalInstance.dismiss')
      result:
        then: jasmine.createSpy('modalInstance.result.then')

    @controller('ContactsEditController', { $scope: @scope, $modalInstance: modalInstance })

  describe 'submitting the update form', ->

    it 'calls update on a Contact', ->
      @scope.contact = {
        name: 'Proctor'
        position: 'CEO'
        address:
          city: 'Boise'
          state: 'ID'
      }

      @httpBackend.expectGET('/api/clients').respond([])
      @httpBackend.expectPUT('/api/contacts').respond({ name: 'Proctor', position: 'CEO'})
      expect(@scope.submitForm()).toBeTruthy()
      @httpBackend.flush()
