prevalence <- readRDS("trends_data.rds")
names(prevalence)
# [1] "alcohol_consumption"   "physical_activity"     "fruit_veg_consumption"
# [4] "bmi_level"             "cigerette_smoking"     "high_cholosterol"     
# [7] "diabetes"              "hypertension"          "CVD_Status"      

# hypertension
(prevalence_plot_hypertension <- prevalence[[ 'hypertension' ]] %>% 
    rename('hypertension'='Yes') %>%
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(height='200px',width='300px',Age) %>% 
      e_text_style(fontSize = 7) %>% # Set global font size
 e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
    e_scatter(serie = value, symbolSize = 3) %>% 
    e_tooltip(trigger = "item",
    formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
    ) %>% 
e_legend(textStyle = list(fontSize = 8),type = 'scroll') %>% 
   e_hide_grid_lines() %>% 
  e_x_axis(name = "Age",
       nameTextStyle = list(fontSize = 8),
      axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",textStyle = list(fontSize = 8),
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE))%>% 
    e_grid(left = "20%", right = "20%", bottom = "15%")
)


# Install and load the package
# install.packages("echarts4r")
library(echarts4r)

# Create sample data
data <- data.frame(
  x = 1:10,
  y = c(10, 20, 15, 25, 30, 35, 40, 38, 32, 28)
)

# Create an area chart with a gradient fill
prevalence[[ 'hypertension' ]] %>% 
    rename('hypertension'='Yes') %>%
  pivot_longer(cols = -Age) %>% 
  group_by(name)  %>%
  e_charts(Age) %>%
  e_area(value,
         smooth = TRUE ,
    color = list(
      type = "cubic", # Gradient type
      x = 0, # Start point x
      y = 0, # Start point y
      x2 = 0, # End point x2
      y2 = 1, # End point y2
      colorStops = list(
        list(offset = 0, color = 'green'),#"#13b5ca"), # Top color
        list(offset = 1, color = "white") # Top color
      )
    )
  ) %>%
  e_scatter(serie = y, symbol = "circle", itemStyle = list(color='transparent')) %>%
  
 e_text_style(fontSize = 10) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
    #e_scatter(serie = value, symbolSize = 3) %>% 
    e_tooltip(trigger = "item",
    formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
    ) %>% 
e_legend(textStyle = list(fontSize = 10),type = 'scroll') %>% 
   e_hide_grid_lines() %>% 
  e_x_axis(name = "Age",
       nameTextStyle = list(fontSize = 10),
      axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",textStyle = list(fontSize = 8),
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE))%>% 
    e_grid(left = "20%", right = "20%", bottom = "15%")

library(apexcharter)
 prevalence[[ 'hypertension' ]] %>% 
    rename('hypertension'='Yes') %>% 
 apex(
  ., 
  aes(x = Age, y = hypertension),
  
  type = "area", 
  serie_name = "Prevalence"
) %>% 
   
  ax_chart(toolbar = list(show=FALSE), 
           #sparkline = list(enabled=TRUE),
           animations = list(enabled = TRUE,speed=900, 
                             animateGradually=list(enabled=TRUE,delay=300)
                             ))  %>% 
     ax_legend(show=TRUE,position = 'bottom') %>% 
  ax_yaxis(tickAmount = 7, labels = list(formatter = format_num(",", suffix = ""))) %>% 
  #ax_colors(c("#8485854D", "#FF0000")) %>%
  ax_stroke(show = FALSE,curve ='smooth',width = c(5, 5)) %>% 
  ax_fill(
  type = "gradient",
  gradient = list(
    shade = "light",
    type = "vertical",
    opacityFrom = 1,
    opacityTo = 0,
    colorStops =list(
  list(opacity = 0.7, offset = 40, color = "#00FB15"),
  list(opacity = 0.1, offset = 110, color = "white")

    )
  )
)
 
#e_line(serie=value,showSymbol = FALSE))
    #e_scatter(serie = value))

# alcohol_consumption
(prevalence_plot_alcohol <- prevalence[[ 'alcohol_consumption' ]] %>% 
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(height='200px',width='300px',Age) %>% 
  e_text_style(fontSize = 7) %>% # Set global font size  e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
 e_scatter(serie = value, symbolSize = 3) %>% 
    e_tooltip(trigger = "item",
    formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
    ) %>% 
e_legend(textStyle = list(fontSize = 8),type = 'scroll') %>% 
   e_hide_grid_lines() %>% 
  e_x_axis(name = "Age",
       nameTextStyle = list(fontSize = 8),
      axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",textStyle = list(fontSize = 8),
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE))%>% 
    e_grid(left = "20%", right = "20%", bottom = "15%")
)

