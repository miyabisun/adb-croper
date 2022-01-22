require! {
  fs
  path: P
  \fs-readdir-recursive : readdir
  jimp: Jimp
  ramda: R
  \../../modules/exec
  \../../modules/config
}

module.exports = (req, res) ->>
  switch req.method
  | \GET =>
    res.json readdir "#{config!.directory}"
  | \POST =>
    {path, x, y, w, h} = req.body
    fulpath = "#{config!.directory}/#path.png"
    unless fs.exists-sync P.dirname fulpath
      fs.mkdir-sync do
        P.dirname fulpath
        recursive: yes
    (await Jimp.read exec "exec-out screencap -p")
      .crop x, y, w, h
      .write fulpath
    res.json message: "snapshot has been saved to the #fulpath "
  | _ =>
    res.status 404
