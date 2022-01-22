require! {
  react: create-element: e
  \../styles/main.sass
  \react-toastify/dist/ReactToastify.css
}

export default: ({Component, pageProps}) ->
  Component pageProps
