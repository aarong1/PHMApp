console.log('change_tab function called funciton called');
  function change_tab(tab){
  var triggerEl = document.querySelector('a[data-value="'+tab+'"]');
    
    console.log(triggerEl);
    var tab = new bootstrap.Tab(triggerEl);
    
    tab.show();
    return true
  }
  
  window.change_tab = change_tab


