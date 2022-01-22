module.exports = (url) ->>
  res = await fetch url
  (await res.blob!)
  |> URL.create-object-URL