#physical_activity
(prevalence_plot_physical_activity <- prevalence[[ 'physical_activity' ]] %>% 
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(height='200px',width='300px',Age) %>% 
  e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
 e_scatter(serie = value, symbolSize = 3) %>% 
    e_tooltip(trigger = "item",
    formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
    ) %>% 
e_legend(textStyle = list(fontSize = 8),type = 'scroll') %>% 
   e_hide_grid_lines() %>% 
  e_x_axis(name = "Age",
           nameTextStyle = list(fontSize = 8),
      axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",
nameTextStyle = list(fontSize = 8),
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE))%>% 
    e_grid(left = "20%", right = "20%", bottom = "15%")
)



#fruit_veg_consumption
(prevalence_plot_fruit_veg_consumption <- prevalence[[ 'fruit_veg_consumption' ]] %>% 
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(height='200px',width='300px',Age) %>% 
  e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>%
e_scatter(serie = value, symbolSize = 3) %>% 
    e_tooltip(trigger = "item",
    formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
    ) %>% 
e_legend(textStyle = list(fontSize = 8),type = 'scroll') %>% 
   e_hide_grid_lines() %>% 
  e_x_axis(#name = "Age",
       nameTextStyle = list(fontSize = 0),
      axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),
       axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",
    textStyle = list(fontSize = 0),
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),
    axisLabel = list(show = FALSE)
    )%>% 
    e_grid(left = "20%", right = "20%", bottom = "15%")
)



#bmi_level
(prevalence_plot_bmi_level <- prevalence[[ 'bmi_level' ]] %>% 
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(height='200px',width='300px',Age) %>% 
  e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
e_scatter(serie = value, symbolSize = 3) %>% 
    e_tooltip(trigger = "item", triggerOn = "mousemove|click", alwaysShowContent = TRUE,
       #trigger = "axis",
     # axisPointer = list(
     #   type = "cross",
     #   label = list(backgroundColor = "#6a7985")
     # ),
    formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
    ) %>% 
e_legend(textStyle = list(fontSize = 8),type = 'scroll') %>% 
   e_hide_grid_lines() %>% 
  e_x_axis(name = "Age",
       nameTextStyle = list(fontSize = 0),
      axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",textStyle = list(fontSize = 0),
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE))%>% 
    e_grid(left = "20%", right = "20%", bottom = "15%")
)


#cigerette_smoking
(prevalence_plot_cigerette_smoking <- prevalence[[ 'cigerette_smoking' ]] %>% 
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(height='200px',width='300px',Age) %>% 
  e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
e_scatter(serie = value, symbolSize = 3) %>% 
    e_tooltip(trigger = "item",
    formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
    ) %>% 
  e_legend(textStyle = list(fontSize = 8),type = 'scroll') %>% 
   e_hide_grid_lines() %>% 
  e_x_axis(name = "Age",
       nameTextStyle = list(fontSize = 8),
      axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",textStyle = list(fontSize = 8),
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE))%>% 
    e_grid(left = "20%", right = "20%", bottom = "15%")
)


#high_cholosterol
(prevalence_plot_high_cholosterol <- prevalence[[ 'high_cholosterol' ]] %>% 
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(height='200px',width='300px',Age) %>% 
  e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
e_scatter(serie = value, symbolSize = 3) %>% 
    e_tooltip(trigger = "item",
    formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
    ) %>% 
e_legend(textStyle = list(fontSize = 8),type = 'scroll') %>% 
   e_hide_grid_lines() %>% 
  e_x_axis(name = "Age",
       nameTextStyle = list(fontSize = 8),
      axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",textStyle = list(fontSize = 8),
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE))%>% 
    e_grid(left = "20%", right = "20%", bottom = "15%")
)


#diabetes
(prevalence_plot_diabetes <- prevalence[[ 'diabetes' ]] %>% 
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(height='200px',width='300px',Age) %>% 
  e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
e_scatter(serie = value, symbolSize = 3) %>% 
    e_tooltip(trigger = "item",
    formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
    ) %>% 
e_legend(textStyle = list(fontSize = 8),type = 'scroll') %>% 
   e_hide_grid_lines() %>% 
  e_x_axis(name = "Age",
       nameTextStyle = list(fontSize = 8),
      axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",textStyle = list(fontSize = 8),
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE))%>% 
    e_grid(left = "20%", right = "20%", bottom = "15%")
)


#CVD_Status
(prevalence_plot_CVD_Status <- prevalence[[ 'CVD_Status' ]] %>% 
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(height='200px',width='300px',Age) %>% 
  e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
e_scatter(serie = value, symbolSize = 3) %>% 
    e_tooltip(trigger = "item",
    formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
    ) %>% 
  e_legend(textStyle = list(fontSize = 8),type = 'scroll') %>% 
   e_hide_grid_lines() %>% 
  e_x_axis(name = "Age",
       nameTextStyle = list(fontSize = 8),
      axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",textStyle = list(fontSize = 8),
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
    e_grid(left = "20%", right = "20%", bottom = "15%")
  
)


