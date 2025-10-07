
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.

# Find out more about building applications with Shiny here:

#    http://shiny.rstudio.com/

## libraries-----
library(shiny)
library(htmltools)
library(tidyverse)
library(shinyjqui)
library(bslib)
library(igraph)
library(visNetwork)
library(yaml)
#fileName='statins.yaml'
#x <- readChar(fileName, file.info(fileName)$size)
library(echarts4r)
library(cowplot)
library(bsicons)
library(sparkline)
library(GWalkR)
library(glue)
library(leaflet)
library(DT)
library(apexcharter)
library(fontawesome)
library(jsonlite)
library(data.table)

#library(mapgl)
#states <- sf::read_sf("https://rstudio.github.io/leaflet/json/us-states.geojson")

###################### IMPORT but only need looading once per project
# source('./prevalence_plots.R')
# source('./population_plots.R')
# source('./shiny_prep_graph.R')
# source('./epi_prevalence_plots.R')

# addResourcePath('www',normalizePath('./components/sandbox'))

# source('./components/sandbox/scenarios_list_component.R')

#source all custom components
paste0('./components/', dir(pattern='.R','./components') ) %>%
  map(.,.f=function(x){source(file=x)})

source('./www/html_script_tags_w_injection/d3_scenario_input_widget.R')

# source some of the necessary data needed for the advanced custom components

jdata <- data.frame(
  x = 2020:2030,
  y = 1
)

json_data <- jsonlite::toJSON(jdata)

#source
#prevalence <- readRDS('./trends_data.rds')

# Options select
population_list <-  c('NI','Belfast','Urban')

intervention_list <- c(#'statins - for low density lipoprotein (bad) cholesterol',
  #'targeted intervention under NICE guidelines',
  #'diuretics - for hypertension',
  #metformin (screening) - for type two diabetes',
  #'NHS diabetes program for diabetes',
  #'smoking cesssation',
  'AF screening')

outcomes <- c( 'health burden',
               'economic burden')

