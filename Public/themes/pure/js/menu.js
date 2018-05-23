var menuViewModel = new Vue({
  el: '#toggle-menu',
  methods: {
    toggleMenu: function (e) {
      document.getElementById('menu').classList.toggle('open-menu')
      document.getElementById('toggle-menu').classList.toggle('open-menu')
    }
  }
})
