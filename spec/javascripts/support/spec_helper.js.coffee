#= require application
#= require angular-mocks

beforeEach(module('Boostr'))

beforeEach inject (_$httpBackend_, _$compile_, $rootScope, $controller, $location, $injector, $timeout) ->
  @scope = $rootScope.$new()
  @httpBackend = _$httpBackend_
  @compile = _$compile_
  @location = $location
  @controller = $controller
  @injector = $injector
  @timeout = $timeout
  @model = (name) =>
    @injector.get(name)
  @eventLoop =
    flush: =>
      @scope.$digest()

afterEach ->
  @httpBackend.verifyNoOutstandingRequest();
  @httpBackend.resetExpectations()
  @httpBackend.verifyNoOutstandingExpectation()