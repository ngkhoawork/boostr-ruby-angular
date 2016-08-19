@app.factory 'DealLossStagesDataStore',
  ['$rootScope',
    ($rootScope) ->
      DataStore = {}

      DataStore.options = {
        chart: {
          type: 'multiBarHorizontalChart',
          margin: {
            top: 20,
            right: 0,
            bottom: 70,
            left: 150
          },
          height: 200,
          x: (d) =>
            return d.label
          ,
          y: (d) =>
            return d.value
          ,
          groupSpacing: 0.3,
          showLegend: false,
          showControls: false,
          stacked: false,
          showValues: true,
          valueFormat: (d) =>
            return d3.format(',.0f')(d) + "%"
          duration: 500,
          xAxis: {
            showMaxMin: false,
            tickFormat: (d) =>
              return if d.length > 18 then d.substr(0, 18) + '...' else d + '   '
          },
          yAxis: {
            ticks: 4,
            showMaxMin: false,
            tickFormat: (d) =>
              return d3.format(',.0f')(d) + "%"
          }
        }
      }

      DataStore.data = []

      DataStore.getOptions = () ->
        return DataStore.options

      DataStore.getData = () ->
        return DataStore.data

      DataStore.setData = (data) ->
        total_count = 0
        _.each data, (row) ->
          total_count = total_count + row.count
        values = _.map data, (row, index) ->
          value = row.count / total_count * 100
          return {
            key: "Deal Loss",
            label: row.stage,
            series: 0,
            size: value,
            value: value,
            y: value,
            y0: 0,
            y1: value
          }
        DataStore.data = [{key: "Deal Loss", color:"#8ec536", values: values}]
        DataStore.options.chart.height = DataStore.options.chart.margin.top + DataStore.options.chart.margin.bottom + 30 * Math.max(values.length, 1)
      return DataStore
  ]