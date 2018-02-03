var viewModel = new Vue({
  el: '#content',
  methods: {
    showPreview: function (e) {

      e.preventDefault()
      document.getElementById('admin-content-preview').style.display = 'block'

      var content = document.getElementById('admin-post-contents').value
      var csrfToken = document.getElementById('csrf-token').getAttribute('value')

      axios.post(makeRequestURL("/api/converted_markdown"), {
        content: content,
        'csrf-token': csrfToken
      })
      .then(function (response) {
        document.getElementById('post-content-body').innerHTML = response.data["html"]
        twttr.widgets.load()
        hljs.initHighlighting.called = false
        hljs.initHighlighting()
      })
    },
    closePreview: function (e) {

      e.preventDefault()
      document.getElementById('admin-content-preview').style.display = 'none'
    },
    selectedTag: function (e) {

      var text = document.getElementById('admin-tag-text').value
      var tags = text.split(",")

      var sameTags = tags.filter(function(tag) {
        return tag === e.target.textContent
      })

      if(sameTags.length > 0) {
        return
      }

      var lastCharacter = text.substr(text.length - 1)
      var separator = (lastCharacter === "," || text === "") ? "" : ","
      document.getElementById('admin-tag-text').value = text + separator + e.target.textContent
    }
  }
})
