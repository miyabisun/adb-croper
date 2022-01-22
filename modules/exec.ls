require! {
  child_process: {exec-sync}
  \./config
}

module.exports = (command) ->
  {adb} = config!
  exec-sync "#adb #command", max-buffer: 1024 * 1024 * 1024,
