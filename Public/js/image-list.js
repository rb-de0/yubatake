var viewModel = new Vue({
  el: '#content',
  delimiters: ['[[', ']]'],
  data: {
    groups: [],
    hasNext: false,
    hasPrevious: false,
    page: 0,
    isLoading: false,
    taskCount: 0,
    completedTaskCount: 0
  },
  computed: {
    previousPage: function() {
      return this.page - 1
    },
    nextPage: function() {
      return this.page + 1
    }
  },
  methods: {
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
        data.append('image_file_name', fileName)
        data.append('image_file_data', file)
        data.append('csrf-token', csrfToken)
        return axios.post(makeRequestURL('/api/images'), data)
          .then(function(response) {
            receiver.completedTaskCount += 1
          })
      })

      Promise.all(tasks).then(function () {
        receiver.isLoading = false
        location.reload()
      }).catch(function(error) {
        receiver.isLoading = false
      })
    }
  },
  mounted: function() {

    var receiver = this

    var page = getQueryParams()['page']
    if (page === undefined) {
      page = 1
    } else {
      page = parseInt(page)
    }

    axios.get(makeRequestURL('/api/images'), {
      params: {
        page: page
      }
    })
    .then(function (response) {
      receiver.hasNext = response.data.page.position.next !== undefined
      receiver.hasPrevious = response.data.page.position.previous !== undefined
      receiver.groups = response.data.data
      receiver.page = response.data.page.position.current
    })
  }
})
