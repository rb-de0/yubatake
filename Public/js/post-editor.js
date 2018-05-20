var viewModel = new Vue({
  el: '#content',
  delimiters: ['[[', ']]'],
  data: {
    page: 1,
    images: [],
    hasNext: false,
    hasPrevious: false,
    totalPage: 0,
    tagString: '',
    tags: []
  },
  computed: {
    hasImages: function() {
      return this.images.length !== 0
    }
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
    showPreview: function (e, id) {
      e.preventDefault()
      var path = '/admin/posts/' + id + '/preview'
      window.open(makeRequestURL(path))
    },
    showPickerView: function (e) {

      e.preventDefault()
      document.getElementById('admin-image-picker').style.display = 'flex'
      document.getElementById('content').style.overflow = 'hidden'
      document.getElementById('menu').style.overflow = 'hidden'

      this.request(null)
    },
    closePickerView: function (e) {

      if (e.target !== document.getElementById('admin-image-picker')) {
        return
      }

      e.preventDefault()
      document.getElementById('admin-image-picker').style.display = 'none'
      document.getElementById('content').style.overflow = 'scroll'
      document.getElementById('menu').style.overflow = 'scroll'
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

      axios.get(makeRequestURL('/api/images'), {
        params: {
          page: page
        }
      })
      .then(function (response) {
        receiver.hasNext = response.data.page.position.next !== undefined
        receiver.hasPrevious = response.data.page.position.previous !== undefined
        receiver.images = response.data.data
        receiver.totalPage = response.data.page.position.max
        receiver.page = response.data.page.position.current
      })
    },
    upload: function (e) {

      var fileName = e.target.value.split('/').pop().split('\\').pop()

      if (e.target.files.length < 1) {
        return
      }

      var csrfToken = document.getElementById('csrf-token').getAttribute('value')
      var receiver = this

      var data = new FormData()
      data.append('image_file_name', fileName)
      data.append('image_file_data', e.target.files[0])
      data.append('csrf-token', csrfToken)

      axios.post(makeRequestURL('/api/images'), data)
      .then(function (response) {
        receiver.request(1)
      })
    },
    selectImage: function (image) {

      document.getElementById('admin-image-picker').style.display = 'none'
      document.getElementById('content').style.overflow = 'scroll'
      document.getElementById('menu').style.overflow = 'scroll'

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
      var tags = text.split(',')

      var sameTags = tags.filter(function(tag) {
        return tag === e.target.textContent
      })

      if(sameTags.length > 0) {
        return
      }

      tags.push(e.target.textContent)
      var emptyRemoved = tags.filter(function(tag) {
        return tag !== ''
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
