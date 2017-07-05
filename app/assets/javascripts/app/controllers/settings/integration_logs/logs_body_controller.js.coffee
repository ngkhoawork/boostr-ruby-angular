@app.controller 'LogsBodyController',
    ['$scope', '$document', '$modalInstance', '$sce', 'body', 'doctype'
        ($scope, $document, $modalInstance, $sce, body, doctype) ->

            $scope.cancel = ->
                $modalInstance.close()

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

            xmlToJson = (xml) ->
                obj = {}
                if xml.nodeType == 1
                    if xml.attributes.length > 0
                        obj['@attributes'] = {}
                        j = 0
                        while j < xml.attributes.length
                            attribute = xml.attributes.item(j)
                            obj['@attributes'][attribute.nodeName] = attribute.nodeValue
                            j++
                else if xml.nodeType == 3
                    obj = xml.nodeValue
                if xml.hasChildNodes()
                    i = 0
                    while i < xml.childNodes.length
                        item = xml.childNodes.item(i)
                        nodeName = item.nodeName
                        if typeof obj[nodeName] == 'undefined'
                            obj[nodeName] = xmlToJson(item)
                        else
                            if typeof obj[nodeName].push == 'undefined'
                                old = obj[nodeName]
                                obj[nodeName] = []
                                obj[nodeName].push old
                            obj[nodeName].push xmlToJson(item)
                        i++
                obj

            if doctype.indexOf('json') != -1
                $scope.xmlObject = body
            else
                $scope.xmlObject = xmlToJson(parseXml(body))
    ]
