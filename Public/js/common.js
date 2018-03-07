function makeRequestURL(path) {
  return location.protocol + '//' + location.host + path
}

function getQueryParams() {
  var search = location.search
  var params = []

  splited  = search.slice(1).split('&')
  splited.forEach(function (param) {
     keyValue = param.split('=')
     params[keyValue[0]] = keyValue[1]
  })

  return params
}
