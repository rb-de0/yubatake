$(function() {
  $('#toggle-menu').click(function(){
    $('#menu').toggleClass('open-menu');
    $('#toggle-menu').toggleClass('open-menu');
  });
});

$(document).on('click', '.admin-supplement-tag-item', function (e) {
  var text = $('#admin-tag-text').val();
  var space = text === "" ? "" : " ";
  $('#admin-tag-text').val(text + space + e.target.textContent);
});

$(document).on('click', '.one-checkbox', function (e) {

  var allCheckbox = $('#all-checkbox').get(0)
  var unCheckedCount = $('.one-checkbox').filter(function(index, elem) {
    return !elem.checked
  }).length

  if (allCheckbox.checked && unCheckedCount > 0) {
    allCheckbox.checked = false
  }
});

$(document).on('click', '#all-checkbox', function (e) {
  $('.one-checkbox').each(function(index, elem) {
    elem.checked = e.target.checked
  })
});
