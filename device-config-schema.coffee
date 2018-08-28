module.exports = {
  title: "pimatic-ping device config schemas"
  DS18B20Sensor: {
    title: "DS18B20Sensor config options"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      hardwareId:
        description: "The ID of the sensor"
        type: "string"
      interval:
        description: "Interval in ms to read the sensor"
        type: "integer"
        default: 10000
      calibration:
        description: "Expression for calibrating the sensor value; $value is a placeholder for the value itself"
        type: "string"
        default: "$value"
  }
}