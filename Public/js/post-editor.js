var viewModel = new Vue({
  el: '#content',
  delimiters: ['[[', ']]'],
  data: {
    page: 1,
    hasNext: false,
    hasPrevious: false,
    totalPage: 0,
    tagString: '',
    tags: [],
    imageGroups: [],
    isLoading: false,
    taskCount: 0,
    completedTaskCount: 0
  },
  computed: {
    hasImages: function() {
      return this.imageGroups.length !== 0
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
      document.getElementById('image-picker').style.display = 'flex'
      document.getElementById('content').style.overflow = 'hidden'
      document.getElementById('menu').style.overflow = 'hidden'

      this.request(null)
    },
    closePickerView: function (e) {

      if (e.target !== document.getElementById('image-picker')) {
        return
      }

      e.preventDefault()
      document.getElementById('image-picker').style.display = 'none'
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
        receiver.hasNext = response.data.metadata.page < response.data.metadata.totalPage
        receiver.hasPrevious = response.data.metadata.page > 1
        receiver.imageGroups = response.data.items
        receiver.totalPage = response.data.metadata.totalPage
        receiver.page = response.data.metadata.page
      })
    },
    upload: function (e) {

      var receiver = this
      var csrfToken = document.getElementById('csrf-token').getAttribute('value')

      if (e.target.files.length < 1) {
        return
      }

      this.taskCount = e.target.files.length
      this.completedTaskCount = 0
      this.isLoading = true

      var tasks = Array.from(e.target.files).map(function(file) {
        var fileName = file.name
        var data = new FormData()
        data.append('imageFileName', fileName)
        data.append('imageFileData', file)
        data.append('csrfToken', csrfToken)
        return axios.post(makeRequestURL('/api/images'), data)
          .then(function(response) {
            receiver.completedTaskCount += 1
          })
      })

      Promise.all(tasks).then(function () {
        receiver.isLoading = false
        receiver.request(1)
      }).catch(function(error) {
        receiver.isLoading = false
      })
    },
    selectImage: function (image) {

      document.getElementById('image-picker').style.display = 'none'
      document.getElementById('content').style.overflow = 'scroll'
      document.getElementById('menu').style.overflow = 'scroll'

      var textarea = document.querySelector('textarea')

      var currentText = textarea.value
      var currentTextLength = currentText.length
      var cursorPosition = textarea.selectionStart

      var imageElement = document.createElement('img')
      imageElement.setAttribute('src', image.path)
      imageElement.setAttribute('alt', image.altDescritpion)

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
    this.tags = document.getElementById('edit-form-tag-text').value.split(',')
  }
})
