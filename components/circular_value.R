library(tidyverse)

library(shiny)
library(bslib)
'red' #ff4741


circular_value <- function(value=15e3){

labels = c('below cost effective', 
  'lower threshold cost effective',
  'upper threshold cost effective',
  'cost effective'
  )

below_values =c(0,20000,25000,30000,1e8)

colours= c('lightgreen','yellow','orange', '#ff4741')

div(
  HTML('<head><style>
  #inner{
  border:solid 20px lightgreen;
  border-radius:50%;
  transform: scale(1);
  padding-top:20px;width:100%;height:100%;
    transition: transform 1s ease-in-out;

  }
  #inner:hover {
    transform: scale(1);
          transition: transform 0.5s ease-in-out;

    
  #content:hover {
    transform: none !important;
    
  </style>
       </head>'),

  div(id='outer',style ='margin:10px;width:100%;border:solid 20px #13b5cb;border-radius:50%;aspect-ratio: 1 / 1;',

div(id ='inner',
     div( id='content',
     style ='padding-top:20px;width:100%;height:100%;;

border-radius:50%;

font-weight:bold;

    display:flex;

    align-items:center;

    align-content:center;
    
    justify-content: space-around;

    flex-direction:column;

    gap:-1rem;',

    
    div(style='text-align:center;',
        p('ICER'),
p(style = 'font-size:10px;','Incremental Cost Effectiveness Ratio')) ,


    
    
    div(style='text-align:center;',
        p(style = 'display:inline-block;font-size:50px;',
          p(style = 'display:inline-block;','£'),
          h1(id='myTargetElement', style = 'display:inline-block;width:95%;',value), 
          p(style = 'display:inline-block;','/ QUALY'))),

   

    

    

div(style='text-align:center;',
    p('over 10 years'))

)
))
)
}

browsable(fluidPage(
circular_value('10,212')
))

