//https://stackoverflow.com/questions/4655273/jquery-window-scrolltop-but-no-window-scrollbottom 


    $(document).ready(function() {
      $(window).scroll(function() {
        var scrollPos = $(window).scrollTop();
        var triggerHeight = $(para2).scrollTop();//+$(para2).height(); // Adjust this value as needed
        if (scrollPos > triggerHeight) {
          $('#sliding-pane').addClass('open');
        } else {
          $('#sliding-pane').removeClass('open');
        }
      });
    });