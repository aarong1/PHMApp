$(document).ready(function(){
  
  const update_nav = function(data) {
  var triggerEl = document.querySelector('a[data-value="'+data+'"]');
  
  console.log(triggerEl);
  var tab = new bootstrap.Tab(triggerEl)
  
  tab.show();
  
});

window.update_nav = update_nav

  Shiny.addCustomMessageHandler('update_nav' , update_nav(data)
);
