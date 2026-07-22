library(readxl)
# eth <- read_excel("data/census-2021-ethnicity_age_geo.xlsx", 
#                   sheet = "MS-B26", skip = 8)
# 
# eth <- eth[1:12,]
# 
# eth_absolute <- eth %>%
#   pivot_longer(cols = -c(Geography, `Geography code`), 
#                names_to = "Category", values_to = "Count") %>%
#   mutate(
#     `Age Group` = str_extract(Category, "aged \\d+\\+? years"),
#     Ethnicity = str_extract(Category, ":\\s*(.*)") %>% str_remove(":\\s*"),
#     `Age Group` = ifelse(is.na(`Age Group`), "All Ages", `Age Group`),
#     Ethnicity = ifelse(is.na(Ethnicity), "All Ethnicities", Ethnicity)
#   ) %>%
#   select(-Category)

# # view(eth)
# 
# eth_percent  <- read_excel("data/census-2021-ethnicity_age_geo.xlsx", 
#                            sheet = "MS-B26", skip = 23)
# # View(lgd_eth)
# 
# 
# # qrisk–
# # white (or not stated)
# # indian
# # pakistani
# # bangladeshi
# # other asian
# # black caribbean
# # black african
# # chinese
# # other ethnic group
# 
# # nisra
# # white
# # irish traveller (can we call white)
# # roma
# # indian
# # chinese
# # filipino
# # pakistani
# # arab
# # other asian
# # black african
# # black other
# # mixed
# # other
# 
# ##################################################
# ############# nisra - qrisk mapping --------------
# ##################################################
# 
# risk_mapping <- c("white" = "white (or not stated)",
#                   "irish traveller" =  "white (or not stated)",
#                   "roma" = "white (or not stated)",
#                   "indian" = "indian",
#                   "chinese" = "chinese",
#                   "filipino" = "other asian",
#                   "pakistani" = "pakistani",
#                   "arab" = "other asian",
#                   "other asian" = "other asian",
#                   "black african" = "black african",
#                   "black other" = "black carribean",
#                   "mixed" = "other ethnic group",
#                   "other" = "other ethnic group") |> 
#   data.frame() |> 
#   rename('health_ethnicity' = 1) |> 
#   rownames_to_column(var = 'nisra_ethnicity')
# 
# qrisk_encoding <- data.frame(
#   health_ethnicity = c("white (or not stated)",
#                        "indian",
#                        "pakistani",
#                        "bangladeshi",
#                        "other asian",
#                        "black caribbean",
#                        "black african",
#                        "chinese",
#                        "other ethnic group"),
#   ethnicity_encoding = 1:9)
# 
# # Ethnicity codes
# # ONS2011 5+1
# # ONS 2011 18+1
# 
# eth_percent <- eth_percent |> 
#   pivot_longer(cols=-(1:2),names_sep = ': \r\n',names_to = c('age','ethnicity')) |> 
#   replace_na(replace = list(ethnicity='All')) |> 
#   mutate(
#     # Extract the age range using regular expressions
#     age_min = str_extract(`age`, "\\d+(?=-)"),     # Extracts the number before the hyphen
#     age_max = str_extract(`age`, "(?<=-)\\d+"),    # Extracts the number after the hyphen
#     # Convert to numeric
#     age_min = as.numeric(age_min),
#     age_max = as.numeric(age_max)
#   ) |> 
#   replace_na(list(age_min = 65, age_max = 105))
# 
# eth_percent <- eth_percent |> 
#   filter( age != "All usual residents" ,
#           ethnicity != "All" ,
#           Geography != "Northern Ireland"
#   )
# 
# eth_percent <- eth_percent |> 
#   pivot_wider(names_from = 'ethnicity',
#               values_from = 'value')
# 
# eth_percent 

eth_absolute <- read.fst( './preprocessed_data/eth_absolute.fst')


(
  absolute_ethnicity_facet_plot_echart <- eth_absolute |> 
  mutate(Count = as.numeric(Count)) |> 
  filter(`Geography code` != 'N92000002', 
         `Age Group` == 'All Ages') |> 
  filter(!Ethnicity %in% c('All Ethnicities','White')) |> 
  
  mutate(region = ifelse(Geography == 'Belfast',
                         'Belfast',
                         'Rest of NI') ) |>
  count(region,Ethnicity, wt = Count,name='Count') |> 
  arrange(desc(Count)) |> 
  group_by(Ethnicity) |> 
  e_charts(region, emphasis = list(focus = 'series' )) |> 
  e_bar(Count) |> 
  e_tooltip()
  
)

