$(function() {
  $('#toggle-menu').click(function(){
    $('#menu').toggleClass('open-menu')
    $('#toggle-menu').toggleClass('open-menu')
  })
})

$(document).on('click', '.admin-supplement-tag-item', function (e) {
  var text = $('#admin-tag-text').val()
  var tags = text.split(",")

  var sameTags = tags.filter(function(tag) {
    return tag === e.target.textContent
  })

  if(sameTags.length > 0) {
    return
  }

  var lastCharacter = text.substr(text.length - 1)
  var separator = lastCharacter === "," ? "" : ","
  $('#admin-tag-text').val(text + separator + e.target.textContent)
})

$(document).on('click', '.one-checkbox', function (e) {

  var allCheckbox = $('#all-checkbox').get(0)
  var unCheckedCount = $('.one-checkbox').filter(function(index, elem) {
    return !elem.checked
  }).length

  if (allCheckbox.checked && unCheckedCount > 0) {
    allCheckbox.checked = false
  }
})

$(document).on('click', '#all-checkbox', function (e) {
  $('.one-checkbox').each(function(index, elem) {
    elem.checked = e.target.checked
  })
})