# Define UI for application that draws a histogram
ui <- div(
  
  # banner ----
  tags$head(
    
    # tags$script(HTML("
    #   document.addEventListener('DOMContentLoaded', function () {
    #     setTimeout(function () {
    #       var banner = document.getElementById('top-banner');
    #       if (banner) {
    #         var alert = bootstrap.Alert.getOrCreateInstance(banner);
    #         alert.close();
    #       }
    #     }, 5000);
    #   });
    # ")),
    
  #   tags$script(HTML("
  #    document.addEventListener('DOMContentLoaded', function () {
  # setTimeout(function () {
  #   var banner = document.getElementById('close_banner_btn');
  #   if (banner) banner.click(); // Optional: check if the button exists
  # }, 20000); // 3000 milliseconds = 3 seconds
  #     });
  #   ")),
    
    tags$style(HTML("
    
      .top-banner {
        /* position: absolute;
        top: 0;
        left: 0;
        right: 0;
        z-index:1000;
        */
        
        /* font-size: 1rem;  */
        background-color: white; /* #0e4980; */
        margin: 10px 10px 0px 10px;
        border-radius: 10px !important;
        /* border-bottom-left-radius: 7px !important; */ 
        
        display: flex !important;
        align-content: flex-start;
        flex-wrap: nowrap;
        justify-content: space-between;
        align-items: baseline;
      }
      
      .top-banner a {
        font-size: 1rem;
      }

 ")
    )
  ),
  
  div(
    id = "top-banner",
    class = "alert alert-dismissible fade show top-banner bg-gradient-cyan-blue border-0",# bg-gradient-blue-teal text-center 
    role = "alert",
    div(tags$a(
      href = "#",
      onclick = 'window.change_tab("baseline_results");',
      target = "_blank", class = "fs-5 text-decoration-none text-white", #text-white 
      "New Updated baseline for SPPG produced for 9 morbidities"
    ),
    
    tags$a(
      href = "https://example.com", target = "_blank", class = "fs-6 text-decoration-underline text-white", #text-white 
      "Learn More"
    )
  ),
    
    tags$div(
      id = 'close_banner_btn', type = "button", class = "", `data-bs-dismiss` = "alert", `aria-label` = "Close",
      icon('x',class='fs-5 text-white')
    )
  ),
  
  
  
  page_fluid(
    theme = bs_theme(
      primary = 'rgb(45,45,45)',
      success  = 'rgb(144, 238, 144)',
      version = 5),
    
    HTML('<script>
            document.addEventListener("DOMContentLoaded", function() {

    document.getElementById("svgObject").addEventListener("load", function() {
        var svgDoc = this.contentDocument; // Access the embedded SVG
        var clickableElement = svgDoc.querySelector("g.hover-group"); // Find the clickable <g>

        if (clickableElement) {
            clickableElement.addEventListener("click", function() {
                window.open("https://www.bhf.org.uk", "_blank"); // Open in a new tab
            });
        }
    });
    };
</script>'),
    tags$head(
      tags$script(HTML("
      document.addEventListener('DOMContentLoaded', function() {
 
        // Shiny.addCustomMessageHandler('updateData', function(data) {
        //  createScatterPlot(data);
        // });



        function createScatterPlot(data) {
          var margin = {top: 20, right: 20, bottom: 30, left: 40},
              width = 500
              height = 250
    
          var xScale = d3.scaleLinear()
            .domain([2019, 2025])
            .range([0, width]);

          var yScale = d3.scaleLinear()
            .domain([-1, 6])
            .range([height, 0]);

          var svg = d3.select('#scatterPlot').append('svg')
            .attr('preserveAspectRatio', 'xMinYMin meet')
            .attr('viewBox', '0 0 1050 300')
            //.append('g');

            //.attr('width', 500 )
            //.attr('height', 500)
            
             // Create a tooltip div that is hidden by default:
          var tooltip = d3.select('body').append('div')
            .attr('class', 'tooltip')
            .style('background-color', '#FAF9F6')
            .style('font-size','15px')
            .style('opacity', 0);
            
          svg.selectAll('rect')
            .data(data)
            .enter()
            .append('rect')
            .attr('x', function(d) { return xScale(d.x); })
            .attr('y', function(d) { return yScale(d.y); })
            .attr('rx', 10)

            //.attr('r', 10)
            .attr('width', 30)
            .attr('height', 70)
            .call(d3.drag()
              .on('start', dragstarted)
              .on('drag', dragged)
              .on('end', dragended))
              .on('mouseover', function(event, d) {
              tooltip.transition()
                .duration(200)
                .style('opacity', .9);
              tooltip.html(' Year : ' + d.x.toFixed(0) + '<br/>y: ' + d.y.toFixed(2))
                .style('left', (event.pageX + 15) + 'px')
                .style('top', (event.pageY - 28) + 'px');
            })
            .on('mouseout', function(d) {
              tooltip.transition()
                .duration(500)
                .style('opacity', 0);
            });

          function dragstarted(event, d) {
            d3.select(this).attr('fill', 'red');
            const ogx = event.x ;
            const ogy = event.y ;
          }

          function dragged(event, d) {
          
          var svg = d3.select('svg');
          svg.on('mousemove', (d) => {
            var finalx = d.clientX
            var finaly = d.clientY; });

          console.log(d)
          console.log(event)
          
           var selectedCircles = svg.selectAll('circle')
                .filter(function(d) { return d.x > event.subject.x; });

            //selectedCircles.style('fill', 'orange');
          
          }

          function dragended(event, d) {
          
           d3.select(this)//.attr('fill', 'rgb(45,45,45)')
           .attr('x', d.x = xScale(event.subject.x))
           .attr('y', d.y = Math.round((yScale(event.subject.y)+event.y)/10)*10);
           
           console.log(Math.round((yScale(event.subject.y)+event.y)/10)*10);
          
          //var selectedCircles = svg.selectAll('circle')
            //.filter(function(d) { return d.x > event.subject.x; })
          
          //selectedCircles
            //  .style('fill', 'rgb(45,45,45)')
            
            d.x = xScale.invert(d.x);
            d.y = yScale.invert(d.y);
              
            Shiny.setInputValue('drag_data', d);

          }
        }

        // Initial plot
        var data = JSON.parse('" , json_data , "');
        createScatterPlot(data);
      });
    "))
    ),
    
    div(style='position:fixed;bottom:15px;left:25px;border-radius:50%;z-index:10000;font-size:x-large',class=' ',#bg-light p-3
        a(href='#',icon('arrow-up',style='font-size:x-large'),p('Top'))
    ),
    tags$head(
      
      tags$style(HTML("
      .tab-pane.fade {
        transition: opacity 0.25s linear;
      }
    ")),
      
      HTML('<script src="https://cdn.jsdelivr.net/npm/countup.js@1.8.1/dist/countUp.min.js"></script>'),
      
      tags$script(src = "https://d3js.org/d3.v6.min.js"),
      
      includeScript(path = './www/js/animate_changing_words.js'),
      
      HTML("<script defer = true>
        $(document).ready(function() {
    console.log('Page is fully loaded!');

     Shiny.addCustomMessageHandler('scroll', function(data) {
          console.log('scroll');
          const element = document.getElementById('outputs');
          element.scrollIntoView();
          
          var demo = new CountUp('myTargetElement',0,10212 ,0,10);
          if (!demo.error) {
            //demo.update(800);
          demo.start()  
            } else {
          console.error(demo.error);
          };
          
          window.demo = demo;
          changeWord();
        
        });
        
      });
</script>"
           
      ),
      #HTML("<link rel='stylesheet' href='css/flipster.css' />"),
      
      HTML("<link rel='stylesheet' href='css/baseline.css' />"),
      HTML("<link rel='stylesheet' href='css/link_button_hover_visited.css' />"),
      HTML('<link  rel="stylesheet" href = css/text-divider.css />'),
      HTML('<link rel="icon" type="image/x-icon" href="img/favicon_io/favicon.ico">'),
      #includeCSS(path = './www/css/styles.css'),
      HTML("<link rel='stylesheet' href='css/styles.css' />"),
      
      
      #includeCSS(path = './www/progress_bar.css'),
      includeScript(path = './www/js/sliding_panel_on_scroll.js'),
      includeScript(path = './www/js/carousel.js'),
      includeScript(path = './www/js/update_nav.js'),
      includeScript(path = './www/js/event_handlers.js'),
      #includeScript(path = './www/js/manipulate_clipboard.js'),
      # tags$head(tags$script(src="js/event_handlers.js")),
      
      # for if getting an error message in javascript about .forEach not being a function....see the below......
      #https://codedamn.com/news/javascript/how-to-fix-typeerror-foreach-is-not-a-function-in-javascript
      includeScript(path = './www/js/canvas_draggable_report_builder.js')),
    
    #includeScript(path = './www/js/overlay.js'),
    
    # overlay ----
    startup_overlay_div(800,900),
    
    tags$head(
      tags$style(HTML("
      /* Panel styles */
      #slidePanel {
        position: fixed;
        top: 0;
        right: -300px; /* Start offscreen */
        width: 300px;
        height: 100%;
        background-color: #f8f9fa;
        box-shadow: -2px 0 5px rgba(0,0,0,0.3);
        transition: right 0.3s ease;
        padding: 20px;
        z-index: 1000;
      }

      /* Show the panel */
      #slidePanel.open {
        right: 0;
      }

      #toggleBtn {
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 1100;
      }
    ")
      )
    ),
    
    
    actionButton(icon('right-from-bracket'), 
                 label = NULL, 
                 class = "btn-outline-info", 
                 style = 'transform: rotate(180deg);position:fixed;bottom:15px;right:15px;',
                 inputId =   "toggle_open"),
    
    
    tags$div(#class='display:relative;',
      id = "slidePanel",
      h4("Collect Graphics from your Report"),
      
      p(class ='text-muted fs-5', icon('indent',class='fs-6 ml-4',
                                       `data-bs-container` = "body",
                                       `data-bs-toggle` = "popover",
                                       `data-bs-placement` = "left",
                                       `data-bs-content` = "You can collate the visuals you see on the dashboard on this page  ",
                                       `data-bs-original-title` = "How do you use this?"),
        "Plot Repository"
      ),
      
      div(id = 'editor', class='shadow-sm',style = 'height:80%;',
          br(),
          p(class ='text-muted','Hello !'),
          p(class ='text-muted','Drag and drop plots here (Edit me!) '),
          tags$br()
      ),
      
      actionButton(
        icon('right-from-bracket'), 
        label = NULL, 
        class = "btn-info", 
        style = 'position:absolute;bottom:20px;right:15px;',
        inputId =   "toggle_close"),
      
      # actionButton("closePanel", "Close")
      div( class="btn-group", role="group", `aria-label`="Basic example",style = 'position:absolute;bottom:20px;left:15px;',
           actionButton(
             icon('floppy-disk'), 
             label = 'Save' , 
             class = "btn-info", 
             style = '',
             inputId =   "save"),
           
           actionButton(
             icon('copy'), 
             label = 'Copy' , 
             class = "btn-info", 
             style = '',
             inputId =   "copy_paste")
      ), 
      
      #     HTML('<div class="btn-group" role="group" aria-label="Basic example">
      #   <button type="button" class="btn btn-secondary">Copy</button>
      #   <button type="button" class="btn btn-secondary">Save</button>
      # </div>')
      
    ),
    tags$script(HTML("
  document.addEventListener('DOMContentLoaded',function(){
    document.getElementById('toggle_open').onclick = function() {
      document.getElementById('slidePanel').classList.toggle('open');
    };
    document.getElementById('toggle_close').onclick = function() {
      document.getElementById('slidePanel').classList.remove('open');
    };
  });
  ")),
    
    tags$head(
      #tags$script(src = "js/make_canvas_elements_draggable.js"),
      tags$script(src = "js/app.js"),
      tags$script(src = "js/clipboard.js"),
      tags$script(src = "js/save_quill_contents.js"),
      
      HTML('<script src="
https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.min.js
"></script>
<link href="
https://cdn.jsdelivr.net/npm/quill@2.0.3/dist/quill.bubble.min.css
" rel="stylesheet">')
    ),
    
    ### MarkJS and search bar ----
    tags$head(
      # Load Mark.js and Bootstrap
      
      tags$script(src = "https://cdn.jsdelivr.net/npm/mark.js/dist/mark.min.js"),
      
      tags$style(HTML("
      mark {
        background: linear-gradient(90deg, ##ac80dc 0%, #2575fc 100%);;
        padding: 0 0px;
        border-radius: 0px;
      }
    "))
    ),
    
    # Example page content
    # div(class = "container",
    #     h2("Example Page Content"),
    #     p("Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
    #     p("Praesent commodo cursus magna, vel scelerisque nisl consectetur et."),
    #     p("Donec ullamcorper nulla non metus auctor fringilla."),
    #     p("Cras justo odio, dapibus ac facilisis in, egestas eget quam.")
    # ),
    # JS Search Logic
    # https://markjs.io
    tags$script(HTML("
  $(document).ready(function() {

    const searchButton = document.getElementById('searchBtn');
    const clearButton = document.getElementById('clearBtn');
    const searchInput =  document.getElementById('searchText');

//var targetElement = document.querySelector('#main-content > div > div.col-sm-10 > div > div.tab-pane.fade.active.show');

    const instance = new Mark(document.body);

    searchButton.addEventListener('click', () => {
      instance.unmark();
      const keyword = searchInput.value.trim();
      if (keyword) {
        instance.mark(keyword);
      }
    });

    clearButton.addEventListener('click', () => {
      instance.unmark();
      searchInput.value = '';
    });
  });

  ")),
    
    #main content ----
    
    
    
    
    div(id = 'mydiv', class='p-0', style='display:flex;height:40px;justify-content:space-between;align-items:center;margin:5px 0px;transition: 1.5s', #background-color:rgb(45,45,45);border-radius:20px;
        
        img(src = 'img/logo_pop.png',height='35px'),
        
        # div(style='visibility:hidden;',
        #     HTML('<img style="position:relative;" bg-neutral id=shine src="https://seeklogo.com/images/H/hsc-public-health-agency-logo-E4CF7B4D14-seeklogo.com.png" />'),
        #   p('Population Health Model',style='position:relative;color:rgb(85,172,189);font-size:medium;font-weight:normal;')) ,
        
        #h1('Population Health Model',style='color:rgb(85,172,189)'),  #color:rgb(73,92,133);
        
        # Search Toolbar
        #         HTML('<div class="input-group mb-3">
        #   <input type="text" class="form-control" placeholder="" aria-label="Example text with two button addons">
        #   <div class= "btn-group"
        #     <button class="btn btn-outline-info btn-small" type="button"><i class="fa-solid fa-magnifying-glass"></i></button>
        #     <button class="btn btn-outline-info btn-small" type="button"><i class="fa-solid fa-backward-step"></i></button>
        #   </div>
        # </div>
        # '),
        
        div(class='d-flex gap-5',
            
            div(class = "d-flex align-items-center gap-2",
                div(style='margin-bottom:-12px;',textInput("searchText",  label = NULL, placeholder = "Search current page...", width = "auto")
                ),
                actionButton("searchBtn", "Search", class = "btn btn-outline-info"),
                actionButton("clearBtn", "Clear", class = "btn btn-outline-info")
                
            ),
            
            #https://getbootstrap.com/docs/5.0/forms/input-group/#button-addons
            
            img( src ='img/filefolder.jpg', width='60px;',style = 'display:none;'),
            #img(src='img/fill-blue-cupped-hands-ppl-500x398.webp',height='60px',style='visibility:hidden;')
            div(id='right-head',
                style='display:flex;align-items:center;justify-content:start;margin-right:10px;z-index:100',
                #img(src='img/ui_folder_family.svg',height='70px',style='fill:green;'),
                img(src='img/metaverse_digital_twin.png',height='30px',style='margin:5px;padding-left:40px;fill:green;'),
                
                div(style='display:inline-block;padding-top:5px;',
                    p('Digital',style='color:rgb(85,172,189);font-size:xx-small;font-weight:normal;margin-left:0px;'),
                    p('Twin',style='display:block;color:rgb(85,172,189);font-size:xx-small;font-weight:bold;margin-left:0px;')) 
            )
        )
        
    ),
    
    #hr(class="border border-primary border-1 opacity-25"),
    
    #was here 
    
    #hr(),
    
    div(id = 'main-content', style = 'display:none;',
        #hr(class="border border-secondary border-2 opacity-75"),
        
        navset_pill_list (id = '',#class='flex-center',
                          well = F,
                          fluid = F,
                          widths = c(1, 10),
                          
                          #header=hr(class="border border-secondary border-2 opacity-75"),
                          #footer=hr(class="border border-warning border-1 opacity-25"),
                          #selected = 'Evidence', 
                          #selected = 'Layout',
                          #selected = "Interactive Scenarios - intermediate",
                          #selected = 'Info Pane',
                          selected='Landing',
                          #title = "Modeling Modes",
                          #landing page-------
                          nav_panel(icon = icon('home'),
                                    title = 'Home',
                                    value='Landing', 
                                    class = 'fade active show',
                                    tags$head( tags$style('li a:hover {
              translate:Scale(1.2);
              ')),
                                    
                                    # HTML(' <ul class="breadcrumb p-3 bg-body-tertiary rounded-3 fw-semibold">
                                    #    <li class="breadcrumb-item active fa fa-home" aria-current="page">Home</li>
                                    #  </ul>'),
                                    
                                    
                                    # bar_chart_skeleton(),
                                    
                                    #https://codepen.io/ecomrick77/details/dyXBXOM
                                    
                                    #div(class='divider mb-2','Landing'),
                                    div(style='display:flex;justify-content:center;align-content:center;',
                                        div(style='width:50%;text-align:center;',
                                            button_block(border='#13b5cb',
                                                         h1(class='hello','Population Health Modelling',style='color:#13b5cb;')
                                            )
                                        )) , 
                                    #   div(style = 'overflow:hidden;height:10vh;
                                    #       display:flex;
                                    #       justify-content:center;
                                    #       align-items:center;',
                                    #   
                                    #         #p(class = 'hello','Home')
                                    #       
                                    #       bar_chart_skeleton(),
                                    #        div(class='bg-light', style='z-index:100;padding:25px;border-radius:15px;',
                                    #   HTML('<img style="height:55px;" bg-neutral id=shine src="img/pha_logo_normal.png" />'),
                                    # p('Population Health Model',style='position:relative;color:rgb(85,172,189);font-size:small;font-weight:normal;')) 
                                    #       
                                    #        
                                    #       
                                    #       ),
                                    div(style = 'overflow:hidden;height:25vh;
                  display:flex;
                 text-align:center;
                  justify-content:center;
                  align-items:center;gap:5-px;',
                                        p(style = 'white-space:pre;font-weight:semibold;font-size:x-small;
                  width:70%;',  'The public policy and planning model is built on mechanistic forecasts of non-communicable disease epidemiology.
 The forecasts go decades into the future. The mechanistic element is important, it models the relation between risk factor - outcome pairs allowing for 
      forecasts to be affected by these parameters coding risk into the model. You can pose scenarios and run simulations
      of public health policy initiatives across the health of the individual for hypothetical outcomes, quantifying impact
      before commiting. The full state - space of health determinants, both modifiable and not, socio-demographic status and 
      current morbiidity burden can be found in exploring the info section.')),
                                    
                                    
                                    div( style='font-size:13px;
                    text-align:center;
                    overflow:hidden;
                    /*height:15vh;*/
                    display:flex;
                    justify-content:center;
                    flex-direction:column;
                    align-items:center;',
                                         
                                         h2('Navigation'),
                                         tags$ul(class='ul navbar bg-light gap-3 flex-column m-1',
                                                 tags$li(
                                                   a("Resources",
                                                     class='landing',
                                                     href = '#', 
                                                     onclick = 'change_tab("resources");return false;'
                                                   )),
                                                 # tags$li(
                                                 #   a('Find resources relating to the model',
                                                 #   class='landing',
                                                 #   href = '#', 
                                                 #   onclick = 'update_tab("");return false;')),
                                                 tags$li(a('Use the model',
                                                           class='landing',
                                                           href = '#', 
                                                           onclick = 'change_tab("model-home");return false;')
                                                 )
                                                 
                                         ),
                                         
                                         a(class='btn rounded-pill text-white m-5',icon('arrow-down'), style ='background-color:rgb(45,45,45)', 'Scroll for more', href = '#info-start')
                                    ),
                                    
                                    
                                    div(style= 'margin-bottom:15%;margin-top:5%;',
                                        contact_bar_black()
                                    ),
                                    
                                    
                                    HTML('  <ol id = "info-start" class="mt-5 breadcrumb p-3 bg-body-tertiary rounded-3 fw-bold">
    <li class="breadcrumb-item fa fa-home"><a href="#" onclick = change_tab("Landing")></a></li>
    <li class="breadcrumb-item "><a href="#" onclick = change_tab("Landing")>Home</a></li>
    <!--<li class="breadcrumb-item  active" aria-current="page">Library</li> -->
  </ol>'),
                                    
                                    div(style = 'display: inline-block; vertical-align: top;',
                                        HTML('<ul class = "navbar bg-light rounded-3 gap-2 flex-column text-decoration-none fw-semibold">
      <li><a href="#validation">Validation</a></li>
      <li><a href="#pathologies">Pathologies</a></li>
      <li><a href="#tactical">Tactical</a></li>
      <li><a href="#strategic">Strategic</a></li>
    </ul>')
                                    ),
                                    div(style = 'display: inline-block; padding: 10px; width: 80%; vertical-align: top ; fw-semibold',
                                        'With an emphasis on accuracy, flexibility, and real-world applicability, 
    the Non-Communicable Disease Models are lifted from evidence and substantiated data sources and are documented throughout this page web.
    you can find references to previous, similar work across the world as well as the peer reviewed papers on which our risk is calculated, as well as the data sources from where our calibration and baseline are derived. 
    This intelligence is corroborated and collaboratively implemented across groups of specific, modeling technical and clinical expertise. It is then validated and extensively discussed.  Results are transparently derived and
    released. At the end of this process we can use theoretical health outcomes to determine where to dedicate and efficiently manage public resources on the basis of projected demand and burden.'),
                                    
                                    div(style = 'height:100%;display:flex;justify-content:center;gap:25px;padding: 100px 100px 150px 100px;',
                                        h2(id = 'validation', 'Validation'),
                                        div_cards('rgb(45,45,45)', 'white','Clinical reference Group', '',icon='check',icon_class='fa-solid greenicon'),
                                        div_cards('white', 'rgb(45,45,45)',"QUB Adele Marshalls' research group", '',icon='check',icon_class='fa-solid greenicon'),
                                        div_cards('rgb(45,45,45)', 'white','Methodology reference group', '',icon='check',icon_class='fa-solid greenicon'),
                                        div_cards('white', 'rgb(45,45,45)','Central steering group', '',icon='check',icon_class='fa-solid greenicon')
                                        
                                    ),
                                    
                                    ##div_cards ---------------------------------------------------------------
                                    
                                    
                                    div(style = 'height:100%;display:flex;justify-content:center;gap:25px;padding:150px 100px 150px 100px;background-color:rgb(45,45,45);border-radius:15px;',
                                        h2(id = 'pathologies', 'Pathology',style='color:white;'),
                                        
                                        div_cards('rgb(45,45,45)', 'lightgreen','Cardiovascular Disease', 'The Most common cause of mortality across the world',icon='heart-crack'),
                                        div_cards('rgb(45,45,45)', 'yellow','Neurological Disorders', 'The first most common cause of Non-communicable disease in the UK',icon='brain'),
                                        div_cards('white', 'darkorange','Cancers', 'Cancers use cases will share a plethora of behavioural and environmentla risk factors',icon='ribbon'),
                                        div_cards('white', 'darkorange','Chronic Respiratory Disease','Respiratory disease will share similar risk factors other disease types',icon='lungs')
                                        
                                    ),
                                    
                                    div(style = 'height:100%;display:flex;justify-content:center;gap:25px;margin:100px 100px 100px 100px',
                                        h2(id='strategic','Strategic Aims'),
                                        #pastel colour palettes
                                        #https://coolors.co/palettes/popular/pastel
                                        div_cards(
                                          border_colour = '#72ddf7',
                                          background_colour = 'white',
                                          text_colour = '#72ddf7',
                                          title = 'Trends',
                                          icon = NULL,
                                          text = 'Look at driving forces, that influence trends and look at root cause analysis that will set course for decades.'),
                                        
                                        div_cards(
                                          text_colour = '#ee6055',
                                          background_colour = 'white',
                                          border_colour = '#ee6055',
                                          title = 'Complex Systems',
                                          icon = NULL,
                                          text = 'Decompose and analyse any complex system. Identify key leverage points to influence change'),
                                        
                                        div_cards(
                                          text_colour = '#7bf1a8',
                                          background_colour = 'white',
                                          border_colour = '#7bf1a8',
                                          title = 'Horizon Scanning',
                                          icon = NULL,
                                          text = 'Helps identify emerging issues, weak signals of change and events that could lead to changes in behaviour, strategy or policy.'),
                                        
                                        
                                        div_cards(
                                          border_colour = '#ff9b85',
                                          background_colour = 'white',
                                          text_colour = '#fcab64',
                                          title = 'Scenario exploration',
                                          icon = NULL,
                                          text = 'Simulations to explore by tweaking certain facets of public health. Solution-oriented approaches to policy.',
                                          class='shadow-sm')
                                    ),
                                    
                                    div(style = 'height:100%;display:flex;justify-content:center;gap:25px;padding:100px 100px 100px 100px;background-color:rgb(45,45,45);border-radius:15px;',
                                        h2(id = 'tactical',  'Tactical Aims',style='color:white;'),
                                        
                                        div_cards(border_colour='transparent','rgb(45,45,45)', 'lightgreen',
                                                  'Epidemiological forecasting', 
                                                  'Look forward to see baseline disease prevalence, 
                      using empirical data and published risk equations at the hypothetical individual level',icon='notes-medical'),
                                        div_cards(border_colour='transparent','rgb(45,45,45)', 'yellow',
                                                  'Infrastructure', 
                                                  'See the impact on primary, community and hopsital care infrastructure, occupancy, resource and costs',icon='bed-pulse'),
                                        div_cards(border_colour='transparent','white', 'darkorange',
                                                  'Scenarios', 
                                                  'Trial and test and compare interventions and policy. ',icon='capsules'),
                                        div_cards(border_colour='transparent','white', 'royalblue',' Society and Community',
                                                  'Eveything touches health. See impact of parks, sports, childhood, education, sport policy planning' ,icon='dumbbell'),
                                        div_cards(border_colour='transparent',text_colour='white',
                                                  'mediumseagreen', 
                                                  'Economics', 
                                                  text='Design, validate and optimize new processes and facilities before spending time and money',icon='money-bill-transfer')
                                    ),
                                    
                                    a(class='btn text-white m-5',
                                      icon('arrow-right'), 
                                      onclick = 'window.change_tab("resources");', 
                                      style ='background-color:rgb(45,45,45)', 
                                      'Go to resource')
                                    
                          ),
                          
                          #Resources page ------     
                          nav_panel(icon=icon('signs-post'),
                                    title = 'Resources',
                                    value = 'resources',
                                    class = 'fade',
                                    
                                    # HTML('  <ol class="breadcrumb p-3 bg-body-tertiary rounded-3">
                                    #     <li class="breadcrumb-item fa fa-home"><a href="#" onclick = change_tab("Landing") >Home</a></li>
                                    #     <li class="breadcrumb-item fa fa-info-circle"><a href="#" onclick = change_tab("info-home") >Info</a></li>
                                    #     <li class="breadcrumb-item active">Walk through</li>
                                    #   </ol>
                                    # '),
                                    
                                    div( style = 'height:90vh',
                                         HTML('<div class=" vh-90 m-5 p-5">
              <link  rel="stylesheet" href = css/curvy-radius.css />

    <div class="row align-items-center">
    <div class="col-1 mb-4">
        </div>
      <div class="col-3 mb-4">

        <div class="fancy-border-radius-1 d-flex mx-auto align-items-center justify-content-center text-center" data-mdb-toggle="animation" data-mdb-animation-start="onLoad"
        data-mdb-animation="pulse" data-mdb-animation-duration="1000" style="animation-iteration-count: infinite;">
          <a href = "#progress" class="text-decoration-none  display-2 " style="color:rgb(45,45,45);" letter-spacing: 5px;">Progress</a>
        </div>

      </div>
      <div class="col-4 mb-4">

        <div class="fancy-border-radius-2 d-flex mx-auto align-items-center justify-content-center text-center" data-mdb-toggle="animation" data-mdb-animation-start="onLoad"
        data-mdb-animation="pulse" data-mdb-animation-duration="1000" style="animation-iteration-count: infinite;">
          <a href="#lib" class="text-decoration-none  display-2 " style="color:rgb(45,45,45);letter-spacing: 5px;">Literature</a>
        </div>

      </div>
      <div class="col-3 mb-4">

        <div class="fancy-border-radius-3 d-flex mx-auto align-items-center justify-content-center text-center" data-mdb-toggle="animation" data-mdb-animation-start="onLoad"
        data-mdb-animation="pulse" data-mdb-animation-duration="1000" style="animation-iteration-count: infinite;">
          <a href="#contemporary" class="text-decoration-none display-2 " style="color:rgb(45,45,45);letter-spacing: 5px;">Contemporary Work</a>
        </div>
      </div>
    </div>
</div>')
                                    ),
                                    
                                    # https://stackoverflow.com/questions/43210924/css-how-to-show-100px-of-an-image
                                    #     HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
                                    #     <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");>Home</a></li>
                                    #     <li class="breadcrumb-item fa"><a href="#" onclick = window.change_tab("info-home");>Info</a></li>
                                    #     <li class="breadcrumb-item active fa">Library</li>
                                    #   </ol>
                                    # '),
                                    # hr(class="border border-warning border-2 opacity-50"),
                                    #hr(class="border border-primary border-3 opacity-75"),
                                    
                                    ##flipster ----
                                    #div(id='lib',style = 'margin-top:50vh;' ,class='divider','Library'),
                                    div(id='lib',style ='height:100vh',
                                        div(
                                          style = 'display: flex !important;
      align-content: center;
      justify-content: space-evenly;
      flex-direction: column;
      flex-wrap: wrap;
      align-items: center;',
                                          icon("pen-nib",class = 'fs-1'),
                                          hatched_subtitle('Library')
                                        ),
                                        tags$head(
                                          ###js ----
                                          HTML('<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.flipster/1.1.6/jquery.flipster.min.js" integrity="sha512-IGPfWH/x5mAD5FzAQQ1fomCSHKymvEDf8W9uJyV+8bVjzIHwUAPuEkyxRZZrw5M35jFfkNeDELOiGzAcCUxVCA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>'),
                                          HTML('<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery.flipster/1.1.6/jquery.flipster.min.css" integrity="sha512-0OFs2tfng6J7BuNGgMTJoZEVBWsaBjWyz4a1p2uW34znd26WG2rwvIf8S+UZ79BXC7ewc0O9h5WSQqkujzAHww==" crossorigin="anonymous" referrerpolicy="no-referrer" />'),
                                          tags$script("$(function(){ $('#flipster').flipster(
  
  {
  style: 'carousel',
  spacing:0,
  nav: true,
  buttons: true }) });"),
                                          tags$style("
   .flipster__nav__link{
  text-decoration:none;
   }
  
  .flipster__nav__child{
    background-color:transparent!important;
  }
  
.flipster--carousel .flipster__item--current .flipster__item__content {
    margin-inline: 100px;
}
    
    /*
  
  div#flipster{
  margin-top:5%;
  height:80vh;
  overflow:clip;
  }
  
div.flipster__item__content img {
  /* width:800px;
  overflow:hidden;
  /* margin-right:-100px; */
  padding:0px;
  */
}



    div.flipster__item__content {
     /* width:800px; */
  /* border: solid 0.5em transparent; */
  border: solid 1em white; 
  border-radius: 10px;
  background-image: linear-gradient(white, white), 
                    linear-gradient(to right,  rgb(85,172,188), gold,  rgb(56,75,123));
                    
  background-origin: border-box;
  background-clip: content-box, border-box;
  }
  
  
  div.flipster__item__content{
    max-height:400px;
      overflow:hidden;
  }
    */

"

                                          )),
                                        
                                        
                                        ###html ----
                                        HTML('
 <div id = "flipster" class="flipster p-3 m-3">
    <ul>
<li data-flip-title = "Population Health Models" data-flip-category = "Deprivation" > <img onclick = window.open("https://pmc.ncbi.nlm.nih.gov/articles/PMC3602270/#:~:text=Interpretation%3A,health%20conditions%20and%20socioeconomic%20deprivation.") src="www/pubmed.ncbi.nlm.nih.gov_23422444_.png"/></li>
<li data-flip-title =  "Risk" data-flip-category = "Risk"> <img onclick = window.open("https://pubmed.ncbi.nlm.nih.gov/32015079/","_blank") src="www/pubmed.ncbi.nlm.nih.gov_32015079_.png"/></li>
<li data-flip-title =  "Risk" data-flip-category = "Risk"> <img onclick = window.open("https://pubmed.ncbi.nlm.nih.gov/32015079/","_blank") src="www/pubmed.ncbi.nlm.nih.gov_32015079_.png"/></li>
<li data-flip-title =  "CVD" data-flip-category = "Cardiovascular Disease"> <img onclick = window.open("https://pubmed.ncbi.nlm.nih.gov/32015079/") src="www/stroke.png"/></li>
<li data-flip-title =  "scenario" data-flip-category = "Interventions" >    <img onclick = window.open("https://pubmed.ncbi.nlm.nih.gov/32015079/") src="www/www.thelancet.com_journals_lanhl_article_PIIS2666-7568(21)00146-X_fulltext.png"/></li>
    </ul>
</div>

')),
                                    
                                    HTML("<style>
    .grid {
      max-width: 1000px;
      margin: 0 auto;
    }

    .grid-sizer,
    .grid-item {
      width: 200px; /* Fixed width */
    }

    .grid-item {
      margin-bottom: 20px;
      background: #ddd;
      border-radius: 8px;
      box-sizing: border-box;
    }

    .grid-item-content {
      padding: 10px;
      background: white;
      border-radius: 6px;
    }
    
  </style>
</head>
<body>
<!--
<div class='grid'>
  <div class='grid-sizer'></div>

  <div class='grid-item'>
    <div class='grid-item-content' style='height: 100px; background-color: #a0d2eb;'>Short item</div>
       </div>
       
       <div class='grid-item'>
       <div class='grid-item-content' style='height: 180px; background-color: #ffb3c1;'>Taller item</div>
       </div>
       
       <div class='grid-item'>
       <div class='grid-item-content' style='height: 250px; background-color: #c1f0c1;'>Even taller item</div>
       </div>
       
       <div class='grid-item'>
       <div class='grid-item-content' style='height: 150px; background-color: #f6d186;'>Medium item</div>
       </div>
       </div>
       
       -->
       
       <!-- Masonry JS -->
       <script src='https://unpkg.com/masonry-layout@4/dist/masonry.pkgd.min.js'></script>
       <script>
       var grid = document.querySelector('.grid');
     var msnry = new Masonry(grid, {
       itemSelector: '.grid-item',
       columnWidth: '.grid-sizer',
       gutter: 10,
       percentPosition: false
     });
     </script> "),
                                    
                                    
                                    div(id='contemporary'),
                                    div(
                                      style = 'display: flex !important;
      align-content: center;
      justify-content: space-evenly;
      flex-direction: column;
      flex-wrap: wrap;
      align-items: center;',
                                      icon('table-columns', 
                                           class='fs-1'),
                                      
                                      hatched_subtitle ('Contemporary Work')),
                                    HTML('  <ol class="mt-5 breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item "><a href="#" onclick = window.change_tab("info-home");>Info</a></li>
    <li class="breadcrumb-item active ">Contemporary</li>
  </ol>
'),
                                    
                                    
                                    # contemporary work ----
                                    #div(id='contemporary',class='divider m-5', 'Contemporary Work'),
                                    
                                    ##################   https://github.com/riktar/jkanban
                                    HTML('

<head> 
<style>

.card i{
color:gold;
}

</style>
</head> 
<div class="album p-5 m-5 bg-body-tertiary">
      <div class="">
  
        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3">
          <div class="col">
          <!-- <div class="card-group"> -->
            <div class="card shadow-sm">
              <img src = "img/similar_work/qintervention.png" class="bd-placeholder-img card-img-top bg-dark-subtle" width="70%" height="70%"> </img>
              <div class="card-body">
              <h3> Qrisk</h3>
                <p class="h-5 p-2 card-text">TWe source a number of risk equations from the Qresearch database. 
                It is based on statistical regression to longitudinal data from a composite UK primary care database.
                The Interventions featuer demosnstrates on a single morbidity level the source of primary intervention our model poses at a population level</p>
                <div class="d-flex justify-content-between align-items-center">
                  <div class="btn-group">
                    <a target="_blank"  type="button" href = "https://qintervention.org/index.php" class="btn btn-sm btn-outline-tertiary">View</a>
                    
                    <a target = "_blank" href = "https://www.bmj.com/content/340/bmj.c2197.full" type="button" class="btn btn-sm btn-outline-tertiary">Paper</a>
                  
                  </div>
                  <small class="text-body-secondary">Relevance <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i></small>
                </div>
              </div>
            </div>
          </div>
        <div class="col">
          <div class="card shadow-sm bg-body-tertiary">
            <img src = "img/similar_work/POHEM_canada.png" class="bd-placeholder-img card-img-top bg-body-tertiary rounded" width="70%" height="70%"> </img>
            <div class="card-body  bg-success-subtle">
            <h3> Canadian Population Health Model</h3>
              <p class="card-text bg-success-subtle  h-5 p-2 "> One of the earlier and pioneering ensemble population health models. As well as Cardiovascular disease the Cancadian Population Health
              Economic Model also modelled osteoporosis and dementias. It similarly used individual risk equations for its Epi engine
              as we have. Also in a microsimulation.</p>
              <div class="d-flex justify-content-between align-items-center">
                <div class="btn-group">
                  <a target="_blank" href = "https://pophealthmetrics.biomedcentral.com/articles/10.1186/s12963-015-0057-x#Tab1" type="button" class="btn btn-sm btn-outline-tertiary">View</a>
        <!--
                  <button type="button" class="btn btn-sm btn-outline-tertiary">Edit</button>
                -->
                </div>
                <div>
                  <small class="text-body-secondary">Insight <i class="fa-solid fa-star"></i></small>

                <small class="text-body-secondary">Relevance <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i></small>
              </div>
              
              </div>
            </div>
          </div>
        </div>
        <div class="col">
          <div class="card shadow-sm">
            <img src = "img/similar_work/PHE_CVD_cost_effectiveness_tool.png" class="bd-placeholder-img card-img-top" width="70%" height="70%" ></img>
            <div class="card-body">
            <h3> CVD Prevention Program</h3>
              <p class="h-5 p-2 card-text">A sleek UI wraps hidden calculation on the cost effectiveness of certain interventions.  This ocst effectiveness model
              is notable for validation and similarity of the the epi engine used to forecast morbidity. It calls on risk equations from 
              across peer reviewed literature and make use of Framingham heart study derived risk, and risk from other constituenties, as well as uk focused Qrisk scores.</p>
              <div class="d-flex justify-content-between align-items-center">
                <div class="btn-group">
                  <a target ="_blank" href="https://cvd-prevention.shef.ac.uk" type="button" class="btn btn-sm btn-outline-tertiary">View</a>
        
                  <a target ="_blank" href = "https://cvd-prevention.shef.ac.uk/files/Project%20Report.pdf" type="button" class="btn btn-sm btn-outline-tertiary">Report </a>
                  
                  <a target ="_blank" href = "https://cvd-prevention.shef.ac.uk/files/Database%20of%20Interventions.xlsx" type="button" class="btn btn-sm btn-outline-tertiary">Database </a>

                </div>
              </div>
                <small class="text-body-secondary">Relevance 
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i></small>
            </div>
          </div>
        </div>

        <div class="col">
          <div class="card shadow-sm">
            <img src = "img/similar_work/impactNCD.png" class="bd-placeholder-img card-img-top" width="70%" height="70%"> </img>
            <div class="card-body">
            <h3> ImpactNCD</h3>
              <p class="h-5 p-2 card-text"> The Impact NCD model similarly lifts parameters regarding risk-outcome pairs from literature from foreign studies
              while similar in the breadth of socio-demographic, behavioural and physiological risk factors it considers, it is distinct in using age stratified relative risk between risk-outcome pairs.
              the authors make use of Lewins formula to calculate Population Attributable Risk Fractions to attribute proportion of disease burden to that risk factor
              and run scenarios on the effect of reducing or eliminating that risk factor.</p>
              <div class="d-flex justify-content-between align-items-center">
                <div class="btn-group">
                  <a href = "https://www.liverpool.ac.uk/population-health/research/groups/ncd-prevention-and-food-policy/ncd-modelling/" type="button" class="btn btn-sm btn-outline-tertiary">View</a>

                  <a href = "https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf" type="button" class="btn btn-sm btn-outline-tertiary">Report</a>

                </div>
                <small class="text-body-secondary">Relevance 
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i></small>
              </div>
            </div>
          </div>
        </div>
        <div class="col">
          <div class="card shadow-sm">
            <img src = "img/similar_work/paper_risk.png" class="bd-placeholder-img card-img-top" width="70%" height="70%" ></img>
            <div class="card-body">
            <h3> Paper consolidating risk</h3>
              <p class="h-5 p-2 card-text">This paper eloquently collates and articulates the synergy and compatibility of different risk equations, particularly those form different 
              constituencies</p>
              <div class="d-flex justify-content-between align-items-center">
                <div class="btn-group">
                  <a type="button" class="btn btn-sm btn-outline-tertiary">View</a>
        <!--
                  <button type="button" class="btn btn-sm btn-outline-tertiary">Edit</button>
                -->
                </div>
                <small class="text-body-secondary">Relevance 
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i>
                <i class="fa-solid fa-star"></i></small>
              </div>
            </div>
          </div>
        </div>
        <div class="col">
          <div class="card shadow-sm">
            <img src = "img/similar_work/oncosim.png" class="bd-placeholder-img card-img-top" width="70%" height="70%" ></img>
            <div class="card-body bg-dark">
            <h3> Cancer Modelling in Canada</h3>
              <p class="card-text"> A microsimulation model from Canada demonstrating the ubiquity of these models across a range of theoretical modelling of non-commmunicable disease epidemiology</p>
              <div class="d-flex justify-content-between align-items-center">
                <div class="btn-group">
                  <a type="button" role="button" class="btn btn-sm btn-outline-tertiary text-white">View</a>
        <!--
                  <button type="button" class="btn btn-sm btn-outline-tertiary">Edit</button>
                -->
                </div>
                <small class=" text-white">Relevance <i class="fa-solid fa-star"></i><i class="fa-solid fa-star"></i></small>
              </div>
            </div>
          </div>
        </div>
        <!-- </div> card group classed div -->

      </div>
    </div>
  </div>'),
                                    
                                    #hover css
                                    tags$link(rel = "stylesheet", type = "text/css", href = "css/cards.css"),
                                    
                                    # HTML('  <ol class="mt-5 breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
                                    #     <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");>Home</a></li>
                                    #     <li class="breadcrumb-item fa"><a href="#" onclick = window.change_tab("info-home");>Info</a></li>
                                    #     <li class="breadcrumb-item active fa">Trello</li>
                                    #   </ol>
                                    # '),
                                    
                                    ##trello ====
                                    #div(id = 'progress' , class='divider m-5','Progress'),
                                     
                                        div(
                                          style = 'display: flex !important;
      align-content: center;
      justify-content: center;
      width:100%;
      flex-direction: row;
      flex-wrap: wrap;
      align-items: center;',
                                          hatched_subtitle('Progress'),
                                          icon('bars-progress', class =
                                                 'fs-1')
                                        ),       
                                    
                                    div(id='progress',
                                      
                                        
                                        HTML("  <link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/jkanban@1.2.0/dist/jkanban.min.css' />
  <style>
    #progress {
      background-color: rgb(35, 35, 35);
      color: white;
      font-family: sans-serif;
    }

    #myKanban {
      padding: 20px;
    }

    .kanban-board {
      background-color: rgb(45, 45, 45);
      border-radius: 8px;
      border: 1px solid rgb(85, 172, 189);
      box-shadow: 0 2px 6px rgba(0,0,0,0.5);
    }

    .kanban-board-header {
      background-color: rgb(85, 172, 189);
      color: black;
      padding: 10px;
      border-radius: 8px 8px 0 0;
      font-weight: bold;
    }

    .kanban-item {
      background-color: rgb(60, 60, 60);
      color: white;
      border-left: 4px solid rgb(85, 172, 189);
      padding: 10px;
      margin: 10px;
      border-radius: 4px;
    }
  </style>
</head>
<body>

<div id='myKanban'></div>

<script src='https://cdn.jsdelivr.net/npm/jkanban@1.2.0/dist/jkanban.min.js'>
</script>

<script>
// First, make sure a container exists in the DOM
let board = document.createElement('div');
board.id = 'myKanban';
document.body.appendChild(board);

// Now initialize the Kanban board
var KanbanTest = new jKanban({
  element: '#myKanban', // this was commented out
  gutter: '15px',
  widthBoard: '280px',
  boards: [
    {
      id: '_todo',
      title: 'To Do',
      class: 'custom-board',
      item: [
        { title: 'Model Site specific cancers' },
        { title: 'Lung cancer screening' },
        { title: 'Bowel cancer screening' },
        { title: 'Cervical cancer screening' },
        { title: 'Neurogenerative Diseases' },
        { title: 'Health Inequality' }



      ]
    },
    {
      id: '_inprogress',
      title: 'In Progress',
      class: 'custom-board',
      item: [
        { title: 'Obesity' },
        { title: 'Hypertension' },
        { title: 'Cholesterol' },
        { title: 'Statins Interventions' },
        { title: 'Other Neurodegenerative Disease, Parkinsons/Alzheimers' },
        { title: 'Asthma, Parkinsons/Alzheimers' },
        { title: 'COPD Neurodengenerative Disease, Parkinsons/Alzheimers' },
        { title: 'Epilepsy, Parkinsons/Alzheimers' },
        { title: 'Disaggregating Ty1 and Ty2 diabetes better' },
        { title: 'Better pathway for pre-diabetes to diabetes progression' }


      ]
    },
    {
      id: '_done',
      title: 'Done',
      class: 'custom-board',
      item: [
        { title: 'Cardiovascular Disease' },
        { title: 'Dementia' },
        { title: 'Other Neurodengenerative Disease' },
        { title: 'Kidney disease' },
        { title: 'Atrial Fibrillation on Stroke scenario' },
        { title: 'SPPG results for projected baseline prevalence' },
        { title: 'Conservative Projection of three state population BMI' }



      ]
    }
  ]
});
</script>")),

  
                                    tags$head(
                                      # resize all font to smaller font
                                      #tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
                                      
                                      #tags$link(rel='stylesheet',href='css/timeline.css'),
                                      ###js ----
                                      HTML('<script>
    $(function() {
    
    console.log("draggable trello board initialised");
        // Make the cards draggable
        $(".card1").draggable({
            revert: "invalid", // If not dropped in a valid target, the card will go back to its original position
            //zIndex: 1000,
            start: function(event, ui) {
                $(this).addClass("dragging");
            },
            stop: function(event, ui) {
                $(this).removeClass("dragging");
            }
        });
        
          $(".card2").draggable({
            revert: "invalid", // If not dropped in a valid target, the card will go back to its original position
            //zIndex: 1000,
            start: function(event, ui) {
                $(this).addClass("dragging");
            },
            stop: function(event, ui) {
                $(this).removeClass("dragging");
            }
        });
        
        $(".card1").droppable({
            accept: ".card2", // Only accept elements with the class "card"
            drop: function(event, ui) {
                $(this).append(ui.helper);
                ui.helper.css({
                    "top": "auto",
                    "left": "auto"
                });
            }
        });

        // Make the columns droppable
        $(".column1").droppable({
            accept: ".card1", // Only accept elements with the class "card"
            drop: function(event, ui) {
                $(this).append(ui.helper);
                ui.helper.css({
                    "top": "auto",
                    "left": "auto"
                });
            }
        });
    });
</script>
'),
                                      
                                      ###css -----
                                      HTML('<link rel = "stylesheet"  type = "text/css" href = "css/trello.css"/>') ) ,
                                    #trello()
                                    
                                    
                                    
                          ),
                          # nav_panel(icon=icon(''),
                          #           title = 'news', 
                          #           value = 'news',
                          #           class = 'fade',
                          #   
                          #           ),
                          
                          #Schematic page ----
                          
                          nav_panel('Schematic',
                                    icon= img(src= 'img/blueprint_!.png',width='15px;'),
                                    #div(class='divider','Overview'),
                                    class = 'fade m-5',
                                    #https://stackoverflow.com/questions/4907843/open-a-url-in-a-new-tab-and-not-a-new-window
                                    
                                                       HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item "><a href="#" onclick = window.change_tab("info-home");>Info</a></li>
    <li class="breadcrumb-item  active">Outline</li>
  </ol>
'),
                                    #button_block( border='rgb(35,35,35)',
                                                  div( style = 'display: flex !important;
                                                    
                                                     justify-content: space-between;
                                                       align-items: center;' ,
      HTML('<ul class = "navbar bg-light rounded-3 gap-2 flex-column text-decoration-none fw-semibold ml-5">
      <li><a style= "font-size: x-small;" href="#model"> Model </a></li>
      <li><a style= "font-size: x-small;" href="#project">Project </a></li>
    </ul>'), 
                                                  div(class = 'd-flex gap-5',
                                                   tags$button(class = 'btn btn-outline-info rounded-pill','Project Schematic Reference', icon('up-right-from-square'), onclick = "window.open('https://pophealthmetrics.biomedcentral.com/articles/10.1186/s12963-015-0057-x/figures/1','_blank').focus();"),
                                                   tags$button(class = 'btn btn-outline-dark rounded-pill',icon('bars'),'Resources', onclick = "change_tab('resources')"),
                                                   tags$button(class = 'btn btn-outline-dark rounded-pill',icon('bars'), 'Model', onclick = "change_tab('model-home')")
                                                  ),
                                                  # button_box_shadow(color='#13b5cb',border='#13b5cb','Reference',   onclick = "window.open('https://pophealthmetrics.biomedcentral.com/articles/10.1186/s12963-015-0057-x/figures/1','_blank').focus();"),
                                                  # #button_box_shadow(color='#13b5cb',border='#13b5cb','Download png'),
                                                  # button_box_shadow(color='#13b5cb',border='#13b5cb','Go to Resources', onclick = "change_tab('resources')"),
                                                  # button_box_shadow(color='#13b5cb',border='#13b5cb','Go to model', onclick = "change_tab('model-home')")
                                    #),
      
                                                  div(),
                                                  ),
                                    
                                    HTML('<script src="https://cdn.jsdelivr.net/npm/atropos@2.0.2/atropos.min.js"></script>
    <!-- AtroposJS JS -->
    <link href="https://cdn.jsdelivr.net/npm/atropos@2.0.2/atropos.min.css" rel="stylesheet">'),
                                    
                                    # initialise atropos elements
                                    shiny::tags$script("
// import Atropos library

 //Initialize
document.addEventListener('DOMContentLoaded', function() {
   const myAtropos1 = Atropos({
  el: '#my-atropos1',
  activeOffset: 99,
  shadow: false
});


const myAtropos2 = Atropos({
  el: '#my-atropos2',
  activeOffset: 99,
  shadow: false
});
});
"
                                                       
                                    ),
                                    
                                    tags$link( href = "css/atrophos_elements.css",type = "text/css",  rel= "stylesheet"),
                                    
                                    div(id='model', style = 'margin-top:150px;height:90vh;',
                                        hatched_subtitle('Model Definition'),
                                        
                                        HTML('<div class = "d-flex justify-content-center align-items-center">
  <div id = "my-atropos1" class="atropos">
  <div class="atropos-scale">

    <div class="atropos-rotate">

          <img class="atrophos" src="img/atrophos/big_arrow_outputs.png" data-atropos-offset="6" />
          <img class="atrophos" src="img/atrophos/smaller_arrow_outputs.png" data-atropos-offset="4" />
          <img class="atrophos" src="img/atrophos/small_arrows_demographics.png" data-atropos-offset="4" />
          <img class="atrophos" src="img/atrophos/risk_factors.png" data-atropos-offset="6" />

      <div class="atropos-inner border-info-subtle bg-opacity-75 rounded-5"> 

    </div>
  </div>
</div>
</div>
     </div>' )
                                    ),
                                    
                                    ################################# Second Atrophos ############################
                                    HTML('<div class="container">
                                      <div id = "my-atropos2" class="atropos">
                                      <div class="atropos-scale">
                                        <div class="atropos-rotate">
                                          <div class="atropos-inner">
                                               <img class="atrophos" src="img/atrophos/schematic first (1).png" data-atropos-offset="0" />
                                              <img class="atrophos" src="img/atrophos/schematic risk (1).png" data-atropos-offset="1" />
                                              <img class="atrophos" src="img/atrophos/schematic int (1).png" data-atropos-offset="2" />
                                              <img class="atrophos" src="img/atrophos/schematic output (1).png" data-atropos-offset="3" />
                                              <img class="atrophos" src="img/atrophos/schematic arrows (1).png" data-atropos-offset="4" />
                                              <img class="atrophos" src="img/atrophos/schematic labels (1).png" data-atropos-offset="5" />
                                          </div>
                                        </div>
                                      </div>
                                    </div>
                                     </div>'),
                                    
                                    #  tags$a(class = 'reference my-2 mx-0', href='https://pophealthmetrics.biomedcentral.com/articles/10.1186/s12963-015-0057-x#Fig1',
                                    #          target='_new',"reference"),
                                    #   tags$a(class = 'reference my-2', href='https://pophealthmetrics.biomedcentral.com/articles/10.1186/s12963-015-0057-x#Fig1',
                                    #          target='_new',"download"),
                                    # tags$a(class = 'reference my-2', href='https://pophealthmetrics.biomedcentral.com/articles/10.1186/s12963-015-0057-x#Fig1',
                                    #          target='_new',"resources"),
                                    # tags$a(class = 'reference my-2', href='https://pophealthmetrics.biomedcentral.com/articles/10.1186/s12963-015-0057-x#Fig1',
                                    #          target='_new',"risk"),
                                    # tags$a(class = 'reference my-2', href='https://pophealthmetrics.biomedcentral.com/articles/10.1186/s12963-015-0057-x#Fig1',
                                    #          target='_new',"population"),
                                    
                                    div(id='project',style = 'margin-top:50px;',
                                        hatched_subtitle('Project Schematic'),
                                        
                                        div(style="display:flex; flex-direction:column;align-items:center;justify-content:center;gap:-10px;margin-top:50px;",
                                            
                                            # tags$object(data= 'img/top timeline.svg', type = 'image/svg+xml', width = '90%', height = '65%'),
                                            
                                            #  tags$object(id='svgObject' , data= 'img/schematic.svg', type = 'image/svg+xml', width = '90%', height = '50%'),
                                            ###fold pls ---
                                            #HTML(return_character_svg())
                                            #tags$object(data= 'img/bottom timeline.svg', type = 'image/svg+xml', width = '90%', height = '50%'),
                                            
                                        )
                                    )
                          ),
                          
                          #Risk Lineage page ----
                          nav_panel(icon=icon('magnifying-glass-chart'),
                                    title='Evidence',
                                    value = 'evidence',
                                    class = 'fade',
                                    #div('Cause and Effect, and Taxonomy',  class='divider fs-5'),
                                    
                                    HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item "><a href="#" onclick = window.change_tab("info-home");>Info</a></li>
    <li class="breadcrumb-item  active">Evidence</li>
  </ol>
'),
                                    
                                    HTML('<h4 class="bg-charcoal text-light rounded-3 m-2 p-2"> Taxonomy, and Cause and effect </h4>'),
                                    
                                    
                                    #flex align
                                    div( class='d-flex align-items-baseline justify-content-center my-3 gap-5 flex-row',
                                         
                                         #flex centre
                                         
                                         div( class='d-flex flex-column align-items-baseline justify-content-center my-3 gap-5',
                                              
                                              # div('inputs and outputs',  class='divider fs-6 w-100'),
                                              
                                              
                                              div(class="border border-warning border-3 rounded-3 vw-30",
                                                  
                                                  visNetworkOutput('network_risk_lineage',width = '500px',height='500px'),
                                                  #div(style='width:700px;height:500px;', network_risk_lineage),
                                                  
                                                  
                                              ),
                                              HTML('<button class="btn btn-outline-danger" role ="button" onclick = window.open("https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41","_blank").focus();> 
      Our casual graph recreated from reference
      <i class="fa-solid fa-arrow-up-right-from-square"></i>
</button>')
                                         ),
                                         
                                         
                                         
                                         #tags$a(class = 'reference', style = 'margin:20px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','reference'),
                                         #tags$a(class = 'reference', style = 'margin:20px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','download'),
                                         #tags$a(class = 'reference', style = 'margin:20px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','filter')
                                         #button_block( border='#13b5cb',
                                         
                                         
                                         div( class = 'd-flex flex-column align-items-baseline justify-content-center my-3 gap-4',
                                              #div('Nomenclature and taxonomy',  class='divider fs-6 w-100'),
                                              tags$object(
                                                data = 'img/svg/taxonomy of CVD.svg',
                                                type = 'image/svg+xml',
                                                width = '450px',
                                                height = '500px'
                                              ),
                                              HTML('<button class="btn btn-pill btn-outline-danger" disabled> Taxonomy subdividision of CVD morbidity ( Source: Our group in collaboration with clinicians )</button>')
                                         )
                                         
                                    )
                          ),
                          # button_box_shadow(
                          #   color = '#13b5cb',
                          #   border = '#13b5cb',
                          #   'Our casual graph recreated from reference',
                          #   onclick = 'window.open("https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41","_blank").focus();'
                          #   ),
                          
                          ################################# Scrollspy  ################################# 
                          
                          # HTML('<div id="list-example" class="list-group">
                          #   <a class="list-group-item list-group-item-action" href="#list-item-1">Item 1</a>
                          #   <a class="list-group-item list-group-item-action" href="#list-item-2">Item2</a>
                          #   <a class="list-group-item list-group-item-action" href="#list-item-3">Item 3</a>
                          #   <a class="list-group-item list-group-item-action" href="#list-item-4">Item 4</a>
                          # </div>
                          # <div data-spy="scroll" data-target="#list-example" data-offset="0" class="scrollspy-example">
                          #   <h4 id="list-item-1">Item 1</h4>
                          #   <p>...</p>
                          #   <h4 id="list-item-2">Item 2</h4>
                          #   <p>...</p>
                          #   <h4 id="list-item-3">Item 3</h4>
                          #   <p>...</p>
                          #   <h4 id="list-item-4">Item 4</h4>
                          #   <p>...</p>
                          # </div>')
                          # ),
                          
                          #Risk table Page ----
                          nav_panel(
                            icon=icon('table'),
                            title= 'Risk',
                            value = 'Risk',
                            class='fade',
                            #div(class='divider', 'Risk Equations'),
                            HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item "><a href="#" onclick = window.change_tab("Landing");>Info</a></li>
    <li class="breadcrumb-item active">Risk</li>
  </ol>
'),
                            hatched_subtitle('Risk'),
                            tags$head(
                              tags$style('
  #risk_equation_dt a:hover{
  transform:scale(1.2);
  /* margin: 5px !important; */
  transition: all 1.5s ease 0.1s;}
  
  #risk_equation_dt tr{
  display:block;
    padding:10px !important;
    margin:10px !important;
  }
    
  #risk_equation_dt a{
    color:rgb(45,45,45);
    text-decoration:none;}
    
  #risk_equation_dt td{
   padding:10px !important;
    margin:10px !important;
    border:solid lightgrey;
     border-width:0px 0px 1px 0px;
  }'           
                              )),
                            
                            div(class='d-flex align-items-center justify-content-center m-2 p-2',
                                dataTableOutput('risk_equation_dt',width = '70vw',height='50%')
                            )#,
                            #risk_table_dt
                          ),
                          
                          #Basline Prevalence Plots -----
                          nav_panel(title = 'Baseline',
                                    value = 'population analytics',
                                    class='fade',
                                    icon=icon('map-pin'),
                                    #div(class=ß'divider', 'Population Baseline Characteristics'),
                                    HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class=" fa fa-home m-2" ></li>
    <li class="breadcrumb-item" ><a href="#" onclick = window.change_tab("Landing");>Home</a></li>
    <li class="breadcrumb-item "><a href="#" onclick = window.change_tab("Info");>Info</a></li>
    <li class="breadcrumb-item active">Population</li>
  </ol>
'),
                                    
                                    #   div(style='display:flex;gap:0px;',
                                    #   tags$a(class = 'reference', style = 'margin:0px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','alcohol'),
                                    #   tags$a(class = 'reference', style = 'margin:0px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','smoking'),
                                    #   tags$a(class = 'reference', style = 'margin:0px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','bmi'),
                                    #   tags$a(class = 'reference', style = 'margin:0px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','excercise'),
                                    #   tags$a(class = 'reference', style = 'margin:0px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','diet'),
                                    #   tags$a(class = 'reference', style = 'margin:0px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','morbidity'),
                                    #   tags$a(class = 'reference', style = 'margin:0px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','diabetes'),
                                    #   tags$a(class = 'reference', style = 'margin:0px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','cholesterol'),
                                    #   tags$a(class = 'reference', style = 'margin:0px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','hypertension'),
                                    #   tags$a(class = 'reference', style = 'margin:0px;',target='_blank',href = 'https://www.health.org.uk/sites/default/files/2023-07/REAL_Insights_Technical%20appendix.pdf#page=41','hypertension')
                                    # ),
                                    
                                    #coming_soon(),
                                    
                                    
                                    
                                    ## modifiable ----
                                    tags$div(
                                      class = "accordion", id = "accordionExample",
                                      
                                      # Panel 1
                                      tags$div(class = "",
                                               tags$h2(class = "", id = "headingOne",
                                                       tags$div(
                                                         class = "", type = "button",
                                                         "data-bs-toggle" = "collapse", "data-bs-target" = "#collapseOne",
                                                         "aria-expanded" = "true", "aria-controls" = "collapseOne",
                                                         hatched_subtitle('Modifiable Risk')
                                                         
                                                       )
                                               ),
                                               tags$div(id = "collapseOne", class = "accordion-collapse collapse show", 
                                                        "aria-labelledby" = "headingOne", "data-bs-parent" = "#accordionExample",
                                                        tags$div(class = "", div(class='echarts_holder',
                                                                                 div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Age Alcohol Consumption'),prevalence_plot_alcohol),
                                                                                 div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Age Activity'),prevalence_plot_physical_activity),
                                                                                 div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Age Fruit and Veg intake'),prevalence_plot_fruit_veg_consumption),
                                                                                 div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Age BMI'),prevalence_plot_bmi_level),
                                                                                 div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Age Prevalence of Smoking '),prevalence_plot_cigerette_smoking)
                                                                                 #div(h5(class='bg-light rounded-3 m-2 p-2','Prevalence of Current Serious morbidities'),prevalence_plot_CVD_Status)
                                                        )
                                                        )
                                               )
                                      ),
                                      
                                      
                                      # Panel 2
                                      tags$div(class = "",
                                               tags$h2(class = "", id = "headingTwo",
                                                       tags$div(
                                                         class = "", type = "button",
                                                         "data-bs-toggle" = "collapse", "data-bs-target" = "#collapseTwo",
                                                         "aria-expanded" = "true", "aria-controls" = "collapseTwo",
                                                         hatched_subtitle('Physiological Risk')
                                                         
                                                       )
                                               ),
                                               tags$div(id = "collapseTwo", class = "accordion-collapse collapse", 
                                                        "aria-labelledby" = "headingTwo", "data-bs-parent" = "#accordionExample",
                                                        tags$div(class = "", div(class='echarts_holder',
                                                                                 div(h4(class='bg-dark text-light rounded-3 m-2 p-2','Prevalence of Hypertension'),prevalence_plot_hypertension),
                                                                                 div(h4(class='bg-dark text-light rounded-3 m-2 p-2','Prevalence of Hypercholesterolemia'),prevalence_plot_high_cholosterol),
                                                                                 div(h4(class='bg-dark text-light rounded-3 m-2 p-2','Prevalence of Diabetes'),prevalence_plot_diabetes)
                                                        )
                                                        )
                                               )
                                      ),
                                      
                                      # Panel 3
                                      tags$div(class = "",
                                               tags$h2(class = "", id = "headingThree",
                                                       tags$div(
                                                         class = "", type = "button",
                                                         "data-bs-toggle" = "collapse", "data-bs-target" = "#collapseThree",
                                                         "aria-expanded" = "true", "aria-controls" = "collapseThree",
                                                         div(# style = 'padding-bottom:10px;',
                                                           hatched_subtitle('Trends in Disease Prevalence')
                                                         )
                                                         
                                                       )
                                               ),
                                               tags$div(id = "collapseThree", class = "accordion-collapse collapse", 
                                                        "aria-labelledby" = "headingThree", "data-bs-parent" = "#accordionExample",
                                                        tags$div(class = "", 
                                                                 div(class='echarts_holder',
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Cancer'),cancer_plot),
                                                                     #div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','COPD'),copd_plot),
                                                                     #div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Asthma'),asthma_plot),
                                                                     #div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Depression'),depression_plot),
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Mental Health '),mental_plot),
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Atrial Fibrillation'),af_plot),
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Coronary Heart Disease'),chd_plot),
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Heart Failure 1'),hf1_plot),
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Heart Failure 3'),hf3_plot),
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Stroke '),stroke_plot),
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Chronic Kidney Disease'),ckd_plot),
                                                                     #div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Non - Diabetic Hyperglycemia'),hypergly_plot),
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Diabetes Mellitus'),DM2_plot),
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Hypertension'),hy_plot),
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Dementia '),dementia_plot),
                                                                     #div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Osteoporosis '),osteoporosis_plot),
                                                                     #div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Arthritis'),arthritis_plot)
                                                                 )
                                                        )
                                               )
                                      ),
                                      
                                      # Panel 4
                                      tags$div(class = "",
                                               tags$h2(class = "", id = "headingFour",
                                                       tags$div(
                                                         class = "", type = "button",
                                                         "data-bs-toggle" = "collapse", "data-bs-target" = "#collapseFour",
                                                         "aria-expanded" = "true", "aria-controls" = "collapseFour",
                                                         div(# style = 'padding-bottom:10px;',
                                                           hatched_subtitle('Ethnicity')
                                                         )
                                                         
                                                       )
                                               ),
                                               tags$div(id = "collapseFour", class = "accordion-collapse collapse", 
                                                        "aria-labelledby" = "headingFour", "data-bs-parent" = "#accordionExample",
                                                        tags$div(class = "", 
                                                                 div(class='echarts_holder',
                                                                     
                                                                     div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Ethnicity'),absolute_ethnicity_facet_plot_apex),
                                                                     
                                                                 )
                                                        )
                                               )
                                      ),
                                      # Panel 5
                                      tags$div(class = "",
                                               tags$h2(class = "", id = "headingFive",
                                                       tags$div(
                                                         class = "", type = "button",
                                                         "data-bs-toggle" = "collapse", "data-bs-target" = "#collapseFive",
                                                         "aria-expanded" = "true", "aria-controls" = "collapseFive",
                                                         div(# style = 'padding-bottom:10px;',
                                                           hatched_subtitle('Demography')
                                                         )
                                                         
                                                       )
                                               ),
                                               tags$div(id = "collapseFive", class = "accordion-collapse collapse show", 
                                                        "aria-labelledby" = "headingFive", "data-bs-parent" = "#accordionExample",
                                                        tags$div(class = "", 
                                                                 div(class='echarts_holder',
                                                                     
                                                                     
                                                                     # div(
                                                                     #  h4(
                                                                     #   class='bg-charcoal text-light rounded-3 m-2 p-2','NI, Geography, Population and Deprivation'),
                                                                     # e_arrange(x1, mdm_rank_tds, x2, cols = 3)
                                                                     #  ),
                                                                     
                                                                     div(h4(class = 'bg-charcoal text-light rounded-3 m-2 p-2','Demographics'), x1),
                                                                     div(h4(class = 'bg-charcoal text-light rounded-3 m-2 p-2','Demographics'), mdm_rank_tds),
                                                                     div(h4(class = 'bg-charcoal text-light rounded-3 m-2 p-2','Demographics'), x2),
                                                                     
                                                                     div(h4(class = 'bg-charcoal text-light rounded-3 m-2 p-2','NI, Age Distribution'), age_pop_echarts),
                                                                     div(h4(class = 'bg-charcoal text-light rounded-3 m-2 p-2','NI, Gender Distribution'), gender_pop_echarts)
                                                                     
                                                                     
                                                                 )
                                                        )
                                               )
                                      )
                                      
                                      
                                    ),
                                    
                                    #     hatched_subtitle('Modifiable Risk'),
                                    # div(class='echarts_holder',
                                    # div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Age Alcohol Consumption'),prevalence_plot_alcohol),
                                    # div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Age Activity'),prevalence_plot_physical_activity),
                                    # div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Age Fruit and Veg intake'),prevalence_plot_fruit_veg_consumption),
                                    # div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Age BMI'),prevalence_plot_bmi_level),
                                    # div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Age Prevalence of Smoking '),prevalence_plot_cigerette_smoking)
                                    # #div(h5(class='bg-light rounded-3 m-2 p-2','Prevalence of Current Serious morbidities'),prevalence_plot_CVD_Status)
                                    #         ),
                                    
                                    ## physiological risk ----
                                    #hatched_subtitle('Physiological Risk'),
                                    #div(class='echarts_holder',
                                    #div(h4(class='bg-dark text-light rounded-3 m-2 p-2','Prevalence of Hypertension'),prevalence_plot_hypertension),
                                    #div(h4(class='bg-dark text-light rounded-3 m-2 p-2','Prevalence of Hypercholesterolemia'),prevalence_plot_high_cholosterol),
                                    #div(h4(class='bg-dark text-light rounded-3 m-2 p-2','Prevalence of Diabetes'),prevalence_plot_diabetes)
                                    #            ),
                                    #
                                    #hatched_subtitle('Trends in Disease Prevalence'),
                                    #div(class='echarts_holder',
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Cancer'),cancer_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','COPD'),copd_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Asthma'),asthma_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Depression'),depression_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Mental Health '),mental_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Atrial Fibrillation'),af_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Coronary Heart Disease'),chd_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Heart Failure 1'),hf1_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Heart Failure 3'),hf3_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Stroke '),stroke_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Chronic Kidney Disease'),ckd_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Non - Diabetic Hyperglycemia'),hypergly_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Diabetes Mellitus'),DM2_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Hypertension'),hy_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Dementia '),dementia_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Osteoporosis '),osteoporosis_plot),
                                    #    div(h4(class='bg-charcoal text-light rounded-3 m-2 p-2','Arthritis'),arthritis_plot)
                                    #)
                                    
                          ),
                          
                          # nav_panel('Statistical Foundations',icon=icon('arrow-right'),class = 'fade',
                          #           'Survival Analysis',
                          #           coming_soon()
                          #           ),
                          
                          # Model Page -----ß
                          nav_panel(icon=icon('chart-simple'),
                                    title='Model',
                                    
                                    value='model-home',
                                    HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item " ><a href="#" onclick = window.change_tab("Landing");>Home</a></li>
    <li class="breadcrumb-item active">Model</li>

  </ol>
'),
                                    
                                    div(style = 'overflow:hidden;height:30vh;display:flex;justify-content:center;align-items:end;',
                                        
                                        p(class = 'hello','View Outputs')),
                                    
                                    div( style='font-size:12px;text-align:center;overflow:hidden;height:20vh;display:flex;justify-content:center;align-items:center;',
                                         
                                         tags$ul(class='ul navbar bg-light gap-2 flex-column',
                                                 # tags$li(
                                                 #     a('Technical Appendix',
                                                 # class='landing',
                                                 # href = '#', 
                                                 # onclick = 'change_tab("Technical Appendix");return false;',
                                                 # )),
                                                 tags$li(
                                                   a('Headline Interventions',
                                                     class='landing',
                                                     href = '#', 
                                                     onclick = 'change_tab("Planned");return false;')),
                                                 tags$li(
                                                   a('Saved Runs',
                                                     class='landing',icon('hammer'),
                                                     href = '#', 
                                                     onclick = 'change_tab("Registry");return false;')),
                                                 tags$li(
                                                   a('Specify Interventions',
                                                     class='landing',
                                                     icon('up-right-from-square'),
                                                     p(class='text-muted d-inline', 'go here instead'),
                                                     href = '#', 
                                                     onclick = 'change_tab("Interactive");return false;')),
                                                 tags$li(a('Build Reports from graphics',
                                                           class='landing',icon('hammer'),
                                                           href = '#', 
                                                           onclick = 'change_tab("Report Builder");return false;')
                                                 )#,
                                                 # tags$li(a('Configurable Interventions',
                                                 #   class='landing',
                                                 #   href = '#', 
                                                 #   onclick = 'change_tab("Configurable");return false;')
                                                 # )
                                         )
                                    )
                                    
                          ) ,
                          
                          nav_panel(icon = icon('clock-rotate-left'),
                                    value = 'Model Registry',
                                    title = 'Registry',
                                    class = 'fade ',
                                    
                                    HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="  fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item" ><a href="#" onclick = window.change_tab("Landing");>Home</a></li>
    <li class="breadcrumb-item"><a href="#" onclick = window.change_tab("model-home");>Model</a></li>
    <li class="breadcrumb-item active">Model Registry</li>
  </ol>
'),
                                    
                                    tags$style('
  #model_registry .hv{margin:15px;}

  #model_registry tr {
  display:block;
  padding:15px !important;
  transition: all 0.5s ease 0.2s;
  }

  #model_registry tr:hover {
   border-radius: 10px;
  box-shadow: 4px 4px 10px #bebebe, -4px -4px 10px #ffffff;
  padding: 15px !important;
  margin-left:20px;
  transition: all 0.5s ease

                         }'),
                                    div(style = 'overflow:scroll;height:70vh;width:400px;',
                                        div(class='d-flex align-items-center justify-content-center m-5',
                                            #div(style='align-text:center;',#'display:flex;align-items:center;justify-content:center;width:70vw;height:90%;padding:30px;',
                                            DT::DTOutput('model_registry',width='100%')
                                        )
                                    )
                                    
                          ),
                          
                          # Scenarios Page ----  
                          nav_panel(icon=icon('play'),
                                    title= 'Scenarios',
                                    value='Planned',class = 'fade',
                                    HTML('  <ol class = "breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item" ><a href="#" onclick = window.change_tab("Landing");>Home</a></li>
    <li class="breadcrumb-item"><a href="#" onclick = window.change_tab("model-home");>Model</a></li>
    <li class="breadcrumb-item active">Headline Scenarios</li>
  </ol>
'),
                                    tags$head(
                                      tags$style(
                                        '#populations > div {
                                            background-color:lightgreen !important;
                                        }'
                                      )),
                                        
                                    #div(class='divider', 'Scenarios'),
                                    # div(style="display:flex; align-items: center;",
                                    #     #h1('1'),#,style="padding:0 10% 0 10%;"),
                                    # 
                                    # div(style="display:inline;border-style:solid;border-color:#CBF5DD;border-width:0px 0px 5px 0px;height:50px;width:100%;")
                                    # ),
                                    #hr(),
                                    
                                    div(style="display:flex; align-items: center;justify-content:center;",
                                        img(href = 'https://www.nice.org.uk/guidance', src = "img/NICE_logo.png",height='50px',width='100px',style ='margin-top:5px;'),
                                        strong(style='padding-left:50px;font-size:x-small;', 'This modelling mode allows observation of different modeliing approaches that best demonstrate 
                the innovation in our modelling together with its clinical relevance in population health analysis. 
                
                Drag and drop components to render existing scenarios.
                
                Scenarios have been designed to map to ',
                                               a(href = 'https://www.nice.org.uk/guidance', 'National Institute for Health and Care Excellence'),
                                               'guidelines using approved risk factor consideration, weighting and calculation')
                                    ),
                                    
                                    div(style='height:80vh;padding-top:100px;',
                                        two_tier_text_box(title = 'Scenarios',
                                                          text = 'Observe a range of predetermined, clinically validated, end to end outputs.', 
                                                          border = '#13b5cb',
                                                          onClick='document.getElementById("scroll_scenarios").scrollIntoView();'
                                        )
                                    ),
                                    
                                    ##dragAndDrop box -----
                                    fluidRow(id='scroll_scenarios',
                                             class = 'bg-body-tertiary rounded-5',
                                             style = 'padding-top:50px;height: 60%;',
                                             
                                             column(1, p('')),
                                             column(5,
                                                    
                                                    style = 'display:flex;align-items:center;flex-direction:column;text-align:center;border:solid red 5px;padding:20px;margin:20px;border-radius: 30px;',
                                                    
                                                    div(style='border: solid lightgreen 5px;border-radius:20px;width:80%;',
                                                        h5('Population'),
                                                        
                                                        orderInput('populations_dest', label='',#'Population',
                                                                   items = NULL, placeholder='',width='100%')
                                                    ),
                                                    
                                                    #hr(),
                                                    
                                                    tags$img(src = "img/down-arrow-svgrepo-com.svg", width = "79px"),# height='100px'),
                                                    
                                                    #hr(),
                                                    #div(style='border: dashed red 2px;',
                                                    
                                                    div(style='border: solid orange 5px;border-radius:20px;width:80%;',
                                                        
                                                        h5('Interventions'),
                                                        
                                                        orderInput('interventions_dest', label='',#'Intervention', 
                                                                   items = NULL, placeholder='',width='100%')
                                                        
                                                    ),
                                                    
                                                    #hr(),
                                                    
                                                    tags$img(src = "img/down-arrow-svgrepo-com.svg", width = "79px"),
                                                    
                                                    #hr(), 
                                                    #div(style='border: dashed red 2px;',
                                                    
                                                    div(style='border: solid red 5px;border-radius:20px;width:80%;',
                                                        
                                                        h5('Use Case'),
                                                        
                                                        orderInput('use_case_dest', label = '',# 'Use Case',
                                                                   items = NULL, placeholder='',width='100%')
                                                    ),
                                                    
                                                    hr()
                                                    
                                             ),
                                             
                                             column(3, offset=1, #s
                                                    #style = 'text-align:center',
                                                    
                                                    h4('Build your population model'),
                                                    
                                                    div(style='height:30px'),
                                                    
                                                    #populations
                                                    
                                                    orderInput('populations', 
                                                               'Populations',
                                                               items = c('NI'), 
                                                               item_class='success',
                                                               as_source = TRUE, 
                                                               connect = 'populations_dest'),

                                                    
                                                    div(style='height:60px'),
                                                    
                                                    #interventions  width = '100px', 
                                                    orderInput('interventions', 'Interventions', items = intervention_list, item_class='warning',
                                                               as_source = TRUE, connect = 'interventions_dest'),
                                                    
                                                    div(style='height:60px'),
                                                    
                                                    orderInput('use_case', 'Use Case', items = c('CVD'), item_class='danger',
                                                               as_source = TRUE, connect = 'use_case_dest'),
                                                    
                                                    div(style='height:50px'),
                                                    
                                                    actionButton(class='btn-info',inputId = 'run1',label = 'Run Scenario')
                                                    
                                                    ##outputs-----
                                             )
                                    ),
                                    
                                    div(id='outputs',style='margin-top:100px;',
                                        
                                        HTML('<link  rel="stylesheet" href = css/changing_words.css />'),
                                        
                                        
                                        
                                        
                                        
                                        div(style='width:350px;',
                                            # div(
                                            #   sm_hatched_subtitle('Costs of AF Intervention')
                                            # ),
                                            
                                            div(class = "fixed-pane",
                                                style='width:300px;padding:20px;background-color:rgb(50,104,126);
           color:white !important;border-color:white !important;',
                                                
                                                cost_component(),
                                                div(style = 'height:250px;width:250px;margin-block:10px;color:inherit !imporant;',
                                                    circular_value('10,212')
                                                )
                                            )
                                        ),
                                        # div( class = 'mx-5',
                                        #   sm_hatched_subtitle(' Assumptions')
                                        # ),
                                        div(style = 'display:flex;flex-direction:row;justify-content:center;flex-wrap:wrap;',
                                            declare_box('Discounting Rate', '3.5 %',background = 'transparent',color='rgb(40,40,40)'),
                                            declare_box('Post Stroke Utility', 0.5,background = 'transparent',color='rgb(40,40,40)'),
                                            declare_box('Screening cost', '£5',background = 'transparent',color='rgb(40,40,40)'),
                                            declare_box('Prescription Costs','£ 80','per person per year',background = 'transparent',color='rgb(40,40,40)'),

                                            declare_box('Cost of a Stroke','£ 48,000','First Year',background = 'transparent',color='rgb(40,40,40)'),
                                            declare_box('Cost of a Stroke','£ 24,000', 'Subsequent Cost',  background = 'transparent',color='rgb(40,40,40)'),

                                            #declare_box('Average normal LE of Stroke victims',background='rgb(85,172,189)', '8 years'),
                                            #declare_box('Average LE wo Stroke', '20 years',background='rgb(85,172,189)',second='model')
                                            
                                            declare_box('LE after Stroke',background='transparent', '8 years',color='rgb(40,40,40)'),
                                            declare_box('Avg. LE w/o Stroke', '20 years',background='transparent',color='rgb(40,40,40)')
                                        ), 
                                        
                                        
                                        div(style = ' display: flex;
  flex-direction: row;
  gap:1rem;
  justify-content: center; /* Horizontally centres the image*/
  align-items: center; /* Vertically centres the image*/', 
                                            #img(src = 'img/AF_epi_plot.png',height='535px'),
                                            div(style = 'width:300px;',
                                                sm_hatched_subtitle('Plot of Stroke Instances subject to AF'),
                                                af_stroke_output_agg_plot
                                            ),
                                            div(style = 'width:300px;',
                                                sm_hatched_subtitle('Delta in Stroke Instances subject to AF'),
                                                af_stroke_output_delta
                                            )
                                            
                                        ),
                                        
                                        div(style = 'text-align:right;margin-top:40px;',
                                            tags$style('wrapper {
                                              background: linear-gradient(90deg ,rgba(142, 68, 173,0.3),white);
                                                                          padding-inline: 10px;
                                                                          border-radius: 15px;
                                                                          }'),
                                            changing_words()
                                        )#,
                                        
                                        #   h4('Target attributes of the Intervention and their time prevalence in the population'),
                                        #   plotOutput('graph_risk_factors'),
                                        #   h4('The population 10 year probability of a serious CVD event including Stroke or CHD'),
                                        #   plotOutput('graph_health_outcomes'),
                                        #   hr(),
                                        #   
                                        # layout_column_wrap( width = "250px",
                                        #     fill = FALSE,
                                        #    value_box(
                                        #     title = "Cost of Stroke per person",
                                        #     value = "£45,409 ",
                                        #     showcase = bs_icon("bar-chart"),
                                        #     theme  = "lightgreen",
                                        #     shiny::tags$a(target = '_blank', href = "https://www.stroke.org.uk/sites/default/files/costs_of_stroke_in_the_uk_report_-executive_summary_part_2.pdf",
                                        #                   "https://www.stroke.org.uk/sites/default/files/costs_of_stroke_in_the_uk_report_-executive_summary_part_2.pdf")
                                        #   ),
                                        #   
                                        #   value_box(width='200px',
                                        #     title = "Cost of Statin Prescription for prevention for a year",
                                        #     value = "£1000",
                                        #     showcase = bs_icon("graph-up"),
                                        #     theme_color  = "mediumseagreen",
                                        #     shiny::tags$a(target = '_blank', "https://www.leedsformulary.nhs.uk/docs/2.12statincosts.pdf",
                                        #                   href = "https://www.leedsformulary.nhs.uk/docs/2.12statincosts.pdf")
                                        #   )
                                        #   )
                                    )
                          ),
      
      
      
      # Population page ----
      nav_panel(title = HTML( '<b style="font-weight: bold;
                          font-size: x-small;">NI</b> 
                                                  Population '),
                value = 'population',
                #div(class='divider','Overview'),
                class = 'fade m-3',
                #https://stackoverflow.com/questions/4907843/open-a-url-in-a-new-tab-and-not-a-new-window
                
                HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item "><a href="#" onclick = window.change_tab("info-home");>Info</a></li>
    <li class="breadcrumb-item  active">Northern Irelands Population</li>
  </ol>
'),
                HTML('<div id="wdr-component"></div>
                  <head>
                  <link href="https://cdn.webdatarocks.com/latest/webdatarocks.min.css" rel="stylesheet"/>
                  <script src="https://cdn.webdatarocks.com/latest/webdatarocks.toolbar.min.js"></script>
                  <script src="https://cdn.webdatarocks.com/latest/webdatarocks.js"></script>
                  </head>
                  </body>'),
                
                tags$head(tags$script(src = 'js/webdatarocks_pivot_table.js'))
                
                ),
      # Fertility page  ----
      nav_panel(title = HTML( '<b style="font-weight: bold;
                          font-size: x-small;">Births</b> 
                                                  Fertility, Deaths '),
                value = 'births',
                #div(class='divider','Overview'),
                class = 'fade m-3',
                #https://stackoverflow.com/questions/4907843/open-a-url-in-a-new-tab-and-not-a-new-window
                
                HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item "><a href="#" onclick = window.change_tab("info-home");>Info</a></li>
    <li class="breadcrumb-item  active">Population Changes</li>
  </ol>
'),


  
  # Container for the pivot table
  div(id = "wdr-component"),
  
  # Include your custom JavaScript
  tags$script(src = "js/webdatarocks_pivot_table.js")



),
      # Risk page ----
      nav_panel(title = HTML( '<b style="font-weight: bold;
                          font-size: x-small;">Risk </b>Changes 
                                                  '),
                value = 'births',
                #div(class='divider','Overview'),
                class = 'fade m-3',
                #https://stackoverflow.com/questions/4907843/open-a-url-in-a-new-tab-and-not-a-new-window
                
                HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item "><a href="#" onclick = window.change_tab("info-home");>Info</a></li>
    <li class="breadcrumb-item  active">Risk Changes</li>
  </ol>
')),
      
      nav_panel(title = HTML( '<<i class="fa-solid fa-vial-circle-check"></i> <b style="font-weight: bold;
                          font-size: x-small;"></b> 
                                                  Screening'),
                value = 'bowel_screening',
                #div(class='divider','Overview'),
                class = 'fade m-3',
                #https://stackoverflow.com/questions/4907843/open-a-url-in-a-new-tab-and-not-a-new-window
                
                HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item "><a href="#" onclick = window.change_tab("info-home");>Info</a></li>
    <li class="breadcrumb-item  active">Bowel Screening Age Extension</li>
  </ol>
'),
                
                
               div(class='d-flex', funnel, 
                sankey)
                
                ),
      
                          # SPPG results ----
                          nav_panel(title = HTML( '<b style="font-weight: bold;
                          font-size: x-small;">DoH</b> 
                                                  Baseline '),
                                    value = 'baseline_results',
                                    #div(class='divider','Overview'),
                                    class = 'fade m-3',
                                    #https://stackoverflow.com/questions/4907843/open-a-url-in-a-new-tab-and-not-a-new-window
                                    
                                    HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item "><a href="#" onclick = window.change_tab("info-home");>Info</a></li>
    <li class="breadcrumb-item  active">Baseline Results</li>
  </ol>
'),
                                      tags$head(
                                        tags$style(HTML("
  
      #scrollspy-nav i {
  /*
  color: grey;         
  Change icon color */
      }
      
      #scrollspy-content h5 {
  color: dimgrey;         /* Change icon color */
  margin-left:1rem;

      }
      
           #intro h5 >h5 {
  color: dimgrey;         /* Change icon color */
  margin-left:2rem;

           }
      
                 #intro p {
  color: dimgrey;         /* Change icon color */
  margin-left:2rem;

      }

      #scrollspy-nav {
      
        border-radius:15px;
        /*
        position: fixed;
        top: 15vh;
        right: 10px;
        width: 80px;
        */
      }
      
      #scrollspy-content {
        margin-left: 50px;
        /*height: 6000px;*/
        overflow-y: scroll;
        position: relative;
      }
      
      .section {
        height: 400px;
        padding-top: 60px;
      }
    "))
                                      ),
                                    
                                    # HTML('
                                    # <div class="row">
                                    #   <div class="col-4">
                                    #   <nav id="scrollspy-nav" class="h-20 flex-column align-items-stretch pe-4 border-end">
                                    #   <nav class="nav nav-pills flex-column">
                                    #   <a class="nav-link" href="#item-1">Item 1</a>
                                    #   <nav class="nav flex-column">
                                    #   <a class="nav-link ms-3 my-1" href="#item-1-1">Item 1-1</a>
                                    #   <a class="nav-link ms-3 my-1" href="#item-1-2">Item 1-2</a>
                                    #   </nav>
                                    #   <a class="nav-link" href="#item-2">Item 2</a>
                                    #   <a class="nav-link" href="#item-3">Item 3</a>
                                    #   <nav class="nav nav-pills flex-column">
                                    #   <a class="nav-link ms-3 my-1" href="#item-3-1">Item 3-1</a>
                                    #   <a class="nav-link ms-3 my-1" href="#item-3-2">Item 3-2</a>
                                    #   </nav>
                                    #   </nav>
                                    #   </nav>
                                    #   </div>
                                    # 
                                    #   <div class="col-8">
                                    #   <div data-bs-spy="scroll" data-bs-target="#scrollspy-nav" data-bs-smooth-scroll="true" class="scrollspy-example-2" tabindex="0">
                                    #   <div id="item-1">
                                    #   <h4>Item 1</h4>
                                    #   <p>This is some placeholder content for the scrollspy page. Note that as you scroll down the page, the appropriate navigation link is highlighted. It’s repeated throughout the component example. We keep adding some more example copy here to emphasize the scrolling and highlighting.  Keep in mind that the JavaScript plugin tries to pick the right element among all that may be visible. Multiple visible scrollspy targets at the same time may cause some issues.</p>
                                    #   </div>
                                    #   <div id="item-1-1">
                                    #   <h5>Item 1-1</h5>
                                    #   <p>This is some placeholder content for the scrollspy page. Note that as you scroll down the page, the appropriate navigation link is highlighted. It’s repeated throughout the component example. We keep adding some more example copy here to emphasize the scrolling and highlighting.  Keep in mind that the JavaScript plugin tries to pick the right element among all that may be visible. Multiple visible scrollspy targets at the same time may cause some issues.</p>
                                    #   </div>
                                    #   <div id="item-1-2">
                                    #   <h5>Item 1-2</h5>
                                    #   <p>This is some placeholder content for the scrollspy page. Note that as you scroll down the page, the appropriate navigation link is highlighted. It’s repeated throughout the component example. We keep adding some more example copy here to emphasize the scrolling and highlighting.  Keep in mind that the JavaScript plugin tries to pick the right element among all that may be visible. Multiple visible scrollspy targets at the same time may cause some issues.</p>
                                    #   </div>
                                    #   <div id="item-2">
                                    #   <h4>Item 2</h4>
                                    #   <p>This is some placeholder content for the scrollspy page. Note that as you scroll down the page, the appropriate navigation link is highlighted. It’s repeated throughout the component example. We keep adding some more example copy here to emphasize the scrolling and highlighting.  Keep in mind that the JavaScript plugin tries to pick the right element among all that may be visible. Multiple visible scrollspy targets at the same time may cause some issues.</p>
                                    #   </div>
                                    #   <div id="item-3">
                                    #   <h4>Item 3</h4>
                                    #   <p>This is some placeholder content for the scrollspy page. Note that as you scroll down the page, the appropriate navigation link is highlighted. It’s repeated throughout the component example. We keep adding some more example copy here to emphasize the scrolling and highlighting.  Keep in mind that the JavaScript plugin tries to pick the right element among all that may be visible. Multiple visible scrollspy targets at the same time may cause some issues.</p>
                                    #   </div>
                                    #   <div id="item-3-1">
                                    #   <h5>Item 3-1</h5>
                                    #   <p>This is some placeholder content for the scrollspy page. Note that as you scroll down the page, the appropriate navigation link is highlighted. It’s repeated throughout the component example. We keep adding some more example copy here to emphasize the scrolling and highlighting.  Keep in mind that the JavaScript plugin tries to pick the right element among all that may be visible. Multiple visible scrollspy targets at the same time may cause some issues.</p>
                                    #   </div>
                                    #   <div id="item-3-2">
                                    #   <h5>Item 3-2</h5>
                                    #   <p>This is some placeholder content for the scrollspy page. Note that as you scroll down the page, the appropriate navigation link is highlighted. It’s repeated throughout the component example. We keep adding some more example copy here to emphasize the scrolling and highlighting.  Keep in mind that the JavaScript plugin tries to pick the right element among all that may be visible. Multiple visible scrollspy targets at the same time may cause some issues.</p>
                                    #   </div>
                                    #   </div>
                                    #   </div>
                                    #   </div>'),
                                    tags$head(
                                      tags$script(
                                        "// Re-initialize ScrollSpy every time a tab is shown
                                        document.addEventListener('shown.bs.tab', function (event) {
                                          const scrollSpy = bootstrap.ScrollSpy.getInstance(document.body);
                                          if (scrollSpy) {
                                            //scrollSpy.refresh();
                                          } else {
                                          console.log('1');
                                            new bootstrap.ScrollSpy(document.body, {
                                              target: '#scrollspy-nav',
                                              offset: 0
                                            });
                                          }
                                        });"
                                      )),
                                      
                                      # Scrollspy Nav

                                     div( class="row",
                                      div( class="col-2",
                                    tags$nav(
                                      id = "scrollspy-nav",
                                      class = "nav flex-column align-items-stretch nav-pills border-end bg-body-tertiary",
                                      `data-bs-spy` = "scroll",
                                      `data-bs-target` = "#scrollspy-nav",
                                      `data-bs-offset` = "0",
                                      tabindex = "0",


                                      tags$a(class = "nav-link active", href = "#intro", "Intro", `data-value` = "interactive"),

                                      tags$a(class = "nav-link", href = "#stroke", "Stroke", `data-value` = "interactive"),

                                      tags$div(class = "nav flex-row ms-3 my-1",
                                               tags$a(class = "nav-link", href = "#stroke_age", icon('person-cane'), `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#stroke_sex", icon('venus-mars'), `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#stroke_trust", icon('globe'), `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#stroke_MDMquintile", icon('comments-dollar'), `data-value` = "interactive")
                                      ),

                                      tags$a(class = "nav-link", href = "#section2", "Atrial Fibrillation", `data-value` = "interactive"),
                                      tags$div(class = "nav flex-row ms-3 my-1",
                                               tags$a(class = "nav-link", href = "#atrial_fibrillation_age", "Age", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#atrial_fibrillation_sex", "Sex", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#atrial_fibrillation_trust", "Trust", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#atrial_fibrillation_MDMquintile", "MDM", `data-value` = "interactive")
                                      ),

                                      tags$a(class = "nav-link", href = "#section3", "Hypertension", `data-value` = "interactive"),
                                      tags$div(class = "nav flex-row ms-3 my-1",
                                               tags$a(class = "nav-link", href = "#hypertension_age", "Age", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#hypertension_sex", "Sex", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#hypertension_trust", "Trust", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#hypertension_MDMquintile", "MDM", `data-value` = "interactive")
                                      ),

                                      tags$a(class = "nav-link", href = "#section4", "CHD", `data-value` = "interactive"),
                                      tags$div(class = "nav flex-row ms-3 my-1",
                                               tags$a(class = "nav-link", href = "#chd_age", "Age", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#chd_sex", "Sex", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#chd_trust", "Trust", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#chd_MDMquintile", "MDM", `data-value` = "interactive")
                                      ),

                                      tags$a(class = "nav-link", href = "#section5", "CKD", `data-value` = "interactive"),
                                      tags$div(class = "nav flex-row ms-3 my-1",
                                               tags$a(class = "nav-link", href = "#ckd_age", "Age", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#ckd_sex", "Sex", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#ckd_trust", "Trust", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#ckd_MDMquintile", "MDM", `data-value` = "interactive")
                                      ),

                                      tags$a(class = "nav-link", href = "#section6", "Diabetes", `data-value` = "interactive"),
                                      tags$div(class = "nav flex-row ms-3 my-1",
                                               tags$a(class = "nav-link", href = "#diabetes_age", "Age", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#diabetes_sex", "Sex", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#diabetes_trust", "Trust", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#diabetes_MDMquintile", "MDM", `data-value` = "interactive")
                                      ),

                                      tags$a(class = "nav-link", href = "#section7", "Heart Failure", `data-value` = "interactive"),
                                      tags$div(class = "nav flex-row ms-3 my-1",
                                               tags$a(class = "nav-link", href = "#heart_failure_age", "Age", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#heart_failure_sex", "Sex", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#heart_failure_trust", "Trust", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#heart_failure_MDMquintile", "MDM", `data-value` = "interactive")
                                      ),

                                      tags$a(class = "nav-link", href = "#section8", "Dementia", `data-value` = "interactive"),
                                      tags$div(class = "nav flex-row ms-3 my-1",
                                               tags$a(class = "nav-link", href = "#dementia_age", "Age", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#dementia_sex", "Sex", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#dementia_trust", "Trust", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#dementia_MDMquintile", "MDM", `data-value` = "interactive")
                                      ),

                                      tags$a(class = "nav-link", href = "#section9", "Cancer", `data-value` = "interactive"),
                                      tags$div(class = "nav flex-row ms-3 my-1",
                                               tags$a(class = "nav-link", href = "#cancer_age", "Age", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#cancer_sex", "Sex", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#cancer_trust", "Trust", `data-value` = "interactive"),
                                               tags$a(class = "nav-link", href = "#cancer_MDMquintile", "MDM", `data-value` = "interactive")
                                      )
                                    )
                                    ),

# 
                                    div(class = 'col-9',
# 
                                    # Scrollspy content container — requires height and overflow
                                    div(
                                      id = "scrollspy-content",
                                      `data-bs-spy` = "scroll",
                                      `data-bs-target` = "#scrollspy-nav",
                                      #`data-bs-offset` = "0",
                                      #tabindex = "0",
                                      style = "position: relative; overflow-y: auto; scroll-behavior: smooth;", # height: 100vh;

                                      tags$div( id = "intro",
                                                h4('QoF definitions'),
                                                tags$div(id = "item-1",
                                                         tags$h5("Stroke and Transient Ischaemic Attack (TIA)"),
                                                         tags$p("Number of patients with stroke or transient ischaemic attack (TIA).")
                                                ),

                                                tags$div(id = "item-2",
                                                         tags$h5("Atrial Fibrillation"),
                                                         tags$p("Number of patients with atrial fibrillation.")
                                                ),

                                                tags$div(id = "item-3",
                                                         tags$h5("Hypertension"),
                                                         tags$p("Number of patients with established hypertension.")
                                                ),

                                                tags$div(id = "item-4",
                                                         tags$h5("Coronary Heart Disease"),
                                                         tags$p("Number of patients with coronary heart disease.")
                                                ),

                                                tags$div(id = "item-5",
                                                         tags$h5("Chronic Kidney Disease"),
                                                         tags$p("Number of patients aged 18 years and over with chronic kidney disease (US National Kidney Foundation: Stage 3 to 5 CKD)."),
                                                         tags$div(id = "item-5-1",
                                                                 # tags$h5("Note 1"),
                                                                  tags$p("Inclusion in the register is based on estimated Glomerular Filtration Rate (eGFR), a measure of kidney function. People with CKD stages 3 to 5 have, by definition, less than 60% of their kidney function.")
                                                         ),
                                                         tags$div(id = "item-5-2",
                                                                 # tags$h5("Note 2"),
                                                                  tags$p("This register was removed from the QOF from 2014/15.")
                                                         ),
                                                         tags$div(id = "item-5-3",
                                                                  #tags$h5("Note 3"),
                                                                  tags$p("The CKD register was re-introduced in the QOF from 2022/23; the definition is consistent with the previous register.")
                                                         ),
                                                         tags$div(id = "item-5-4",
                                                                  #tags$h5("Note 4"),
                                                                  tags$p("Number of patients aged 18 or over with CKD with classification of categories G3a to G5 (previously stage 3 to 5).")
                                                         ),
                                                         tags$div(id = "item-5-5",
                                                                  #tags$h5("Note 5"),
                                                                  tags$p("This disease area applies to patients with category G3a, G3b, G4 and G5 CKD (eGFR<60 mL/min/1.73 m² confirmed with at least two separate readings over a three month period).")
                                                         ),
                                                         tags$div(id = "item-5-6",
                                                                  #tags$h5("Note 6"),
                                                                  tags$p("Patients with CKD stage G3 (eGFR 30-59 ml/min/1.73m2) have impaired kidney function. These patients can be further subdivided based on their eGFR as follows:\nCKD stage G3a: eGFR 45-59 ml/min/1.73m2\nCKD stage G3b: eGFR 30-44 ml/min/1.73m2")
                                                         )
                                                ),

                                                tags$div(id = "item-6",
                                                         tags$h5("Cancer"),
                                                         tags$p("Number of patients with a diagnosis of cancer, excluding non-melanotic skin cancers, from 1st April 2003."),
                                                         tags$div(id = "item-6-1",
                                                                  tags$h5("Cancer - Note 1"),
                                                                  tags$p("Because of the date cut-off in the definition of this register, prevalence trends are obscured by the increase in the size of the register due to the cumulative accrual of new cancer cases onto practice registers with each passing year.")
                                                         )
                                                ),

                                                tags$div(id = "item-7",
                                                         tags$h5("Chronic Obstructive Pulmonary Disease (COPD)"),
                                                         tags$p("Number of patients with chronic obstructive pulmonary disease."),
                                                         tags$div(id = "item-7-1",
                                                                 # tags$h5("Note 1"),
                                                                  tags$p("For 2004/05 and 2005/06 QOF definitions did not allow patients to be on both asthma and COPD registers thus patients with a degree of reversible airway disease were not included on the COPD register. From 2006/07 the rules were revised to allow patients to be included on both COPD and asthma registers. Approximately 15% of patients with COPD will also have asthma. Any comparisons of COPD prevalence before and after this change in definition should be made with caution.")
                                                         )
                                                ),

                                                tags$div(id = "item-8",
                                                         tags$h5("Diabetes Mellitus"),
                                                         tags$p("Number of patients aged 17 years and over with diabetes mellitus (specified as type 1 or type 2 diabetes)."),
                                                         tags$div(id = "item-8-1",
                                                                #  tags$h5("Note 1"),
                                                                  tags$p("Since April 2006, the definition includes all patients aged 17 years and over with diabetes mellitus defined by clinical (Read) codes specific to Type 1 or Type 2 diabetes. Previously there was a wider range of codes accepted under the definition, although the age constraint has remained consistent. The prevalence statistics for 2006/07 onwards are therefore not directly comparable with those for 2004/05 and 2005/06.")
                                                         ),
                                                         tags$div(id = "item-8-2",
                                                               #   tags$h5("Note 2"),
                                                                  tags$p("Although the practice must record whether the patient has Type 1 or Type 2 diabetes, this level of detail is not collected centrally, therefore the register size cannot be disaggregated by type of diabetes.")
                                                         )
                                                ),

                                                tags$div(id = "item-9",
                                                         tags$h5("Dementia"),
                                                         tags$p("Number of patients diagnosed with dementia."),
                                                         tags$div(id = "item-9-1",
                                                                  # tags$h5("Note 1"),
                                                                  tags$p("This indicator applies to all people diagnosed with dementia either directly by the GP or through referral to secondary care.")
                                                         )
                                                )
),

                                      # Stroke Section,
                                      
# 
# 
                                      div(id = "stroke", class = "pt-5", h2("Stroke")),
                                      div(tbl, style = 'overflow:visible;width:1000px;padding-top:100px;padding-bottom:50px;z-index:10000000;'),
                                      div(id = "stroke_age", class = "pt-5", h4("Age")),
                                      stroke_age20,
                                      div(id = "stroke_sex", class = "pt-5", h4("Sex")),
                                      stroke_sex,
                                      div(id = "stroke_trust", class = "pt-5", h4("Trust")),
                                      stroke_HSCT,
                                      div(id = "stroke_MDMquintile", class = "pt-5", h4("MDM Quintile")),
                                      stroke_mdm_quintile,
# 
                                      div(id = "atrial_fibrillation", class = "pt-5", h2("Atrial Fibrillation")),
                                      div(id = "atrial_fibrillation_age", class = "pt-5", h4("Age")),
                                      atrial_fibrillation_age20,
                                      div(id = "atrial_fibrillation_sex", class = "pt-5", h4("Sex")),
                                      atrial_fibrillation_sex,
                                      div(id = "atrial_fibrillation_trust", class = "pt-5", h4("Trust")),
                                      atrial_fibrillation_HSCT,
                                      div(id = "atrial_fibrillation_MDMquintile", class = "pt-5", h4("MDM Quintile")),
                                      atrial_fibrillation_mdm_quintile,

                                      div(id = "hypertension", class = "pt-5", h2("Hypertension")),
                                      div(id = "hypertension_age", class = "pt-5", h4("Age")),
                                      hypertension_age20,
                                      div(id = "hypertension_sex", class = "pt-5", h4("Sex")),
                                      hypertension_sex,
                                      div(id = "hypertension_trust", class = "pt-5", h4("Trust")),
                                      hypertension_HSCT,
                                      div(id = "hypertension_MDMquintile", class = "pt-5", h4("MDM Quintile")),
                                      hypertension_mdm_quintile,

                                      div(id = "chd", class = "pt-5", h2("Coronary Heart Disease")),
                                      div(id = "chd_age", class = "pt-5", h4("Age")),
                                      chd_age20,
                                      div(id = "chd_sex", class = "pt-5", h4("Sex")),
                                      chd_sex,
                                      div(id = "chd_trust", class = "pt-5", h4("Trust")),
                                      chd_HSCT,
                                      div(id = "chd_MDMquintile", class = "pt-5", h4("MDM Quintile")),
                                      chd_mdm_quintile,

                                      div(id = "ckd", class = "pt-5", h2("Chronic Kidney Disease")),
                                      div(id = "ckd_age", class = "pt-5", h4("Age")),
                                      chronic_kidney_disease_age20,
                                      div(id = "ckd_sex", class = "pt-5", h4("Sex")),
                                      chronic_kidney_disease_sex,
                                      div(id = "ckd_trust", class = "pt-5", h4("Trust")),
                                      chronic_kidney_disease_HSCT,
                                      div(id = "ckd_MDMquintile", class = "pt-5", h4("MDM Quintile")),
                                      chronic_kidney_disease_mdm_quintile,

                                      div(id = "cancer", class = "pt-5", h2("Cancer")),
                                      div(id = "cancer_age", class = "pt-5", h4("Age")),
                                      lung_cancer_age20,
                                      div(id = "cancer_sex", class = "pt-5", h4("Sex")),
                                      lung_cancer_sex,
                                      div(id = "cancer_trust", class = "pt-5", h4("Trust")),
                                      lung_cancer_HSCT,
                                      div(id = "cancer_MDMquintile", class = "pt-5", h4("MDM Quintile")),
                                      lung_cancer_mdm_quintile,

                                      div(id = "diabetes", class = "pt-5", h2("Diabetes")),
                                      div(id = "diabetes_age", class = "pt-5", h4("Age")),
                                      diabetes_age20,
                                      div(id = "diabetes_sex", class = "pt-5", h4("Sex")),
                                      diabetes_sex,
                                      div(id = "diabetes_trust", class = "pt-5", h4("Trust")),
                                      diabetes_HSCT,
                                      div(id = "diabetes_MDMquintile", class = "pt-5", h4("MDM Quintile")),
                                      diabetes_mdm_quintile,

                                      div(id = "dementia", class = "pt-5", h2("Dementia")),
                                      div(id = "dementia_age", class = "pt-5", h4("Age")),
                                      dementia_age20,
                                      div(id = "dementia_sex", class = "pt-5", h4("Sex")),
                                      dementia_sex,
                                      div(id = "dementia_trust", class = "pt-5", h4("Trust")),
                                      dementia_HSCT,
                                      div(id = "dementia_MDMquintile", class = "pt-5", h4("MDM Quintile")),
                                      dementia_mdm_quintile,

                                      div(id = "outro", class = "pt-5", h2("Notes")),
# 
                                    )
# 
                                      ) #col

                                    ) #row

                                    
                                    
                                    
                                    
                                    
                                    ),
                                    
                          #  Interactive Scenarios Page----
                          
                          nav_panel(icon=icon('sliders'),
                                    title='Interactive',
                                    value = "interactive", 
                                    class = 'fade',
                                    
                                    HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
    <li class="breadcrumb-item fa-home fa" ><a href="#" onclick = window.change_tab("Landing");></a></li>
    <li class="breadcrumb-item fa-home" ><a href="#" onclick = window.change_tab("Landing");>Home</a></li>
    <li class="breadcrumb-item"><a href="#" onclick = window.change_tab("model-home");>Model</a></li>
     <li class="breadcrumb-item active" style="float:right;">Specify Scenarios</li>
  </ol>
'),
                                    HTML('    <li class="breadcrumb-item fa active" style="float:right;">Specify Scenarios</li>'),
                                    
                                    style='height:80vw;',
                                    
                                    div(style="display:flex; align-items: center;",
                                        
                                        #h1('2'),#,style="padding:0 10% 0 10%;"),
                                        
                                        div(style="display:inline;border-style:solid;border-color:#FFd580;border-width:0px 0px 5px 0px;height:50px;width:100%;border-radius;10px;")),
                                    # hr(),
                                    div(class = 'm-2 p-1', style = 'display: flex; align-items: center; justify-content:space-between;',
                                        #div(style = 'display: flex; align-items: center; justify-content:space-around;flex-direction:column;',
                                        #img(src ='fill-blue-500x398.webp',height='80px'),
                                        icon('staff-snake', style='fill:navy;color:#FFd580;font-size:large;padding-top:10px'),
                                        #a('How to Use?',style = 'width:100px;text-align:center;')),
                                        strong(id='para2',style= 'padding-top:-30px;padding-left:50px; padding-right: 50px;', 
                                               'This modelling mode allows interactive specification of scenarios and their modelling outcomes.
                Drag and drop data points to rerender expected prevalence curves corresponding to different interactive scenarios. '
                                        )
                                        
                                    ),
                                    br(),
                                    fluidRow(
                                    
                                      
                                      #first column  ----
                                      column(3,offset=0,
                                             
                                             selectInputWithIcons(
                                               "select_disease",
                                               "isease:",
                                               labels    = c("Stroke", "Coronary Heart Disease"),
                                               values    = c("stroke" ,'CHD'),
                                               icons     = list( c("smoking", "burger",'utensils',"weight", "wine-glass"),
                                                                 c("smoking", "burger",'utensils',"weight", "wine-glass")),
                                               iconStyle = "font-size: 3rem; vertical-align: middle;",
                                               selected  = NULL
                                             ),
                                             
                                             
                                               
                                               selectInputWithIcons(
                                                 "select_risk",
                                                 "Risk",
                                                 labels    = c("smoking", "alcohol",'utensils','diet','BMI'),
                                                 values    = c("smoking", "alcohol",'utensils','diet','bmi'),
                                                 icons     =  list(c("smoking", "burger",'utensils',"weight", "wine-glass")),
                                                                  ,
                                                 iconStyle = "font-size: 3rem; vertical-align: middle;",
                                                 selected  = NULL
                                               ),
                                             
                                             
                                             ##first column first block
                                             div( style= 'border:solid lightgreen 3px; border-radius:10px;', #"margin:20px;box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px;",
                                                  # icon('computer-mouse',style='float:right;padding:15px;'),
                                                  h5(style = "padding:20px;",'Input for base multiplier on incidence of disease'),
                                                  
                                                  div(id='scatterPlotContainer',
                                                      icon('computer-mouse',style='float:right;margin:5px;'),
                                                      div(id = "scatterPlot", style = "width: 95%; height: 90%;")
                                                  ),
                                                  
                                                  div( style= 'border:solid white 3px; border-radius:10px;margin:10px', 
                                                       
                                                       h5(style = "padding:15px;",'Output for base multiplier on incidence of disease'),
                                                       
                                                       echarts4rOutput('prevalence_input_multiplier',height = '100%')
                                                  )
                                             ),
                                             
                                             tags$button('Submit', onclick = 'Shiny.setInputValue("show2",Math.random());return false;', inputId = 'submit',label = 'Submit', class='neumorphic', width ='100%'),
                                             
                                             # div(style= 'height:500px;margin-top:30px;border:solid lightgreen 3px; border-radius:10px;',
                                             #     
                                             #     h5(style = "padding:20px;",'Prevalence Over Time')
                                             # ),
                                             
                                             div(style= 'margin-top:30px;border:solid lightgreen 3px;padding:20px; border-radius:10px;',
                                                 
                                                 #h5(style = "padding:10px;",'Prevalence Over Deprivation')
                                                 div(class='indent',h3('Prevention'),
                                                     p(style = 'padding:15px;','The rates of incidence are diminished. Less people suffer onset.'),
                                                     img(src="img/svg/prevention.svg", style="float:right;width: 50px; height: auto;", alt="SVG icon")
                                                 ),
                                                 br(),
                                                 div(class='indent',h3('Remission'),
                                                     p(style = 'padding:15px;','The disease or risk factor is mitigated to an extent, or symptoms managed, such that they are nearly or totally gone.'),
                                                 img(src="img/svg/remission.svg", style="float:right;width: 50px; height: auto;", alt="SVG icon")
                                                     ),
                                                 
                                                 br(),
                                                 div(class='indent',
                                                     h3('Mitigation'),
                                                     p(style = 'padding:15px;','Managing the burden of disease and preventing complications, while still suffering. Prevents, more serious, acute or chronic cardiovascular disease'),
                                                     img(src="img/svg/migration.svg", style="float:right;width: 50px; height: auto;", alt="SVG icon")
                                                     
                                                 )
                                             )
                                      ),
                                      column(4, 
                                             div(style= 'border:solid lightgreen 3px; border-radius:10px;',#style="box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px;",#"box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px;",#style='margin-top:-50px;',
                                                 # h5(style = "z-index:100;padding:30px;position:absolute;top:10px;",
                                                 #    'Directed Graph of Cascading Influence'),
                                                 icon('computer-mouse',style='float:right;margin:10px;'),
                                                 tags$a(href = '#', 
                                                        target = '_blank',
                                                        onclick = 'Shiny.setInputValue("show1",Math.random());return false;',
                                                        icon('up-right-and-down-left-from-center'),
                                                        style='float:right;margin:10px;'),
                                                 
                                                 visNetworkOutput('network'),
                                                 
                                                 p(style = "margin:0px; padding:15px; width:100%; border: solid white 3px; border-radius: 9px; background-color:#FFd580; color:rgb(45,45,45);",
                                                   'The causal graph of factors influence on each other and subsequent sway on health outcomes.
                  Changing any of of these parameters will affect downstream health outcomes. Demographics are relatively fixed.
                  But physiological life attributes can be mediated by medication and or will be influenced by
                  positive behavioural lifestyles.')
                                             ),
                                             
                 #                             div(style= 'height:500px;margin-top:30px;border:solid lightgreen 3px; border-radius:10px;',#style="box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px;",#"box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px;",#style='margin-top:-50px;',
                 #                                 #h5(style = "padding:10px;",'Evidence'),
                 #                                 #h5(style = "padding:10px;",'Background'),
                 #                                 #h5(style = "padding:10px;",'References')
                 #                                 h5( style = "padding:20px;", 'Cardiovascular disease is going down, but remains the biggest killer in the world.
                 # In the UK it is the second biggest killer, after neurodegenerative diseases Alzheimers and dementia'),
                 #                             )
                                      ),
                                      column(3,
                                           #  div(style= 'border:solid lightgreen 3px; border-radius:10px;height:100px;',#style="box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px;",
                                                 
                                            # ),
                                             
                                             #second row ------
                                           
                                           tags$head(HTML("<script>
                                           
                                            //https://www.youtube.com/watch?v=UqEmFSlx4ps
                                            //https://codepen.io/Coding_Journey/pen/RwGzqgJ
                                            //tilt.js
                                            
                                            $(document).ready(function () {
                                             const box = document.getElementById('carouselExample');
                                           
                                           box.addEventListener('mousemove', function (e) {
                                             const bounds = box.getBoundingClientRect();
                                             const x = e.clientX - bounds.left;
                                             const y = e.clientY - bounds.top;
                                             const centerX = bounds.width / 2;
                                             const centerY = bounds.height / 2;
                                             
                                             const percentX = (x - centerX) / centerX;
                                             const percentY = (y - centerY) / centerY;
                                             
                                             const maxTilt = 10;
                                             const tiltX = -percentY * maxTilt;
                                             const tiltY = percentX * maxTilt;
                                             
                                             box.style.transform = `perspective(1000px) rotateX(${tiltX}deg) rotateY(${tiltY}deg) scale3d(1.05, 1.05, 1.05)`;
                                           });
                                           
                                           box.addEventListener('mouseleave', function () {
                                             box.style.transform = `rotateX(0deg) rotateY(0deg) scale3d(1, 1, 1)`;
                                           });
                                            });
                                           </script>")
                                                    ),
                                           
                                             div(style= 'height:500px;margin-top:30px;border:solid lightgreen 3px; border-radius:10px;',
                                                 h5(style = "padding:20px 20px 0px 20px;",'Attributes/ Parameters'),
                                                 div( carousel('carouselExample')),
                                                 
                                             ),#style="box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px;",#"box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px;",#style='margin-top:-50px;',
                                             #third row --------
                                           
  #                                            div( style= 'margin-top:30px;border:solid orange 3px; border-radius:10px;', #"margin:20px;box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px;",
  #                                                 # icon('computer-mouse',style='float:right;padding:15px;'),
  #                                                 h5(style = "padding:5px;",'Configuration of interventions'),
  #                                                 
  #                                                 div(style = 'padding:10px;height:150px;
  # margin:10px;
  # border: solid lightgreen 3px;
  # border-radius:10px;',
  #                                                     icon('table',style='height:200px;float:right;margin:5px;'),
  #                                                     
  #                                                     DT::DTOutput('table_configutation')
  #                                                 ),
  #                                                 
  #                                                 div( style= 'height:300px;border:solid white 3px; border-radius:10px;margin:10px', 
  #                                                      
  #                                                      h5(style = "padding:10px;",'Intervention'),
  #                                                      
  #                                                      
  #                                                 )
  #                                            ),
                                      ),
                                      
                                      ###right sidebar -----
                                      column(2, 
                                             style='display:inline;position:relative;',
                                             div(class = "fixed-pane",style = "padding:10px;",
                                                 #h5( 'Cost'),
                                                 icon('coins',style= 'float:right'),
                                                 h6('Cost per capita'),
                                                 p('Total administered, lack of adherence or other wastage is considered separately'),
                                                 div(class='cost', numericInput(width = '80%','cost',label='',value = 5,min = 0,max=10000)),
                                                 # cost_component(),
                                                 HTML('<div class="skeleton" style = "display:flex;flex-direction:column;  gap: 16px;">
  <div class="skeleton-box"></div>
  <div class="skeleton-title"></div>
  <div class="skeleton-row"></div>
  <div class="skeleton-row"></div>
  <div class="skeleton-row"></div>
<hr>

  <div class="skeleton-box"></div>
  <div class="skeleton-title"></div>
  <div class="skeleton-row"></div>
  <div class="skeleton-row"></div>
  <div class="skeleton-row"></div>

</div>')  
                                             ) #end fixed pane
                                      ), # end column
                                      
                                      
                                      
                                      #         fluidRow( column(12,
                                      # div(id = 'footer2', class='flex-center',
                                      # style = 'position: absolute;
                                      #   bottom: 0;
                                      #   left:0;
                                      #   right:0;
                                      #   width: 80%;
                                      #   height: 50px; /* Adjust as necessary */
                                      #   background-color: red;
                                      #   color: #fff;
                                      #   text-align: center;
                                      #   line-height: 50px; /* Center the text vertically */',5)
                                      # 
                                      #         )
                                      # )
                                    ), # end row
  
  ## target_echarts ----
  div(id = 'target_echart',class = 'd-flex align-items-center justify-content-center',
      data.frame(year = 2023, incidence = 1) |> 
        mutate(year = as.character(year)) |> 
        e_chart(year) |> 
        e_line(incidence)
      
  ),
  tags$script(src = "js/update_chart_w_model_runs.js"),
  tags$head(tags$script(#defer = TRUE,
    "Shiny.addCustomMessageHandler('updateChart', function(seriesList) {
  const chartEl = document.querySelector('#target_echart > .echarts4r');
  if (!chartEl) {
    console.warn('Chart container not found');
    return;
  }

  const chart = echarts.getInstanceByDom(chartEl);
  if (!chart) {
    console.warn('ECharts instance not ready');
    return;
  }

  const legendData = seriesList.map(s => s.name);
  const seriesConfig = seriesList.map(s => ({
    name: s.name,
    type: 'line',
    data: s.data
  }));

  chart.setOption({
    xAxis: { type: 'time', scale: true, max: '2030-01-01' },
    yAxis: { type: 'value', scale: true },
    tooltip: { trigger: 'axis' },
    legend: { data: legendData },
    series: seriesConfig
  });
});
    "))
    
  
  
      
                          ) # end nav panel #,
                          
                          #   nav_panel(value = 'Report Builder',
                          #             title='Report',
                          #             icon=icon('pen'),
                          #             class = 'fade',
                          #                HTML('  <ol class="breadcrumb breadcrumb-nav p-3 bg-body-tertiary rounded-3">
                          #     <li class="breadcrumb-item fa fa-home" ><a href="#" onclick = window.change_tab("Landing");>Home</a></li>
                          #     <li class="breadcrumb-item fa"><a href="#" onclick = window.change_tab("model-home");>Model</a></li>
                          #     <li class="breadcrumb-item fa active">Report</li>
                          #   </ol>
                          # '),
                          #             div(class='divider','Reports'),
                          #             
                          # 
                          # div (style="margin-top:30px;display:flex; align-content:center; justify-content:center;",
                          #      div (style="margin:20px;",
                          # 
                          #      tags$button(id = 'copy_editor', 'Copy', class= 'btn btn-danger reference', icon('copy'))
                          # ),
                          # 
                          #      
                          # #div(style='width:200px;',
                          #    # prevalence_plot_diabetes,
                          #     
                          #     # leaflet(options = leafletOptions(preferCanvas = TRUE)) %>% addTiles() %>% 
                          #     #   addPolygons(data = states),
                          #     # 
                          #     # 
                          #     #  maplibre(style = carto_style("positron"),preserveDrawingBuffer=TRUE) |> 
                          #     #   fit_bounds(nc, animate = FALSE) |> 
                          #     #   add_fill_layer(id = "nc_data",
                          #     #                  source = nc,
                          #     #                  fill_color = "blue",
                          #     #                  fill_opacity = 0.5)
                          #     
                          #   #  ),
                          # 
                          # 
                          # #gwalkrOutput('gwalkr',width = '50vw'),
                          # 
                          # div(id='drop'),
                          # #https://stackoverflow.com/questions/2518807/css-import-or-multiple-css-files
                          # HTML('<link href="https://cdn.jsdelivr.net/npm/quill@2.0.2/dist/quill.snow.css" rel="stylesheet" />
                          # <head><style>
                          #        #editor body {
                          #             font-family: Arial, sans-serif;
                          #             line-height: 1.6;
                          #             margin: 20px;
                          #             padding: 20px;
                          #             border: 1px solid #ccc;
                          #             border-radius: 5px;
                          #             background-color: #f9f9f9;
                          #         }

                          #         #editor h1,#editor h2,#editor h3 {
                          #             color: #333;
                          #         }
                          #         #editor h1 {
                          #             text-align: center;
                          #         }
                          
                          #         #editor section {
                          #             margin-bottom: 20px;
                          #         }
                          #         #editor .section-title {
                          #             background-color: #e0e0e0;
                          #             padding: 10px;
                          #             border-radius: 5px;
                          #         }
                          #         #editor ul {
                          #             margin: 10px 0;
                          #             padding-left: 20px;
                          #         }
                          #     </style>
                          #     </head>
                          # <!-- Create the editor container -->
                          # 
                          # <div class="d-block" style="height: auto !important;width:60vw;">
                          # FFEvidence
                          
                          # 
                          # <div id="editor">
                          #  <p>
                          # </p><p class=""></p><h2 class=""></h2><h3 class=""></h3><h6 class=""></h6><h1 class=""><img style="width: 100px;" src="data:image/png;base64,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oJqFO/MVTIiorKxs+qefWYEDgpECaUGaBFqIgC1P+bW1K2/nW2+9pcNKnnDSSW++/ZbvDMQnJtxz3729emffdcedJOKpq/vn628889yzvgsXERHx7w8/8NXLNEVHR192xeVjx44944wz6qqqyVCff/75gw8/FGg5Ckrp6emTzjhdX7/44ou6xbi4uDPPPDOUkw18Pp/5u3YJ0KNnz+nTp8fGxel3cuDAgWefffajDz/yr3ffBcDMn3766QMPPBDujtCVtDOsX46IITrWFljHdxURl6FImIj0WUelaR4OPb0RqgBA4+h6y5f99+4774Tl7YULLrgAtovr4TvLZ8hfn3xScys0Zot9+/d7+e9/v+aqq3TrS5cu3b4tt2v3bn5yR2uWgAjAjBkztm/bZjFxpV546aVRxx8XvDA1PNUcXzlnSvcXFNx7992t655fW2+99ZZpmkpRbGzsI4896ivKOYXPOeecr+bNnzdnDgm+nj+/srIyJiYGPkJWgxXPWU97aFldu15yySXvvfU2M1dWVq5dvWbw0CHNtGQFfgsDea6fF7f2l9L3k1NS3njznzFxsX5f0LvuuXv+3Ln79u0jorqammnTpl1+5RVwvK/b6ZciG5mLBhUgWoXBhy/UmofRl7OsrEyfsFjaRFnZvHnzrr7yqsumTCkoKNDi1eDBg2+44QbY3KrNT2CUFbUe40888bwLzg9V7Pgxo8+74ALrD+YvvviiDXvy8ssvw57z6264/pRTJ1CIQIa+1py2hRT5MR2/pxrCTlRWffrpp3qXXnvddRkZGaGeuvraa3QHKioqFi9eHKobQrYLXsPzOPnkk4VARApYu3Zt84FyDidy+IhqHDMy0LDg/GmEhb377rtBT2Cjo6OvvPpq55Evbe9934ba6bBTQoTFmxQMvaYiEumygG962apZ2tz93HkhJpx8yuBjjx193PGnnnTy8MFDBg869pabbl6yeDEsB1IaMGjQm2+/FRYR7vdgGzILJ1bEVddcHbyAvROuvvpqxyS8ePHitvKOXrt6zY7cXH0dFRV18803N+FsFJSthByaj7ih7ceOe3ngf6aIUwCh7YzffvttfW2trvCiiy4K6qeprwcPHhzuduvD3xXLfwzVycDBiEhqhzTYss/u3bub47jTaFpCL0vgK+TwuOOPP75///6hmhgzbqzYj6xZs8bpT7tK+AsS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ESOLDxxQSk0+99y77767Q8d03yEfNeM9cqidYbVTsyiQ6YhIfn5+YWFhfX29iERFRXXu3DkpKenX7ukvOhV/e+754uLiKVOm9B9wTIuwEe3UOmpnWO3USmoR+ukokzhCISraedbhpv8PL/4kebQbIMwAAAAldEVYdGRhdGU6Y3JlYXRlADIwMjAtMDItMTFUMTg6NTk6MzkrMDA6MDAAv81yAAAAJXRFWHRkYXRlOm1vZGlmeQAyMDIwLTAyLTExVDE4OjU5OjM5KzAwOjAwceJ1zgAAABF0RVh0ZXhpZjpDb2xvclNwYWNlADEPmwJJAAAAIXRFWHRleGlmOkRhdGVUaW1lADIwMTY6MDQ6MDYgMTY6MjA6NDmYrZHNAAAAGHRFWHRleGlmOkV4aWZJbWFnZUxlbmd0aAAyODdOltXzAAAAGHRFWHRleGlmOkV4aWZJbWFnZVdpZHRoADExNDFiS/OrAAAAE3RFWHRleGlmOkV4aWZPZmZzZXQAMTcyPAO/YAAAADF0RVh0ZXhpZjpTb2Z0d2FyZQBBZG9iZSBQaG90b3Nob3AgQ0MgMjAxNSAoTWFjaW50b3NoKcYLodkAAAAcdEVYdGV4aWY6dGh1bWJuYWlsOkNvbXByZXNzaW9uADb5ZXBXAAAAKHRFWHRleGlmOnRodW1ibmFpbDpKUEVHSW50ZXJjaGFuZ2VGb3JtYXQAMzEwsjE6MAAAAC90RVh0ZXhpZjp0aHVtYm5haWw6SlBFR0ludGVyY2hhbmdlRm9ybWF0TGVuZ3RoADMzNjC2cpTPAAAAH3RFWHRleGlmOnRodW1ibmFpbDpSZXNvbHV0aW9uVW5pdAAyJUBe0wAAACB0RVh0ZXhpZjp0aHVtYm5haWw6WFJlc29sdXRpb24AMzAwLzEtbLGVAAAAIHRFWHRleGlmOnRodW1ibmFpbDpZUmVzb2x1dGlvbgAzMDAvMarKetYAAAA4dEVYdGljYzpjb3B5cmlnaHQAQ29weXJpZ2h0IChjKSAxOTk4IEhld2xldHQtUGFja2FyZCBDb21wYW55+Vd5NwAAACF0RVh0aWNjOmRlc2NyaXB0aW9uAHNSR0IgSUVDNjE5NjYtMi4xV63aRwAAACZ0RVh0aWNjOm1hbnVmYWN0dXJlcgBJRUMgaHR0cDovL3d3dy5pZWMuY2gcfwBMAAAAN3RFWHRpY2M6bW9kZWwASUVDIDYxOTY2LTIuMSBEZWZhdWx0IFJHQiBjb2xvdXIgc3BhY2UgLSBzUkdCRFNIqQAAAABJRU5ErkJggg=="></h1><p></p><h1 style="text-align: center;" class="">Public Health Report</h1><h4 style="text-align: center;" class="">Analysis of Smoking Trends using NISRA data</h4><p style="text-align: center;"><br></p><p style="text-align: center;"><span style="color: rgb(51, 51, 51); font-size: 12px;">Joe Smith, Health Intelligence Manager</span><br></p><p style="text-align: center;"><br></p><hr><p style="text-align: center;"><br></p><h1 style="text-align: left;" class="">Intro</h1><blockquote style="text-align: left;" class="">Smoking irreparably damages lungs</blockquote><p></p><p></p><h1 style="text-align: left;" class="">Analysis</h1><p style="text-align: left;"><br></p><h4 style="text-align: left;" class="">Graph</h4><p style="text-align: left;"><br></p><p></p><p></p><p></p><div style="text-align: left;"><img src="data:image/jpeg;base64,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" data-filename="th.jpg" class="" style="text-align: center;"></div><div style="text-align: left;"><br></div><div style="text-align: left;"><br></div><div style="text-align: left;">Fig1. Smoking is on the decline, but electronic vaping and e-cigarettes are up.</div><div style="text-align: left;"><br></div><p></p><p style="text-align: justify;"><font color="#000000" style="background-color: rgb(255, 255, 0);">Drag and drop images, tables and plots here,</font></p>
                          #   <div swtyle="font-style: italic; text-align: justify;"><i>Please your cursor here and drag and drop the images. This directs the image.</i></div><div style="font-style: italic; text-align: justify;"><i><br></i></div><div style="text-align: justify;"><font color="#000000" style="background-color: rgb(255, 255, 0);">Add formatted text to fill out your analysis</font></div><div style="font-style: italic; text-align: justify;"><br></div><p></p><h4 style="text-align: justify;" class="">Smoking trends over the last ten years</h4><ul><li>&nbsp;Cigarette smoking prevalence has shown a gradual decline over the last ten years, falling from 24% in 2010/11 to 17% in 2019/20.</li><li>&nbsp;Smoking rates amongst males and females have tended to be at a similar level, with 18%&nbsp; of males and 16% of females indicating they currently smoke cigarettes in 2019/20.</li><li>&nbsp;Those living in the most deprived areas have consistently been between two and three&nbsp; times as likely to smoke as those living in the least deprived areas, however, smoking prevalence has fallen from 40% to 27% in the most deprived quintile over the last ten years.</li><li>&nbsp;Use of packaged cigarettes has declined with two-thirds (69%) of smokers in 2019/20 using them compared with 83% in 2010/11</li></ul><p><br></p><p><span style="color: rgb(0, 0, 0); font-size: 14px; text-align: justify; background-color: rgb(255, 255, 0);">Add links to reference sources</span><br></p><p><a href="https://www.health-ni.gov.uk/sites/default/files/publications/health/hsni-smoking-trends-19-20.pdf" target="_blank">https://www.health-ni.gov.uk/sites/default/files/publications/health/hsni-smoking-trends-19-20.pdf</a><br></p><div style="text-align: justify;"><br></div><h4 style="text-align: justify;" class="">Tables</h4><p style="text-align: justify;"><br></p><p style="" class=""><font color="#000000" style="background-color: rgb(255, 255, 0);">Tables drag and drop as if they were native tables - manipulate them!</font></p><p style="" class=""><font color="#000000" style="background-color: rgb(255, 255, 0);"><br></font></p><div style="text-align: justify;"><table class="pvtTable" data-numrows="16" data-numcols="0" style="caption-side: bottom; font-family: Helvetica; font-size: 8pt; background-color: rgb(255, 255, 255);"><thead style="border: none;"><tr style="border: none;"><th class="pvtAxisLabel" style="text-align: -webkit-match-parent; border: 1px solid rgb(205, 205, 205); font-size: 8pt; padding: 5px; text-wrap-mode: nowrap;">Year</th><th class="pvtTotalLabel pvtRowTotalLabel" style="text-align: right; border: 1px solid rgb(205, 205, 205); font-size: 8pt; padding: 5px;">Totals</th></tr></thead><tbody style="border: none;"><tr style="border: none;"><th class="pvtRowLabel" rowspan="1" style="text-align: -webkit-match-parent; border: 1px solid rgb(205, 205, 205); font-size: 8pt; padding: 5px; vertical-align: top; text-wrap-mode: nowrap;">2018/19</th><td class="pvtTotal rowTotal" data-value="24" data-for="row13" style="border: 1px solid rgb(205, 205, 205); font-weight: 700; color: rgb(61, 61, 61); padding: 5px; vertical-align: top; text-align: right;">24</td></tr><tr style="border: none;"><th class="pvtRowLabel" rowspan="1" style="text-align: -webkit-match-parent; border: 1px solid rgb(205, 205, 205); font-size: 8pt; padding: 5px; vertical-align: top; text-wrap-mode: nowrap;">2019/20</th><td class="pvtTotal rowTotal" data-value="24" data-for="row14" style="border: 1px solid rgb(205, 205, 205); font-weight: 700; color: rgb(61, 61, 61); padding: 5px; vertical-align: top; text-align: right;">24</td></tr><tr style="border: none;"><th class="pvtRowLabel" rowspan="1" style="text-align: -webkit-match-parent; border: 1px solid rgb(205, 205, 205); font-size: 8pt; padding: 5px; vertical-align: top; text-wrap-mode: nowrap;">2021/22</th><td class="pvtTotal rowTotal" data-value="24" data-for="row15" style="border: 1px solid rgb(205, 205, 205); font-weight: 700; color: rgb(61, 61, 61); padding: 5px; vertical-align: top; text-align: right;">24</td></tr><tr style="border: none;"><th class="pvtTotalLabel pvtColTotalLabel" colspan="1" style="text-align: right; border: 1px solid rgb(205, 205, 205); font-size: 8pt; padding: 5px;">Totals</th><td class="pvtGrandTotal" data-value="384" style="border: 1px solid rgb(205, 205, 205); font-weight: 700; color: rgb(61, 61, 61); padding: 5px; vertical-align: top; text-align: right;">384</td></tr></tbody></table></div><div style="text-align: justify;"><br></div><div style="text-align: justify;"><br></div><p class=""><span style="background-color: rgb(255, 255, 0);"><font color="#424242">Excel tables drag and drop as images - preserving formatting - but are otherwise immutable</font></span></p><br><div style="text-align: justify;"><div><img src="data:image/png;base64,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" data-filename="image.png" style="width: 881.359px;"><span style="color: rgb(66, 81, 95); font-family: inherit; font-size: 26px;"><br></span></div><div><span style="color: rgb(66, 81, 95); font-family: inherit; font-size: 26px;"><br></span></div><div><span style="color: rgb(66, 81, 95); font-family: inherit; font-size: 26px;"><br></span></div><div><span style="color: rgb(66, 81, 95); font-family: Helvetica; font-size: 26px;">What does the law have to say about it?</span><br></div><div><br></div><div><br></div></div><div style="font-style: italic; text-align: justify;"><a href="https://www.nidirect.gov.uk/articles/smoking-and-vaping-regulations-northern-ireland" target="_blank"><span style="font-family: Helvetica;">Northern Ireland Law</span></a><i><br></i></div><div style="font-style: italic; text-align: justify;"><i><br></i></div><h1 style="text-align: justify;" class=""><span style="font-family: Helvetica;"><br></span></h1><h1 style="text-align: justify;" class=""><span style="font-family: Helvetica;">Conclusion</span></h1><h1 style="text-align: justify;" class=""><span style="font-family: Helvetica;"><br></span></h1><div style=""><br></div><div style="text-align: justify;"><div style="padding-bottom: 0px; outline: none; text-align: left;"><div class="df_con df_rhigh" style="overflow: hidden; margin-bottom: 0px; padding-bottom: 0px; outline: none;"><p style="padding-bottom: 0px; outline: none; line-height: 22px;" class=""><span style="text-underline-offset: 3px;">Smoking is banned by law in many public places in Northern Ireland, including all forms of public transport, theatres, cinemas, and public buildings, shared work vehicles and in private vehicles where someone under the age of 18 is present</span><span style="text-underline-offset: 3px;">.&nbsp;Most enclosed public places and workplaces in Northern Ireland are smoke free, and it is against the law to smoke in these places</span><span style="text-underline-offset: 3px;">.&nbsp;Smoking contributes to many illnesses, including cancer, heart disease, bronchitis, asthma, and stroke, which causes around 2,400 deaths per year in Northern Ireland</span><span style="text-underline-offset: 3px;">.</span></p></div></div></div><div style="font-style: italic; text-align: justify;"><br></div><div style="font-style: italic; text-align: justify;"><span style="color: rgb(66, 66, 66); font-size: 13px; font-style: normal; text-align: start; background-color: rgb(255, 255, 0);">Copy and paste the content into a richer text editor, like MS Word, once you are content with the basic structure.</span></div><div style="font-style: italic; text-align: justify;"><span style="color: rgb(66, 66, 66); font-size: 13px; font-style: normal; text-align: start; background-color: rgb(255, 255, 0);"><br></span></div><div style="font-style: italic; text-align: justify;"><span style="color: rgb(66, 66, 66); font-size: 13px; font-style: normal; text-align: start; background-color: rgb(255, 255, 0);"> </span></div><div style="font-style: italic; text-align: justify;"><span style="color: rgb(0, 0, 0); font-size: 13px; font-style: normal; text-align: start; font-family: inherit;"><br></span></div><div><span style="color: rgb(66, 81, 95); font-family: Helvetica; font-size: 26px;">Pick up where you left off</span><br></div><div><br style="text-align: justify;"></div><h6 style="text-align: start;" class=""><span style="background-color: rgb(255, 255, 0); color: rgb(66, 66, 66); font-size: 13px;">Once you have copied the content it is saved for your next session!</span><br></h6><div><span style="color: rgb(66, 66, 66); font-size: 13px; font-style: normal; text-align: start; background-color: rgb(255, 255, 0);"><br></span></div><div style="font-style: italic; text-align: justify;"><br></div></div>
                          # </div>'),
                          # 
                          # HTML('<!-- Include the Quill library -->
                          # <head><script src="https://cdn.jsdelivr.net/npm/quill@2.0.2/dist/quill.js"></script>
                          # <script src="https://cdn.jsdelivr.net/npm/quill-image-resize-module@3.0.0/image-resize.min.js"></script>
                          # 
                          # 
                          # <!-- Initialize Quill editor -->
                          # <script src = "/js/initialise_quill.js">
                          # 
                          # </script></head>'),
                          # 
                          #   )
                          # )
                          
        )
    )
  )
)




# Defiπne server logic required to draw a histogram
server <- function(input, output, session) {
  
  output$risk_equation_dt <- renderDataTable({
    risk_table_dt
    
  })
  
  
  
  #risk and evidence
  output$network_risk_lineage <- renderVisNetwork({
    network_risk_lineage
  })
  
  # output$gwalkr <- renderGwalkr({
  #   gwalkr(mtcars)
  #     #gwalkr(YR20_HYPER_CHOLE_10SCEN_hold_risk_factors)
  #   })
  
  output$model_registry <- DT::renderDT({
    datatable(data=y[c('display','model_run','spk')],
              rownames = FALSE, 
              escape =FALSE,
              height='80vh',
              options = list(
                dom = 't',  # Only show the table, no pagination or search box
                paging = FALSE,  # Disable pagination
                searching = FALSE,  # Disable search box
                ordering = FALSE,  # Disable column sorting
                info = FALSE,  # Disable info ("Showing X of Y entries")
                headerCallback = JS("function(thead, data, start, end, display){ $(thead).remove(); }")  # Remove headers
                
              ),
              style = "semanticui") %>% spk_add_deps()
  })
  
  observeEvent(input$jumptab,ignoreInit = T,ignoreNULL = T,{
    
    msg = c('Info Pane',
            'Planned Scenarios - observe functionality',
            'Interactive Scenarios - intermediate')[input$jumptab]
    
    session$sendCustomMessage(type='update_nav', message=msg)  
    print(switch(
      input$jumptab,
      'Info Panel',
      'Planned Scenarios - observe functionality',
      'Interactive Scenarios - intermediate'
    ))
    
  })
  
  observeEvent(input$show1, {
    
    print(input$show1)
    showModal(modalDialog(size = 'l',
                          title = "Causal Graph",
                          'This casual graph, shows the cascading effect of different levels of 
        cardiovascular health and risk  factors from lifestyle, demographic factors to
        phsiological and more serious CVD disease events. And, eventually, death',
                          visNetworkOutput('network1',width = '100%',height='600px'),
                          easyClose = TRUE,
                          footer = NULL
                          
    ))
  })
  
#   observeEvent(input$show2, {
#     print(input$show2)
#     showModal(modalDialog(size = 's',
#                           div(style='display:flex;align-content:center;justify-content:center;',
#                               htmltools::HTML('<script src="https://unpkg.com/@dotlottie/player-component@latest/dist/dotlottie-player.mjs" type="module"></script>
# <dotlottie-player src="https://lottie.host/9c018b56-3182-45ff-9030-05432950e693/gZE7PaFso4.json" background="transparent" speed="0.2" style="width: 200px; height: 200px" direction="1" playMode="normal" loop autoplay></dotlottie-player>'
#                               ),
#                               h4('loading...')
#                           ),
#                           easyClose = TRUE,
#                           footer = NULL
#                           
#     ))
#   })
  dummy <- reactiveVal(NULL)
  
  ## run_model ----
  observeEvent(input$show2, {
    print(input$show2)
    
    past_populations <- data.frame()#initial_time_zero_population)
    
    for(run in 1:(test_specification$model$number_of_runs)) {
      
      cat(paste('################################### \n run : ', run, ' \n###################################### \n'))
      
      #reinstate the same initial time zero population for each new run some they are comparable
      #current_population <- initial_time_zero_population |> 
      #  mutate(run = {{run}})
      
      population_w_established_prevalence <- reduce2(
        .x = rep(trusts,length(morbidities)),
        .y = rep(morbidities,each = length(trusts)),
        .init = initial_time_zero_population,
        .f = function(pop, trust, morbidity) {
          
          assign_year_minus_one_prevalence(
            input_population = pop,
            trust = trust,
            morbidity = morbidity,
            #year = 2017,
            prevalence_df = prevalence_hsct_new,
            configuration = test_specification
          )
        }
      )
      
      
      
      
      current_population <- population_w_established_prevalence |> 
        mutate(run = {{run}})
      
      current_population <- current_population |> mutate(bern_trial = runif(n()))
      
      for (time in 1:test_specification$model$duration){
        
        cat(paste('###################################### \n Time, t : ', time, '\n Run, r:', run,'\n###################################### \n'))
        
        print('Adding the current population to the past populations data structure')
        #current_population <- current_population |> select(-bern_trial)
        past_populations <- rbind(past_populations, current_population)
        
        current_population <- current_population |>
          mutate(age = age + 1) |> 
          mutate(
            age20 = cut(age,include.lowest = T,
                        breaks = seq(0,120,20),
                        labels = c('0-20',
                                   '20-40',
                                   '40-60',
                                   '60-80',
                                   '80-100',
                                   '100-120')
            )
          )
        
        current_population <- current_population |>
          mutate(year = year + 1)
        
        print('Apply and Partition deaths')
        
        current_population <- current_population %>% 
          apply_age_sex_death(apply_death = F) |> 
          apply_qmortality_mortality(apply_death = T)
        #uses data.table - not converts back to data frame in function
        
        current_population_who_died <- current_population |> 
          filter( !is.na(death) & !is.null(death) & !death==0 )
        
        dead_population <- rbind(dead_population, current_population_who_died)
        
        current_population_alive <- current_population |> 
          filter(is.na(death)| is.null(death)| death==0)
        
        current_population <- current_population_alive
        
        
        if (FALSE){  
          print('Shouldnt enter')
          
        }else{ # baseline always runs
          
          print('entered non intervention loop')
          
          current_population <- current_population |> 
            calculate_risk_of_morbidity()
          
          print('Applying absolute morbidity onset')
          print(paste('population df run',max(current_population$run)))
          
          current_population <- current_population |> 
            declare_absolute_incident_morbidity(morbidity = "stroke") |> 
            declare_absolute_incident_morbidity(morbidity = "chd") |> 
            declare_absolute_incident_morbidity(morbidity = "diabetes") |> 
            declare_absolute_incident_morbidity(morbidity = "dementia") |> 
            declare_absolute_incident_morbidity(morbidity = "heart_failure") |> 
            declare_absolute_incident_morbidity(morbidity = "atrial_fibrillation") |> 
            declare_absolute_incident_morbidity(morbidity = "hypertension") |> 
            declare_absolute_incident_morbidity(morbidity = "chronic_kidney_disease") |> 
            declare_absolute_incident_morbidity(morbidity = "lung_cancer") 
          
          print('Calculating the incidence of stroke')
          df <- count(past_populations, stroke  = (stroke!=0), run, year) |>
            filter(stroke ==TRUE) |> 
            mutate(n = n * test_specification$population$scale_down_factor)
          print(df)
          
          
          df_json <- jsonlite::toJSON(
            unname(as.list(df[c('year','n')])),  # prevent named keys like "year", "incidence"
            dataframe = "columns",
            auto_unbox = TRUE
          )
          print(df_json)
          
          print('Calculating the json')
          
          series_list <- df %>%
            group_by(run) %>%
            summarise(data = list(map2(as.character(year), n, ~ list(.x, .y)))) %>%
            mutate(name = paste0("run ", run)) %>%
            transmute(name, data) %>%
            jsonlite::toJSON(auto_unbox = TRUE)
          
          
          
          print(series_list)
          print('calculating the series list')
          
          session$sendCustomMessage("updateChart", series_list)
          
          
        }
        
      }
      
      
    }
    
    
  })
  
  new_data <- reactiveVal(jdata %>% mutate(final=NA) )
  
  observeEvent(ignoreInit = T, input$drag_data,{
    
    #shiny::req(input$drag_data)
    #print(input$drag_data)
    
    #print(data.frame(input$drag_data))
    
    # nd <- data.frame( input$drag_data ) %>% 
    #   left_join( data,. , by = c('x' = 'x')) %>% 
    #   fill(y.y) %>% 
    #   mutate(y=coalesce(y.y,y.x)) %>% select()
    
    nd <- new_data()
    
    nd[new_data()$x==input$drag_data['x'],'final'] <- input$drag_data$y
    
    print(data.frame( input$drag_data ))
    
    print(nd)
    
    new_data(nd)
    
    
  })
  
  
  observe({
    print(input$prevalence_input_multiplier_clicked_zr)
    
  })
  
  # observeEvent(input$prevalence_input_multiplier_clicked_row,{
  # 
  #   print(rbind(m10y, proposed) %>%
  #                      filter(row_number()==input$prevalence_input_multiplier_clicked_row ))
  
  #   echarts4r_proxy(id = 'prevalence_input_multiplier',
  #                 data = data.frame(forecast=1,multiplier=4),
  #                   #x = forecast,
  #                   session = session) %>%
  #     e_scatter(serie = multiplier,
  #                 data = data.frame(forecast=1,multiplier=4,color='red'),
  #                    forecast,
  #                   multiplier)
  # 
  # })
  
  observe({ 
    print( input$network_selected )
  })
  
  # observe({
  #   print(input$prevalence_plot_by_age_clicked_data)
  #   print(input$prevalence_plot_by_age_clicked_data_value)
  #   print(input$prevalence_plot_by_age_clicked_row)
  #   print(input$prevalence_plot_by_age_clicked_serie)
  #   print(input$prevalence_plot_by_age_mouseover_data)
  #   print(input$prevalence_plot_by_age_mouseover_data_value)
  #   print(input$prevalence_plot_by_age_mouseover_row)
  #   print(input$prevalence_plot_by_age_mouseover_serie)
  # })
  # 
  # output$prevalence_plot_by_age <- renderEcharts4r({
  # 
  #   prevalence[[ input$network_selected ]] %>% 
  # pivot_longer(cols = -Age) %>% 
  # group_by(name) %>% 
  # e_charts(Age) %>% 
  # e_theme_custom('{"color":["lightgreen","red"]}') %>% 
  # e_scatter(serie = value)
  # })
  
  output$prevalence_input_multiplier <- renderEcharts4r({
    
    # rbind(m10y, proposed) %>% 
    # group_by(type) %>% 
    #     
    #  mutate(size = 25,
    #         color = 'lightgreen',
    #         forecast=as.character(forecast+2020)) %>% 
    
    
    
    #print(input$drag_data)
    
    new_data() %>% 
      fill(final) %>% 
      mutate(y=coalesce(final,y),
             size=10,
             x=as.character(x),
             impact=lag(y,3,1)) %>% 
      print() %>% 
      #left_join(data.frame(input$drag_data), by=c('x'='x')) %>% 
      
      
      e_charts(x) %>% 
      echarts4r::e_line(serie = y) %>%
      echarts4r::e_line(serie = impact, lineStyle = list(opacity = 0.5)) %>%
      #e_mark_line(data = list(xAxis = '2025'), lineStyle = list(color='lightgreen'), title = "") %>%
      #e_mark_line(data = list(xAxis = '2030'), title = "") %>% 
      
      e_theme_custom('{"color":["lightgreen","royalblue"]}') %>% 
      e_hide_grid_lines() %>% 
      e_x_axis(
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),
        min = '2020',
        max = '2030') %>% 
      e_y_axis(
        min = -1,
        max = 5,
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE)) %>% 
      e_grid(index=1,show=FALSE) %>% 
      e_legend(show=FALSE)
    # e_on(event = 'click', handler =  'function(params){
    #      console.log(params);
    #      Shiny.setInputValue("chart_clicked", params.data);
    # }')
  })
  
  # observeEvent(eventExpr = input$prevalence_input_multiplier_global_out,{
  # 
  #   print(input$prevalence_input_multiplier_global_out)
  # })
  
  
  #   observeEvent(eventExpr = input$prevalence_input_multiplier_clicked_zr,{
  #   
  #   print(input$prevalence_input_multiplier_clicked_zr)
  # })
  
  
  
  output$network <- renderVisNetwork(
    visNetwork(nodelist %>% mutate(label=NULL),edgelist,background = 'transparent') %>% 
      #visHierarchicalLayout()
      visLayout(randomSeed = 10) %>% 
      visNodes(label=NULL,
               color = list(background = "lightblue", 
                            highlight = "orange"),
               shadow = list(enabled = TRUE, size = 10))  %>% 
      visInteraction(dragNodes = TRUE, 
                     selectable =TRUE,
                     dragView = FALSE, 
                     zoomView = FALSE) %>% 
      visOptions(nodesIdSelection = list(selected='hypertension'))
    
  )
  
  output$network1 <- renderVisNetwork(
    visNetwork(nodelist,edgelist,background = 'transparent') %>% 
      #visHierarchicalLayout()
      visLayout(randomSeed = 10) %>% 
      visNodes(
        color = list(background = "lightblue", 
                     highlight = "orange"),
        shadow = list(enabled = TRUE, size = 10))  %>% 
      visInteraction(dragNodes = TRUE, 
                     selectable =TRUE,
                     dragView = FALSE, 
                     zoomView = FALSE) %>% 
      visOptions(nodesIdSelection = list(selected='hypertension'))
  )
  
  
  reactive( print(input$populations_dest) )
  
  observeEvent(input$run1,{
    session$sendCustomMessage("scroll", c(1))
    
  })
  
  output$graph_risk_factors <- renderPlot({
    req(input$run1)
    
    ( hold_risk_factors %>%
        mutate(multiplier=run) %>% 
        mutate(`impact parameter` = as.factor(run),
               `synthetic population morbidity` = n,
               category1 = case_when(
                 category == 'bp' ~ 'Blood Pressure',
                 category == 'cholesterol' ~ 'Cholesterol'
               ),
               name1 = case_when(
                 name =='high_bp' ~ 'Normal',
                 name =='normal_bp' ~ 'Risky',
                 name == 'high_cholesterol' ~ 'Risky',
                 name == 'normal_cholesterol' ~ 'Normal') ) %>% 
        #pivot_wider(id_cols = -value,names_from = category,values_from = name) %>%
        #count(year,name,run,category) %>%
        
        ggplot() +
        geom_line(aes(year,`synthetic population morbidity`,
                      color=`impact parameter`,group=`impact parameter`))+
        facet_wrap(~category1 + name1,scales = 'free') +
        theme_classic() +
        labs(title='Plot of the impacted physiological states of individuals over 20yr of a population wide statin prescription',
             subtitle = 'Simulating the effect of a universal, population wide statin prescription.\nThe "impact parameter" is a measure of impact of the prescription. It is simulated from 0% to 10% efficacy at 1% increments\n'
        ) )
    
  })
  
  output$economic_risk <- renderPlot({
    req(input$run1)
    
    hold_risk_factors %>%
      mutate(multiplier=run) %>% 
      
      ggplot() +
      geom_line(aes(year,n,color=run,group=multiplier))+
      facet_wrap(~category+name,scales = 'free') +
      theme_cowplot() 
    
  })
  
  
  output$graph_health_outcomes <- renderPlot({
    req(input$run1)
    
    hold_outcome %>% 
      mutate(run=run) %>% 
      
      ggplot()+
      geom_line(aes(year,n,group=run,colour=run))+
      theme_cowplot()
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
