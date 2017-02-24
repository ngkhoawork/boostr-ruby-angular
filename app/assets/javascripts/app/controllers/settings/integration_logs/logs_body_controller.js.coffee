@app.controller 'LogsBodyController',
    ['$scope', '$modalInstance', '$sce', 'body',
        ($scope, $modalInstance, $sce, body) ->

            parseXml = null
            if typeof window.DOMParser != 'undefined'

                parseXml = (xmlStr) ->
                    (new (window.DOMParser)).parseFromString xmlStr, 'text/xml'

            else if typeof window.ActiveXObject != 'undefined' and new (window.ActiveXObject)('Microsoft.XMLDOM')

                parseXml = (xmlStr) ->
                    xmlDoc = new (window.ActiveXObject)('Microsoft.XMLDOM')
                    xmlDoc.async = 'false'
                    xmlDoc.loadXML xmlStr
                    xmlDoc

            else
                throw new Error('No XML parser found')

            $scope.body = parseXml(body)
            console.log typeof $scope.body
            console.log $scope.body.document

            $scope.cancel = ->
                $modalInstance.close()

            $scope.getHtml = (html) ->
                return $sce.trustAsHtml(html)
    ]
