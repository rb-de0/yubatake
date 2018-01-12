
// -- Menu

$(function() {
  $('#toggle-menu').click(function(){
    $('#menu').toggleClass('open-menu')
    $('#toggle-menu').toggleClass('open-menu')
  })
})

// -- Admin Table

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
  var separator = (lastCharacter === "," || text === "") ? "" : ","
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

// -- Images

$(document).on('change', '#image-file-data', function (e) {
  var fileName = $(this).val().split('/').pop().split('\\').pop()
  $('#image-file-name').val(fileName)
  $('#admin-selectable-form').submit()
})

// -- Preview

$(document).on('click', '#admin-content-preview-button', function (e) {
  e.preventDefault()
  $('#admin-content-preview').show()

  $.post(makeRequestURL("/api/converted_markdown"), $("form").serialize())
    .done(function(response) {
      $("#post-content-body").html(response["html"])
    })
})

$(document).on('click', '#admin-content-preview-close-button', function (e) {
  e.preventDefault()
  $('#admin-content-preview').hide()
})

function makeRequestURL(path) {
  return location.protocol + "//" + location.host + path
}
