require! {
  react: {
    use-state, use-effect
    create-element: e
  }
  \react-toastify : {ToastContainer, toast}
  ramda: R
  \../modules/useSWR
  \../modules/img-fetcher
}
mutate = useSWR.mutate

module.exports = ->
  [img, set-img] = use-state null
  [filter, set-filter] = use-state null
  [i-position, set-i-position] = use-state null
  [position-start, set-position-start] = use-state null
  [position-end, set-position-end] = use-state null
  [now-drag, set-now-drag] = use-state no

  {data: snap} = useSWR \/api/snap, img-fetcher
  {data: templates} = useSWR "/api/templates"

  img-refresh = -> mutate \/api/snap
  position = if position-end
    x: R.min position-start.x, position-end.x
    y: R.min position-start.y, position-end.y
    width: Math.abs position-end.x - position-start.x
    height: Math.abs position-end.y - position-start.y
  [template, set-template] = use-state ""
  [template-input, set-template-input] = use-state null

  e \main, id: \top,
    e \div, class-name: \canvas,
      e \button,
        class-name: \refresh
        on-click: img-refresh
        \refresh
      e \div,
        class-name: \filter
        ref: set-filter
        on-mouse-move: ({client-x: cx, client-y: cy}) ->
          x = cx - filter.offset-left
          y = cy - filter.offset-top
          scale = img.natural-width / img.offset-width
          set-i-position do
            x: Math.round x * scale
            y: Math.round y * scale
            xl: Math.round x * scale / img.natural-width * 100
            yl: Math.round y * scale / img.natural-height * 100
        on-mouse-down: ({client-x: x, client-y: y}) ->
          set-position-start do
            x: x - filter.offset-left
            y: y - filter.offset-top
          set-position-end null
          set-now-drag yes
        on-drag-over: ({client-x: cx, client-y: cy}) ->
          return unless now-drag
          x = cx - filter.offset-left
          y = cy - filter.offset-top
          scale = img.natural-width / img.offset-width
          set-i-position do
            x: Math.round x * scale
            y: Math.round y * scale
            xl: Math.round x * scale / img.natural-width * 100
            yl: Math.round y * scale / img.natural-height * 100
          set-position-end {x, y}
        on-drag-end: (event) ->
          set-now-drag false
        e \img,
          src: snap
          ref: set-img
        if position
          e \div,
            class-name: \selected
            style:
              top: "#{position.y}px"
              left: "#{position.x}px"
              width: "#{position.width}px"
              height: "#{position.height}px"
      e \div,
        class-name: \position
        if i-position
          e \div, null,
            e \div, null, "x: #{i-position.x} (#{i-position.xl}%)"
            e \div, null, "y: #{i-position.y} (#{i-position.yl}%)"
    e \article, null,
      e \h1, null, "Snap Shot"
      if templates
        e \div, class-name: \games,
          e \h2, null, \Template
          e \div,
            class-name: "field template",
            e \input,
              ref: set-template-input
              type: \text
              value: template
              on-change: (.target.value) >> set-template
            e \input,
              type: \submit
              value: \create
              on-click: ->>
                scale = img.natural-width / img.offset-width
                mutate \/api/snap
                res = await fetch \/api/templates,
                  method: \POST
                  headers: \Content-Type : \application/json
                  body: JSON.stringify do
                    path: template
                    x: Math.round position.x * scale
                    y: Math.round position.y * scale
                    w: Math.round position.width * scale
                    h: Math.round position.height * scale
                toast "成功"
          if templates
            e \div, null,
              e \h2, null, "Directory Tree"
              e \ul, class-name: \directries,
                templates
                |> R.filter (.match /\//)
                |> R.map R.replace /[^\/]+$/, ""
                |> R.uniq
                |> R.map (dir) ->
                  e \li,
                    key: dir
                    on-click: ->
                      set-template dir
                      template-input.focus!
                    dir
    ToastContainer
