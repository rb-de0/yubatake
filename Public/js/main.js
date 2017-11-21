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
