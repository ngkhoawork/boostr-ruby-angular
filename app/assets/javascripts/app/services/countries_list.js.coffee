@service.service 'CountriesList',
['$resource', '$q',
    ($resource, $q) ->

        resource = $resource '/api/countries', {}

]