plot_aesthetics <- function(x){
  
  x |> 
    e_text_style(fontSize = 7) %>% # Set global font size  e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>% 
    
    e_color(color = c('#dd6b66',
                      '#759aa0',
                      '#73a373',
                      '#eedd78',
                      '#8dc1a9',
                      '#e69d87',
                      '#ea7e53',
                      '#73b9bc',
                      '#7289ab',
                      '#91ca8c',
                      '#f49f42')) |> 
    e_legend(textStyle = list(fontSize = 7),
             type = 'scroll') %>% 
    e_hide_grid_lines() %>% 
    e_x_axis(#name = "Age",
      nameTextStyle = list(fontSize = 7),
      axisLine = list(show = FALSE),
      axisTick = list(show = FALSE),    
      axisLabel = list(show = T)) %>% 
    e_y_axis(
      #name = "Prevalence (%)",
      textStyle = list(fontSize = 7),
      axisLine = list(show = FALSE),
      axisTick = list(show = FALSE),     
      axisLabel = list(show = TRUE)) %>% 
    e_grid(left = "20%", right = "20%", bottom = "15%")
}


soa <- st_read('soa.geojson')

# soa_map_pop <- read_excel("data/MYE20-SOA-WARD.xlsx", 
#                           sheet = "Flat") 

soa_map_pop <- read.fst("preprocessed_data/soa_map_pop.fst") 

gender_pop <- soa_map_pop |> 
  filter( 
    area == '1. Super Output Areas', # exclude Northern Ireland
    year == max(year),
    gender != 'All persons',
    age =='All ages') %>% 
  #e_tooltip() |> 
  count(gender,wt=MYE,name = 'Count') 

gender_pop_echarts <- gender_pop |> 
  e_chart(gender,               
          height='250px',
          width='250px'
  ) |> 
  e_bar(Count) |> 
  e_tooltip() |> 
  plot_aesthetics()

age_pop <- soa_map_pop |> 
  filter( 
    area == '1. Super Output Areas', # exclude Northern Ireland
    year == max(year),
    gender != 'All persons',
    age != 'All ages') %>% 
  count(age,gender,wt=MYE,name = 'Count') 

age_pop_echarts <- age_pop |> 
  group_by(gender) |> 
  e_chart(age,
          height='250px',
          width='250px') |> 
  e_bar(Count) |> 
  e_tooltip() |> 
  plot_aesthetics()

soa_map_pop <- soa_map_pop %>% 
  filter( 
    area=='1. Super Output Areas', # exclude Northern Ireland
    year==max(year),
    gender == 'All persons',
    age =='All ages') %>% 
  select(-c(year,area))

# soa <- left_join(soa,soa_map_pop,by =c('SOA_CODE'='area_code'))

# #https://www.nisra.gov.uk/publications/nimdm17-soa-level-results
# soa_mdm <- read_excel('./data/MDM17_SOAresults.xls',sheet='MDM')
# soa_mdm<- soa_mdm[1:5]
# names(soa_mdm) <- 
#   c("LGD2014NAME",                                                             
#     "Urban",                                                
#     "SOA2001",                                                                 
#     "SOA2001_name",                                                            
#     "mdm_rank")

#' soa_mdm <-  
#'   mutate( soa_mdm,
#'           mdm_decile = cut(mdm_rank,
#'                            breaks = 10,
#'                            labels = 1:10 )) |> 
#'   ungroup() |> 
#'   arrange(desc(mdm_rank))
#' 
#' soa <- soa %>% 
#'   left_join(soa_mdm, 
#'             by=c('SOA_CODE' = 'SOA2001'#,
#'                  #'area_name' = 'SOA2001_name'
#'             ))
#' 
#' townsend <- read_csv("data/townsend_SOA.csv")
#' names(townsend) <- paste0('townsend_',names(townsend))
#' 
#' soa <- soa |> 
#'   left_join(townsend,
#'             by = c('SOA_CODE' = 'townsend_GEO_CODE')
#'   )

##############-------------------------------

# Register and Plot

# file.remove('soa.geojson')
# st_write(soa,'soa.geojson',append = FALSE)
soa_json <- jsonlite::read_json("soa.geojson")

