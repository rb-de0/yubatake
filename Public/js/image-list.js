var viewModel = new Vue({
  el: '#content',
  methods: {
    upload: function (e) {
      var fileName = e.target.value.split('/').pop().split('\\').pop()
      document.getElementById('image-file-name').value = fileName
      var form = document.getElementById('admin-selectable-form')
      form.setAttribute('action', '/admin/images')
      form.setAttribute('enctype', 'multipart/form-data')
      form.submit()
    }
  }
})
