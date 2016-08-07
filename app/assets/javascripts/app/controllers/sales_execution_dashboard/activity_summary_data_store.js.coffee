@app.factory 'ActivitySummaryDataStore',
  ['$rootScope',
    ($rootScope) ->
      DataStore = {}

      DataStore.options = {
        chart: {
          type: 'multiBarChart',
          height: 300,
          margin: {
            top: 20,
            right: 20,
            bottom: 120,
            left: 40
          },
          showLegend: false,
          showControls: false,
          x: (d) =>
            return d.label
          ,
          y: (d) =>
            return d.value
          ,
          average: (d) ->
            return d.mean/100
          ,
          duration: 500,
          stacked: true,
          showValues: true,
          groupSpacing: 0.7,
          reduceXTicks: false,
          xAxis: {
            axisLabel: "",
            showMaxMin: false,
            rotateLabels: -45,
            tickFormat: (d) =>
              value = d.replace("Lost - ", "")
              return if value.length > 15 then value.substr(0, 15) + "..." else value
          },
          yAxis: {
            axisLabel: "#",
            showMaxMin: true,
            ticks: 4,
            tickFormat: (d) =>
              return d3.format(',.0f')(d)
          }
        }
      }

      DataStore.data = []

      DataStore.getOptions = () ->
        return DataStore.options

      DataStore.getData = () ->
        return DataStore.data

      DataStore.setData = (data) ->
        values = _.map data, (row, index) ->
          return {
          key: "Activity Count",
          label: row.activity,
          series: 0,
          size: row.count,
          value: row.count,
          y: row.count,
          y0: 0,
          y1: row.count
          }
        DataStore.data = [{key: "Activity Count", color:"#70ad47", values: values}]
      return DataStore
  ]