(x1 <- soa %>% 
    #head() |> 
    e_charts(mdm_rank,reorder = FALSE,width = '250px' ,height='250px') %>%
    e_scatter(MYE,
              bind=area_name, 
              name = 'SOA',
              legend = T,
              nameProperty = "area_name",
              itemStyle = list(
                opacity=0.2),
              emphasis = list(
                focus = 'self',
                itemStyle = list(
                  color = 'lightblue',
                  opacity=1)),
              symbol_size=8) |> 
    # e_labels() |> 
    # e_title("Population by Deprivation") %>%
    e_tooltip(trigger = "item", 
              triggerOn = "mousemove|click", 
              alwaysShowContent = FALSE,
              formatter = htmlwidgets::JS("
      function(params) {
      return `Area: ${params.name} <br> Population: ${Math.round(params.value[1])} <br> MDM Rank: ${Math.round(params.value[0])}`;
      }
    ")) |>  
    e_group('group') |> 
    plot_aesthetics()
)

(x2 <- soa %>%
    #rename(SOA_CODE=area_code) |> 
    #group_by(SOA_CODE ) |> 
    e_charts(area_name,reorder = FALSE,width = '250px' ,height='250px') %>%
    e_map_register("custom_map", soa_json) |> 
    e_map(serie=MYE, 
          name='SOA',
          roam=T,
          map = "custom_map", 
          itemStyle=list(
            borderColor ='white',
            borderWidth= 1
          ),
          #label=list(show=FALSE),
          emphasis = list(
            focus = 'self',
            itemStyle = list(
              color = 'lightblue',
              opacity=1)),
          nameProperty = "area_name") %>%
    e_tooltip(trigger = "item", 
              triggerOn = "mousemove|click", 
              formatter = htmlwidgets::JS("
  function(params) {
    return `Area: ${params.name} <br> Population: ${Math.round(params.value)}`;
  }"))  |> 
    e_zoom() |> 
    e_toolbox() |> 
    e_visual_map(serie = MYE,) |> 
    e_group('group') #|> 
  # e_connect_group('group')
)
#https://echarts.apache.org/examples/en/editor.html?c=map-usa

##############-------------------------------

(
  mdm_rank_tds <- soa |> 
    as.data.frame() %>%
    select(-geometry) |> 
    #group_by(Urban) |> 
    
    e_charts(townsend_TDS, reorder = FALSE,width = '250px' ,height='250px') %>%
    e_scatter(mdm_rank,
              itemStyle=list(opacity=0.6),
              name = 'SOA',
              bind = area_name, 
              nameProperty = "area_name",
              itemStyle = list(
                opacity=0.2),
              emphasis = list(
                focus = 'self',
                #label = list(show=T),
                itemStyle = list(
                  color = 'lightblue',
                  opacity=1)),
              symbol_size=7) %>%
    #e_title("Histogram Example") %>%
    #e_loess(legend = F, formula = mdm_rank ~ townsend_TDS,showSymbol = FALSE) %>%  # Adding best-fit line
    #e_color(c('blue','green','yellow')) |> 
    e_tooltip(trigger = "item", 
              triggerOn = "mousemove|click", 
              alwaysShowContent = FALSE,
              formatter = htmlwidgets::JS("
      function(params) {
        return `${params.name} <br> MDM Rank: ${Math.round(params.value[1])} <br> Townsend: ${Math.round(params.value[0]*10)/10}`;
      }
    ")) |> 
    plot_aesthetics() |> 
    e_group('group') |> 
    e_connect_group('group')
)

e_arrange(x1, mdm_rank_tds, x2, cols = 3)

browsable(
  div(
    div(x1), 
    div(mdm_rank_tds, x2)
  )
)

(density_graph <- soa %>%
    group_by(Urban) |> 
    e_charts(reorder=FALSE) %>%
    e_density(MYE,showSymbol =FALSE) %>%
    e_title("Histogram Example") %>%
    e_tooltip(trigger = "item", 
              triggerOn = "mousemove|click", 
              alwaysShowContent = TRUE,
              formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }")) |> 
    e_connect('group')|> 
    e_connect_group('group')
)


(h <- soa %>%
    group_by(Urban) |> 
    e_charts() %>%
    e_histogram(mdm_rank,showSymbol =FALSE) %>%
    e_title("Histogram Example") %>%
    e_tooltip(trigger = "item", 
              triggerOn = "mousemove|click", 
              alwaysShowContent = TRUE,
              formatter = htmlwidgets::JS("
      function(params) {
        return `${params.seriesName}: ${Math.round(params.value[1])}% (Age: ${params.value[0]})`;
      }
    ")) |> 
    e_connect('group')
)

(
  x1 <- soa %>% 
    #head() |> 
    group_by(Urban) |> 
    
    e_charts(x = MYE,elementId = 'group') %>%
    e_scatter(serie = mdm_rank,
              bind=area_name,
              name = 'mdm',
              
              #name = 'area_name',
              legend = T,
              symbol_size = 6,
              itemStyle = list(
                #color = "lightblue",  # Default color
                emphasis = list(
                  label=list(show=TRUE),
                  
                  selectorLabel = list(show=TRUE),
                  color = "red")
              )  # Color when hovered) 
    ) |> 
    # e_labels() |> 
    e_title("Population by Deprivation") %>%
    e_toolbox_feature() |> 
    e_tooltip(trigger = "item", 
              triggerOn = "mousemove|click", 
              alwaysShowContent = TRUE,
              #           formatter = htmlwidgets::JS("
              #   function(params) {
              #   console.log(params);
              #     return `<b>${params.seriesName} ${params.name}</b><br> MDM rank: ${Math.round(params.value[1])} <br>(Pop: ${params.value[0]})`;
              #   }
              # ")
    ) |> 
    # e_brush() |> 
    e_connect('map') |> 
    e_connect_group('group') |> 
    plot_aesthetics()
)


# e_arrange(soa_map,x1,cols=2)

#https://echarts.apache.org/examples/en/editor.html?c=map-usa


(
  x33 <- soa %>%
    st_drop_geometry() %>% 
    count(LGD1992,wt=MYE) %>%   # Aggregate by rank (or any grouping variable)
    #summarise(MYE = sum(MYE, na.rm = TRUE)) %>%
    e_charts(LGD1992, elementId = 'group') %>%
    e_bar(n,legend = F) %>%
    #e_visual_map(MYE) |> 
    e_title("Total Population") %>%
    e_tooltip(trigger = "item") %>%
    e_toolbox_feature() |> 
    e_connect(ids = c('group','map') )
)


(x3 <- soa %>% 
    # filter(row_number()<35) %>% #view()
    group_by(Urban) %>%   # Aggregate by rank (or any grouping variable)
    #summarise(MYE = sum(MYE, na.rm = TRUE)) %>%
    e_charts(LGD1992, elementId = 'group') %>%
    e_histogram(MYE, legend = F) %>%
    #e_visual_map(MYE) |> 
    e_title("Total Population by Rank") %>%
    e_tooltip(trigger = "item") %>%
    e_connect(ids = 'group') |> 
    e_toolbox_feature() |> 
    e_connect_group('group') 
) # Ensures linking across all charts


e_arrange(x3, x33, cols = 2)




(
  x6 <- soa |> group_by(Urban) |> mutate(mdm_decile=as.numeric(mdm_decile)) |> 
    e_charts(MYE) |> 
    e_scatter(mdm_rank, bind = area_name) |> 
    e_scatter(mdm_decile, bind = area_name, x_index = 1, y_index = 1) |> 
    e_grid(width = "35%") |> 
    e_grid(width = "35%", left = "55%") |> 
    e_y_axis(gridIndex = 1) |> # put x and y on grid index 1
    e_x_axis(gridIndex = 1) |> #add a theme
    e_brush() |> # add the brush
    e_tooltip() |> 
    e_datazoom(x_index = 0, type = "slider") |> 
    e_datazoom(y_index = 0, type = "slider") |> 
    e_connect_group('group') |> 
    e_connect('group'))

e_arrange(x1, x2, x6 ,cols = 2)
# e_arrange(x4,x5,cols = 2)

soa |> 
  e_charts(MYE) |> 
  e_scatter(mdm_rank,bind= area_name, coord_system = '1',legend=T,name = "mdm", rm_y = FALSE, rm_x = FALSE) |> # do not remove axis
  e_data(quakes, depth) |> # use e_data to add data and/or change value on x axis
  e_scatter(depth, mag, stations, name = "mag & depth") |>  # plot scatter
  e_grid(right = 40, top = 100, width = "30%") |> # adjust grid to avoid overlap
  e_y_axis(name = "depth", min = 3.5) |> # add y axis name
  e_x_axis(name = "magnitude") |> # add x axis name
  e_legend(FALSE) |>  # hide legend
  e_title("Built-in crosstalk", "Use the brush") |> # title
  e_theme("chalk") |> # add a theme
  e_brush() |> # add the brush
  e_tooltip() |> 
  e_datazoom(x_index = 0, type = "slider") |> 
  e_datazoom(y_index = 0, type = "slider") 



