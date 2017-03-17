angular.module('boostrServerErrors', [])
    .config(['$httpProvider', ($httpProvider) ->
        errorsContainer = angular.element('<div class="boostr-server-errors-container"></div>')
        angular.element('body').prepend(errorsContainer)
        showError = (errors) ->

            errorEl = angular.element('<div class="boostr-server-error"></div>')
            if typeof errors == 'object' && !Array.isArray(errors)
                for key, error of errors
                    title = angular.element('<div class="boostr-server-error-title">' + key + ' error:</div>')
                    list = angular.element('<div class="boostr-server-errors-list"></div>')
                    list.append(error.map((text) -> '<div class="boostr-server-error-message"> - ' + text + '</div>'))
                    errorEl.append([title, list])
            else if typeof errors == 'string'
                errorEl.append('<span class="boostr-server-error-message">' + errors + '</span>')
            else
                console.error errors

            errorsContainer.prepend(errorEl)
            setTimeout () -> errorEl.css('top', '0')
            setTimeout () ->
                errorEl.fadeOut 500, () ->
                    errorEl.remove()
            , 10000

        $httpProvider.interceptors.push ($q) ->
            {
                'responseError': (res) ->
                    switch res.status
                        when 404
                            console.log res.statusText
                        when 400
                            showError(res.statusText)
                        when 500
                            showError(res.statusText)
                        when 422
                            console.log res.data.errors
                            if res.data && res.data.errors then showError(res.data.errors)
                    $q.reject res

            }
    ])