module.exports = ->
  adb: process.env.ADB || \adb
  directory: process.env.DIR || \templates
