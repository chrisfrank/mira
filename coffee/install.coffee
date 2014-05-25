app.install = ->
  canvas = document.getElementById 'app'
  appIcon = document.createElement('img')
  appIcon.src = document.querySelector('link[rel=apple-touch-icon]').href
  installIcon = document.createElement('img')
  installIcon.src = 'assets/share-white.png'
  header = document.createElement('h2')
  header.innerText = 'Tap'
  paragraph = document.createElement 'p'
  paragraph.innerText = "in Safari's toolbar to add #{document.title} to your home screen"
  frag = document.createDocumentFragment()
  frag.appendChild appIcon
  frag.appendChild header
  frag.appendChild installIcon
  frag.appendChild paragraph
  canvas.innerHTML = ''
  canvas.classList.add 'install'
  canvas.appendChild frag

