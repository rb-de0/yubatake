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
    }
  },
  watch: {
    selectedFile: function (file) {

      if (file !== null && this.editor === null) {
        this.editor = ace.edit("file-editor")
        this.editor.$blockScrolling = Infinity
        this.editor.setTheme("ace/theme/xcode")
      }

      this.fetchFileBody()
    },
    selectedBodyIndex: function (index) {
      this.updateEditor()
    }
  },
  methods: {
    selectFile: function (file) {
      this.selectedFile = file
    },
    selectBodyIndex: function (index) {

      if (this.editor === null) {
        return
      }

      this.bodies[this.selectedBodyIndex].body = this.editor.getValue()
      this.selectedBodyIndex = index
    },
    fetchFileBody: function() {

      this.bodies = null
      this.selectedBodyIndex = 0

      if (this.selectedFile === null) {
        return
      }

      var receiver = this

      axios.get(makeRequestURL("/api/filebody"), {
        params: {
          path: this.selectedFile.path,
          type: this.selectedFile.type
        }
      })
      .then(function (response) {
        receiver.hasError = false
        receiver.bodies = response.data.bodies
        receiver.updateEditor()
      })
      .catch(function (error) {
        receiver.hasError = true
      })
    },
    updateEditor: function () {

      if (this.editor === null) {
        return
      }

      if (this.bodies === null || this.bodies.length === 0) {
        this.editor.setValue("")
        return
      }

      var body = this.bodies[this.selectedBodyIndex]

      if (this.bodies.length === 2 && body.customized === false) {
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
        receiver.fetchFileBody()
      })
      .catch(function (error) {
        receiver.hasError = true
      })

    }
  },
  mounted: function() {

    var viewModel = this
    axios.get(makeRequestURL("/api/files"))
    .then(function (response) {
      viewModel.grouplist = response.data
    })
    .catch(function (error) {
      console.log(error)
    })
  }
})
