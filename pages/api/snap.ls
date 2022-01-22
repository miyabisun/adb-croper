require! {
  \../../modules/exec
}

module.exports = (req, res) ->
  res
    ..set-header \Content-Type, \image/png
    ..end exec "exec-out screencap -p"
