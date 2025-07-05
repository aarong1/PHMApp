
m10y <- data.frame(forecast = 1:10, multiplier = 1, type = 'default')

proposed <- expand.grid(forecast = 1:10, multiplier = c(seq(0.25,0.75,0.25),seq(1.25,5,0.25)), type='proposed')


rbind(m10y, proposed) %>% 
  group_by(type) %>% 
   mutate(size = 25,
          color = 'lightgreen') %>% 
   e_charts(forecast) %>% 
    echarts4r::e_scatter(serie = multiplier,
                        size = size) %>%
  e_theme_custom('{"color":["orange","white"]}')


 #e_theme("mytheme")
  #e_theme_custom('{"color":["#000000","#FFFFFF"]}', name = "myTheme")

   # e_x_axis(
   #    min = -1,
   #    max = 12,
   #    axisLine = list(show = FALSE)) %>% 
   #    e_y_axis(
   #      min = 0,
   #      max = 5,
   #      axisLine = list(show = FALSE))
 
 
   
prevalence <- readRDS('./trends_data.rds')
prevalence <- prevalence[['diabetes']]
  
  
prevalence %>% 
  pivot_longer(cols = -Age) %>% 
  group_by(name) %>% 
  e_charts(Age) %>% 
  e_scatter(serie = value)
