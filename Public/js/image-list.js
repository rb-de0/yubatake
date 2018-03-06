var viewModel = new Vue({
  el: '#content',
  data: {
    images: [],
    hasNext: false,
    hasPrevious: false,
    page: 0
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

      axios.post(makeRequestURL("/api/images"), data)
      .then(function (response) {
        location.reload()
      })
    }
  },
  mounted: function() {

    var receiver = this

    var page = getQueryParams()["page"]
    if (page === undefined) {
      page = 1
    } else {
      page = parseInt(page)
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
      receiver.page = response.data.page.position.current
    })
  }
})
