var viewModel = new Vue({
  el: '#content',
  methods: {
    selectOne: function (e) {
      var allCheckbox = document.getElementById('all-checkbox')
      var checkBoxes = document.getElementsByClassName('one-checkbox')

      var unCheckedCount = Array.prototype.filter.call(checkBoxes, function (elem) {
        return !elem.checked
      }).length

      if (allCheckbox.checked && unCheckedCount > 0) {
        allCheckbox.checked = false
      }
    },
    selectAll: function (e) {
      var checkBoxes = document.getElementsByClassName('one-checkbox')
      Array.prototype.forEach.call(checkBoxes, function (elem) {
        elem.checked = e.target.checked
      })
    }
  }
})
