@service.service 'CountriesList',
    ['$resource',
        ($resource) ->
            countriesList = [
                'Australia'
                'Brazil'
                'Canada'
                'Denmark'
                'United States of America'
            ]

            return countriesList
    ]