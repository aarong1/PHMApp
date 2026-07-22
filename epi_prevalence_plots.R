# epi_prevalence_plots.R

library(readxl)
library(apexcharter)
library(echarts4r)
library(readr)
library(tidyverse)

mdm_soa <- read_excel("data/NIMDM17_SOAresults.xls", 
                                 sheet = "MDM")

npp <- read_excel("data/NPP20-ppp-age-sex.xlsx", 
                                sheet = "Tabular 5 Year Age Bands", skip = 1)

dp <- read_csv("disease_prevalence_trust.csv")

(
disease_prevalence_plots <- dp |> 
  filter(`Statistic Label` %in%
           "Raw disease prevalence per 1,000 patients" #,
         #Disease =='Asthma'
         ) |> 
 # group_by(`Health and Social Care Trust`) |> 
apex(synchronize = F,
  aes(x = `Financial Year`, y = VALUE, colour = `Health and Social Care Trust`),
  type = "line"
) |> ax_markers(size = 5) |> 
  ax_chart(sparkline = list(enabled=TRUE)) |> 
    
   ax_colors( '#dd6b66',
  '#759aa0',
  '#e69d87',
  '#8dc1a9',
  '#ea7e53',
  '#eedd78',
  '#73a373',
  '#73b9bc',
  '#7289ab',
  '#91ca8c',
  '#f49f42') |> 
    #ax_colors('#c23531',
    #          '#2f4554',
    #          '#61a0a8',
    #          '#d48265',
    #          '#91c7ae',
    #          '#749f83',
    #          '#ca8622',
    #          '#bda29a',
    #          '#6e7074',
    #          '#546570',
    #          '#c4ccd3') |> 
  ax_facet_wrap(ncol = 3,
                grid_width = '1200px',
                chart_height = '400px', 
                vars( Disease),scales = 'free') |> 
  ax_legend(show=TRUE) |> 
    ax_tooltip(shared=F) |> 
  ax_grid(padding = list(left=50,right=50,top=20,bottom=50))
)

# Sample Data
df <- data.frame(
  x = 1:10,
  y = cumsum(rnorm(10, mean = 5, sd = 2))
)

# Create ECharts Area Chart with Gradient Fade
library(echarts4r)

# Sample Data
df <- data.frame(
  x = 1:10,
  y = cumsum(rnorm(10, mean = 5, sd = 2))
)

# ECharts Area Chart with Vertical Gradient

df <- data.frame(
  x = 1:10,
  y = cumsum(rnorm(10, mean = 5, sd = 2))
)


df %>%
  e_charts(x,darkMode =TRUE) %>%
  e_scatter(serie = y,
            legend = TRUE,
            itemStyle = list(
    color = "green")) |> 
  e_line(serie = y,
          itemStyle = list(
          color = "white"),
    areaStyle = list(
      color = list(
        type = "linear",
        x = 0, 
        y = 0, 
        x2 = 0, 
        y2 = 1,  # Vertical gradient from top to bottom
        colorStops = list(
          list(offset = 0, color = 'mediumseagreen'),  # Top: Fully opaque
          list(offset = 1, color = 'white')   # Bottom: Fully transparent
      )
    )
  )
) %>% 
  e_title("ECharts Area Chart with Fading Opacity")


  dp |> 
  filter(`Statistic Label` %in%
           "Raw disease prevalence per 1,000 patients" ,
         Disease=='Asthma') |> 
  group_by(`Health and Social Care Trust`,Disease ) |> 
  e_charts(`Financial Year`,timeline = F ) %>%
  e_scatter(VALUE ) %>% 
    e_line(VALUE) |> 
  e_tooltip() |> 
  e_title("Raw disease Prevalence") 



#  [1] "Atrial Fibrillation"                   "Asthma"                               
#  [3] "Cancer"                                "Coronary Heart Disease"               
#  [5] "Chronic Obstructive Pulmonary Disease" "Dementia"                             
#  [7] "Depression"                            "Diabetes Mellitus"                    
#  [9] "Heart Failure 1"                       "Heart Failure 3"                      
#  [11] "Mental Health"                         "Osteoporosis"                         
#  [13] "Rheumatoid Arthritis"                  "Stroke & TIA"                         
#  [15] "Hypertension"                          "Chronic Kidney Disease"               
#  [17] "Non-Diabetic Hyperglycaemia" 

  plot_disease_prevalence <- function(dp,disease){
   # print(unique(dp$Disease))
   # print(disease)
    dp %>%
      filter(`Statistic Label` %in%
               "Raw disease prevalence per 1,000 patients") %>%
      filter(Disease==disease) %>%
      group_by(`Health and Social Care Trust`) |> 
     # e_x_axis(axisLabel = list(rotate = 45)) |> # Rotate X labels by 45 degrees
      e_charts(elementId = disease, 
               darkMode=T,
               timeline = T,
               height = '250px', #'200px',
               width  =  '250px', #'500px',
               x = `Financial Year`) %>%
      e_scatter(serie = VALUE,name = 'Rate per 100k') %>%
      # e_timeline_serie(index =`Health and Social Care Trust` ) |> 
      # e_timeline_opts(
      #                 label = list(
      #   rotate = 15, 
      #   offset = 80,
      #   color = '#333')
      # ) |> 
      e_toolbox_feature( feature = 'magicType',
        type = c("line", "bar")) |> #, "stack"
      # e_tooltip(trigger = 'axis') |> 
      e_line(serie = VALUE) |> 
          plot_aesthetics() |> 
      e_group(group = 'connect')

  }

  
(cancer_plot <-  plot_disease_prevalence(dp, 'Cancer'))
  
copd_plot <- plot_disease_prevalence(dp, 'Chronic Obstructive Pulmonary Disease')  
depression_plot <- plot_disease_prevalence(dp, 'Depression')  
asthma_plot <- plot_disease_prevalence(dp, 'Asthma')  
mental_plot <- plot_disease_prevalence(dp, 'Mental Health')  
af_plot <- plot_disease_prevalence(dp, 'Atrial Fibrillation')
chd_plot <- plot_disease_prevalence(dp, 'Coronary Heart Disease')  
hf1_plot <- plot_disease_prevalence(dp, 'Heart Failure 1')  
hf3_plot <- plot_disease_prevalence(dp, 'Heart Failure 3')  
stroke_plot <- plot_disease_prevalence(dp, 'Stroke & TIA')  
ckd_plot <- plot_disease_prevalence(dp, 'Chronic Kidney Disease')
hypergly_plot <- plot_disease_prevalence(dp, 'Non-Diabetic Hyperglycaemia')  
DM2_plot <- plot_disease_prevalence(dp, 'Diabetes Mellitus')
hy_plot <- plot_disease_prevalence(dp, 'Hypertension')  
dementia_plot <- plot_disease_prevalence(dp, 'Dementia')    
osteoporosis_plot <- plot_disease_prevalence(dp, 'Osteoporosis')  
arthritis_plot <- plot_disease_prevalence(dp, 'Rheumatoid Arthritis')  


  e_arrange(title = 'hello',
            cols = 2,
            copd_plot,            
            cancer_plot |> 
              e_connect_group("connect") 
            )  
  
  

  
  
  
  
  
  
  
  