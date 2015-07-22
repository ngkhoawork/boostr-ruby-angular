#= require support/spec_helper

describe "ContactsNewController", ->

  beforeEach ->
    modalInstance =
      close: jasmine.createSpy('modalInstance.close')
      dismiss: jasmine.createSpy('modalInstance.dismiss')
      result:
        then: jasmine.createSpy('modalInstance.result.then')

    @controller('ContactsNewController', { $scope: @scope, $modalInstance: modalInstance })

  describe 'submitting the create form', ->

    it 'calls save on a Contact', ->
      @scope.contact = {
        name: 'John Doe',
        position: 'CEO'
        address: {}
      }

      @httpBackend.expectGET('/api/clients').respond([])
      @httpBackend.expectPOST('/api/contacts').respond({ name: 'John Doe'})
      expect(@scope.submitForm()).toBeTruthy()
      @httpBackend.flush()
