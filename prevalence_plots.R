prevalence <- readRDS("trends_data.rds")
names(prevalence)
# [1] "alcohol_consumption"   "physical_activity"     "fruit_veg_consumption"
# [4] "bmi_level"             "cigerette_smoking"     "high_cholosterol"     
# [7] "diabetes"              "hypertension"          "CVD_Status"      

#residualise out the graph settings
plot_aesthetics <- function(x){
 
  x |> 
  e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
  e_tooltip(trigger = "item",triggerOn = "mousemove|click", alwaysShowContent = TRUE,
            formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
  ) %>% 
  e_color(color = c('#dd6b66',
                    '#759aa0',
                    '#e69d87',
                    '#8dc1a9',
                    '#ea7e53',
                    '#eedd78',
                    '#73a373',
                    '#73b9bc',
                    '#7289ab',
                    '#91ca8c',
                    '#f49f42')) |> 
    
  e_legend(textStyle = list(fontSize = 8),
           type = 'scroll') %>% 
  e_hide_grid_lines() %>% 
    e_x_axis(#name = "Age",
             nameTextStyle = list(fontSize = 8),
             axisLine = list(show = FALSE),
             axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
    e_y_axis(
      name = "Prevalence (%)",textStyle = list(fontSize = 8),
      axisLine = list(show = TRUE),
      axisTick = list(show = FALSE),     
      axisLabel = list(show = TRUE)) %>% 
    
  e_grid(left = "20%", right = "20%", bottom = "35%")
}


# hypertension
(prevalence_plot_hypertension <- prevalence[[ 'hypertension' ]] %>% 
    rename('hypertension'='Yes') %>% 
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(height='200px',width='300px',Age) %>% 
    e_scatter(serie = value, symbolSize = 3) %>% 
    
    plot_aesthetics()
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
data %>%
  e_charts(x) %>%
  e_area(y, smooth = TRUE,
    color = list(
      type = "cubic", # Gradient type
      x = 0, # Start point x
      y = 0, # Start point y
      x2 = 0, # End point x2
      y2 = 1, # End point y2
      colorStops = list(
        list(offset = 0, color = 'lightgreen'),#"#13b5ca"), # Top color
        list(offset = 1, color = "white") # Top color

      )
    )
  ) %>%   e_hide_grid_lines() %>% 
  e_x_axis(name = "Age",
       nameTextStyle = list(fontSize = 8),
      axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",textStyle = list(fontSize = 8),
        axisLine = list(show = FALSE),
        axisTick = list(show = FALSE),     axisLabel = list(show = FALSE))%>% 
    e_grid(left = "10%", right = "10%", bottom = "15%")%>% 
    e_tooltip(trigger = "item",triggerOn = "mousemove|click", alwaysShowContent = TRUE,
    formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")
    )

4#e_line(serie=value,showSymbol = FALSE))
    #e_scatter(serie = value))

# alcohol_consumption
(prevalence_plot_alcohol <- prevalence[[ 'alcohol_consumption' ]] %>% 
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(height='200px',width='300px',Age) %>% 
  e_text_style(fontSize = 7) %>% # Set global font size  e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
 e_scatter(serie = value, symbolSize = 3) %>% 
    e_tooltip(trigger = "item",triggerOn = "mousemove|click", alwaysShowContent = TRUE,
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
    e_tooltip(trigger = "item",triggerOn = "mousemove|click", alwaysShowContent = TRUE,
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
    e_tooltip(trigger = "item",triggerOn = "mousemove|click", alwaysShowContent = TRUE,
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
        axisTick = list(show = FALSE),
       axisLabel = list(show = FALSE)) %>% 
      e_y_axis(
    name = "Prevalence (%)",textStyle = list(fontSize = 0),
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
    e_tooltip(trigger = "item",triggerOn = "mousemove|click", alwaysShowContent = TRUE,
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
    e_tooltip(trigger = "item",triggerOn = "mousemove|click", alwaysShowContent = TRUE,
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
    e_tooltip(trigger = "item",triggerOn = "mousemove|click", alwaysShowContent = TRUE,
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
    e_tooltip(trigger = "item",triggerOn = "mousemove|click", alwaysShowContent = TRUE,
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
    e_grid(left = "20%", right = "20%", bottom = "25%")
  
)


