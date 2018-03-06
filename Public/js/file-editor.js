function getModeFromFileName(filename) {
  var extension = filename.split('.').pop()
  switch (extension) {
    case 'js':
    return 'ace/mode/javascript'
    case 'css':
    return "ace/mode/css"
    case 'leaf':
    return 'ace/mode/html'
    default:
    return 'ace/mode/javascript'
  }
}

var viewModel = new Vue({
  el: '#file-editor-app',
  data: {
    themelist: null,
    selectedTheme: null,
    editor: null,
    grouplist: null,
    selectedFile: null,
    bodies: null,
    selectedBodyIndex: 0,
    hasError: false
  },
  computed: {
    isFileSelected: function () {
      return this.selectedFile !== null
    },
    hasUserFile: function() {

      if (this.bodies === null) {
        return false
      }

      var bodyObj = this.bodies.find(function(elem, _, _) {
        return elem.customized === true
      })
      return bodyObj !== undefined
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
  watch: {
    selectedBodyIndex: function (index) {
      this.updateEditor()
    }
  },
  methods: {
    selectFile: function (file) {
      this.fetchFileBody(file)
    },
    selectBodyIndex: function (index) {
      this.bodies[this.selectedBodyIndex].body = this.editor.getValue()
      this.selectedBodyIndex = index
    },
    fetchFileBody: function(file) {

      if (file === null) {
        if (this.selectedFile === null) {
          return
        }
        file = this.selectedFile
      }

      var receiver = this

      axios.get(makeRequestURL("/api/filebody"), {
        params: {
          path: file.path,
          type: file.type,
          theme: file.theme
        }
      })
      .then(function (response) {
        receiver.hasError = false
        receiver.selectedFile = file
        receiver.selectedBodyIndex = 0
        receiver.bodies = response.data.bodies
        receiver.updateEditor()
      })
      .catch(function (error) {
        receiver.hasError = true
      })
    },
    updateEditor: function () {

      if (this.editor === null) {
        this.editor = ace.edit("file-editor")
        this.editor.$blockScrolling = Infinity
        this.editor.setTheme("ace/theme/xcode")
        this.editor.session.setUseWorker(false)
      }

      if (this.bodies === null || this.bodies.length === 0) {
        this.editor.setValue("")
        return
      }

      var body = this.bodies[this.selectedBodyIndex]

      if ((this.bodies.length === 2 && body.customized === false) || this.isThemeSelected) {
        this.editor.setReadOnly(true)
      } else {
        this.editor.setReadOnly(false)
      }

      var mode = getModeFromFileName(this.selectedFile.name)

      this.editor.session.setMode(mode)
      this.editor.setValue(body.body)
      this.editor.clearSelection()
    },
    save: function() {

      if (this.bodies === null || this.bodies.length === 0) {
        return
      }

      if (this.selectedFile === null) {
        return
      }

      this.bodies[this.selectedBodyIndex].body = this.editor.getValue()

      var bodyObj = this.bodies.find(function(elem, _, _) {
        return elem.customized === true
      })
      var body = bodyObj === undefined ? this.bodies[0].body : bodyObj.body
      var type = this.selectedFile.type
      var path = this.selectedFile.path
      var csrfToken = document.getElementById('csrf-token').getAttribute('value')
      var receiver = this

      axios.post(makeRequestURL("/api/filebody"), {
        body: body,
        path: path,
        type: type,
        'csrf-token': csrfToken
      })
      .then(function (response) {
        receiver.hasError = false
        receiver.selectedFile.customized = true
        receiver.fetchFileBody(null)
      })
      .catch(function (error) {
        receiver.hasError = true
      })
    },
    destroy: function() {

      if (this.selectedFile === null) {
        return
      }

      var type = this.selectedFile.type
      var path = this.selectedFile.path
      var csrfToken = document.getElementById('csrf-token').getAttribute('value')
      var receiver = this

      axios.post(makeRequestURL("/api/filebody/delete"), {
        path: path,
        type: type,
        'csrf-token': csrfToken
      })
      .then(function (response) {
        receiver.hasError = false
        receiver.fetchFileBody(null)
        receiver.selectedFile.customized = false
      })
      .catch(function (error) {
        receiver.hasError = true
      })
    },
    resetFiles: function() {

      var csrfToken = document.getElementById('csrf-token').getAttribute('value')
      var receiver = this

      axios.post(makeRequestURL("/api/files/reset"), {
        'csrf-token': csrfToken
      })
      .then(function (response) {
        location.reload()
      })
      .catch(function (error) {
        receiver.hasError = true
      })
    },
    selectTheme: function(theme) {

      this.selectedFile = null

      var receiver = this
      axios.get(makeRequestURL("/api/files"), {
        params: {
          theme: theme
        }
      })
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

      var name = this.selectedTheme
      var csrfToken = document.getElementById('csrf-token').getAttribute('value')

      var receiver = this
      axios.post(makeRequestURL("/api/themes/apply"), {
        name: name,
        'csrf-token': csrfToken
      })
      .then(function (response) {
        location.reload()
      })
      .catch(function (error) {
        receiver.hasError = true
      })
    },
    saveTheme: function() {

      var name = document.getElementById('theme-name').value
      var csrfToken = document.getElementById('csrf-token').getAttribute('value')

      var receiver = this
      axios.post(makeRequestURL("/api/themes"), {
        name: name,
        'csrf-token': csrfToken
      })
      .then(function (response) {
        location.reload()
      })
      .catch(function (error) {
        receiver.hasError = true
      })
    },
    destroyTheme: function() {

      var name = this.selectedTheme
      var csrfToken = document.getElementById('csrf-token').getAttribute('value')

      var receiver = this
      axios.post(makeRequestURL("/api/themes/delete"), {
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
    axios.get(makeRequestURL("/api/themes"))
    .then(function (response) {
      receiver.themelist = response.data.themes
      receiver.selectTheme(null)
    })
  }
})
