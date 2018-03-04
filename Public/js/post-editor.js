var viewModel = new Vue({
  el: '#content',
  data: {
    page: 1,
    images: [],
    hasNext: false,
    hasPrevious: false,
    latestScrollOffset: 0,
    tagString: '',
    tags: []
  },
  watch: {
    tagString: function (tagString) {
      this.tags = tagString.split(',')
    },
    tags: function (tags) {
      this.tagString = tags.join(',')
    }
  },
  methods: {
    showPreview: function (e) {

      e.preventDefault()

      var preview = document.getElementById('admin-content-preview')
      preview.style.display = 'block'
      preview.style.height = window.innerHeight + 'px'

      this.latestScrollOffset = window.scrollY
      document.querySelector('.pure-form').style.display = 'none'

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
      document.querySelector('.pure-form').style.display = 'block'
      window.scrollTo(0, this.latestScrollOffset)
    },
    showPickerView: function (e) {

      e.preventDefault()
      document.getElementById('admin-image-picker').style.display = 'flex'
      document.body.style.overflow = 'hidden'

      this.request(null)
    },
    closePickerView: function (e) {

      if (e.target !== document.getElementById('admin-image-picker')) {
        return
      }

      e.preventDefault()
      document.getElementById('admin-image-picker').style.display = 'none'
      document.body.style.overflow = 'scroll'
    },
    requestNext: function (e) {
      this.request(this.page + 1)
    },
    requestPrevious: function (e) {
      this.request(this.page - 1)
    },
    request: function(requestPage) {

      var receiver = this
      if (requestPage === null) {
        var page = this.page
      } else {
        var page = requestPage
      }

      axios.get(makeRequestURL("/api/images"), {
        params: {
          page: page
        }
      })
      .then(function (response) {
        receiver.hasNext = response.data.page.position.next !== undefined
        receiver.hasPrevious = response.data.page.position.previous !== undefined
        receiver.images = response.data.data
        receiver.page = page
      })
    },
    selectImage: function (image) {

      document.getElementById('admin-image-picker').style.display = 'none'
      document.body.style.overflow = 'scroll'

      var textarea = document.querySelector('textarea')

      var currentText = textarea.value
      var currentTextLength = currentText.length
      var cursorPosition = textarea.selectionStart

      var imageElement = document.createElement('img')
      imageElement.setAttribute('src', image.path)
      imageElement.setAttribute('alt', image.alt_description)

      var beforeCursor = currentText.substr(0, cursorPosition)
      var afterCursor = currentText.substr(cursorPosition, currentTextLength)

      textarea.value = beforeCursor + imageElement.outerHTML + afterCursor

    },
    selectedTag: function (e) {

      var text = this.tagString
      var tags = text.split(",")

      var sameTags = tags.filter(function(tag) {
        return tag === e.target.textContent
      })

      if(sameTags.length > 0) {
        return
      }

      tags.push(e.target.textContent)
      var emptyRemoved = tags.filter(function(tag) {
        return tag !== ""
      })

      this.tags = emptyRemoved
    },
    isSelectedTag: function (tag) {
      return this.tags.includes(tag)
    }
  },
  created: function() {
    this.tags = document.getElementById('admin-tag-text').value.split(',')
  }
})
