function getModeFromFileName(filename) {
  var extension = filename.split('.').pop()
  switch (extension) {
    case 'js':
    return 'ace/mode/javascript'
    case 'css':
    return 'ace/mode/css'
    case 'leaf':
    return 'ace/mode/html'
    default:
    return 'ace/mode/javascript'
  }
}

var viewModel = new Vue({
  el: '#file-editor-app',
  delimiters: ['[[', ']]'],
  data: {
    themelist: null,
    grouplist: null,
    selectedTheme: null,
    selectedFile: null,
    editor: null,
    hasError: false
  },
  computed: {
    isFileSelected: function () {
      return this.selectedFile !== null
    },
    isThemeSelected: function() {
      return this.selectedTheme !== null
    },
    isNotEmptyGroupList: function() {
      return (this.grouplist !== null && this.grouplist.length !== 0)
    },
    isNotEmtpyThemeList: function() {
      return (this.themelist !== null && this.themelist.length !== 0)
    }
  },
  methods: {
    selectFile: function (file) {
      this.fetchFileBody(file)
    },
    fetchFileBody: function(file) {

      if (file === null) {
        if (this.selectedFile === null) {
          return
        }
        file = this.selectedFile
      }

      var receiver = this

      axios.get(makeRequestURL('/api/files'), {
        params: {
          path: file.path
        }
      })
      .then(function (response) {
        receiver.hasError = false
        receiver.selectedFile = file
        receiver.selectedFile.body = response.data.body
        receiver.updateEditor()
      })
      .catch(function (error) {
        receiver.hasError = true
      })
    },
    updateEditor: function () {

      if (this.editor === null) {
        this.editor = ace.edit('file-editor')
        this.editor.$blockScrolling = Infinity
        this.editor.setTheme('ace/theme/xcode')
        this.editor.setReadOnly(false)
        this.editor.session.setUseWorker(false)
      }

      if (this.selectedFile.body === null) {
        this.editor.setValue('')
        return
      }

      var body = this.selectedFile.body
      var mode = getModeFromFileName(this.selectedFile.name)

      this.editor.session.setMode(mode)
      this.editor.setValue(body)
      this.editor.clearSelection()
    },
    save: function() {

      if (this.selectedFile.body === null) {
        return
      }

      var body = this.editor.getValue()
      var path = this.selectedFile.path
      var csrfToken = document.getElementById('csrf-token').getAttribute('value')
      var receiver = this

      axios.post(makeRequestURL('/api/files'), {
        body: body,
        path: path,
        'csrf-token': csrfToken
      })
      .then(function (response) {
        receiver.hasError = false
        receiver.fetchFileBody(null)
      })
      .catch(function (error) {
        receiver.hasError = true
      })
    },
    selectTheme: function(theme) {

      this.selectedFile = null

      var receiver = this
      var url = '/api/themes/' + theme.name + '/files'

      axios.get(makeRequestURL(url))
      .then(function (response) {
        receiver.hasError = false
        receiver.selectedTheme = theme
        receiver.grouplist = response.data
      })
    },
    applyTheme: function() {

      if (this.selectedTheme === null) {
        return
      }

      var name = this.selectedTheme.name
      var csrfToken = document.getElementById('csrf-token').getAttribute('value')

      var receiver = this
      axios.post(makeRequestURL('/api/themes'), {
        name: name,
        'csrf-token': csrfToken
      })
      .then(function (response) {
        location.reload()
      })
      .catch(function (error) {
        receiver.hasError = true
      })
    }
  },
  mounted: function() {

    var receiver = this
    axios.get(makeRequestURL('/api/themes'))
    .then(function (response) {
      receiver.themelist = response.data
    })
  }
})