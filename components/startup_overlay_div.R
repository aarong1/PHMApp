
startup_overlay_div <- function(overlay_out_time_ms = 500, main_in_time_ms=700){
  
tags$div(id = "startup-overlay", 

         tags$script(HTML(paste0("
    setTimeout(function() {
      //document.getElementById('startup-overlay').style.display = 'none';
      // document.getElementById('main-content').style.display = 'block';
        $('#startup-overlay').fadeOut(500);

        //$('#main-content').fadeIn('slow');

    }, ",overlay_out_time_ms,");  // 10 seconds = 10000 ms
    //5000
    setTimeout(function() {
      //document.getElementById('startup-overlay').style.display = 'none';
      // document.getElementById('main-content').style.display = 'block';
       // $('#startup-overlay').fadeOut(200);
       
        $('#main-content').fadeIn('slow');

    }, ",main_in_time_ms,");  // 10 seconds = 10000 ms
    //7000
  "))),


style = "
    position: fixed;
    top: 1%; /*110px*/
    left: 0;
    width: 100%;
    height: 98%;
   
    color: rgb(30,30,30);
    text-align: center;

    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 10040;
  ", div(style = 'overflow:hidden; background-color:rgb(122,236,244);margin:10px;border-radius:15px;height:100%;width:100%;display:flex;justify-content:center;align-items:center;flex-direction:column;',
              
         
         button_block(border = 'white',
                      p(class = 'hello','Population Health Modelling')
                      ),
         #div(style='display:block;position:absolute;justify-content:start;top:50px;left:50px;gap:20px;',
              #img(style= '',src = 'img/pha_logo_0.png', width = '120px;'),
              #p(style='font-size: 11px;','Population Health Model')
         #),
         HTML('<div class="loader-container1">
    <div class="progress-bar1">
        <div class="progress1"></div>
    </div>
</div>' )
              )
         )
}

startup_overlay_div()
