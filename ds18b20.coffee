module.exports = (env) ->

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  ds18b20 = require 'ds18b20'
  Promise.promisifyAll(ds18b20)

  class DS18B20Plugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("DS18B20Sensor", {
        configDef: deviceConfigDef.DS18B20Sensor, 
        createCallback: (config, lastState) => 
          device = new DS18B20Sensor(config, lastState)
          return device
      })

  plugin = new DS18B20Plugin

  class DS18B20Sensor extends env.devices.TemperatureSensor
    _temperature: null

    constructor: (@config, lastState) ->
      @id = @config.id
      @name = @config.name
      @_temperature = lastState?.temperature?.value
      super()

      @requestValue()
      @_updateInterval = setInterval( ( => @requestValue() ), @config.interval)

    requestValue: ->
      ds18b20.temperatureAsync(@config.hardwareId).then( ({value}) =>
        if value isnt 0xffff and value isnt 85
          variableManager = plugin.framework.variableManager
          info = variableManager.parseVariableExpression(@config.calibration.replace(/\$value\b/g, value))
          @_temperature = variableManager.evaluateNumericExpression(info.tokens)

          Promise.resolve(@_temperature).then((result) => @emit 'temperature', result)
        else
          env.logger.debug("Got wrong value from DS18B20 Sensor: #{value}")
      ).catch( (error) =>
        env.logger.error("Error reading DS18B20Sensor with hardwareId #{@config.hardwareId}: #{error.message}")
        env.logger.debug(error.stack)
      )

    getTemperature: -> Promise.resolve(@_temperature)
    
    destroy: ->
      clearInterval(@_updateInterval)
      super()
      
  return plugin
