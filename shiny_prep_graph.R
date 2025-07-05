
# risk factor list
library(purrr)
risk_factors_demographic <- c('age', 'gender',  'deprivation')

risk_factors_lifestyle <- c('smoking','bmi')

risk_factors_physiological <- c('diabetes','hypertension','chiolesterol')

outcomes <- c('chd','stroke')

#edge_list1 <- expand.grid(from = risk_factors_demographic,to = risk_factors_physiological)
#edge_list2 <- expand.grid(from = risk_factors_demographic, to=risk_factors_lifestyle)

edge_list1 <- data.frame(from = risk_factors_demographic, to ='demographic')
edge_list2 <- data.frame(from = 'demographic', to = 'lifestyle')
edge_list21 <- data.frame(from = risk_factors_physiological, to = 'physiological')
edge_list22 <- data.frame(from = 'lifestyle', to = 'physiological')
edge_list23 <- data.frame(from = risk_factors_lifestyle, to = 'lifestyle')
edge_list24 <- data.frame(from = 'physiological', to = 'risk engine')
edge_list3 <- data.frame(from = c(#risk_factors_demographic,
                                  #risk_factors_lifestyle,
                                  risk_factors_physiological), to = 'risk engine')

edge_list4 <- data.frame(from = 'risk engine',to = outcomes)



edgelist <- reduce(
  list(
  edge_list1,
  edge_list2,
 edge_list21,
edge_list22,
 edge_list23,
edge_list24,
#edge_list3,
edge_list4),rbind) %>% mutate(arrows='middle')

node_list1 <- data.frame(id = risk_factors_demographic, type = 'demographic')  
node_list2 <- data.frame(id = risk_factors_lifestyle, type = 'lifestyle')
node_list3 <- data.frame(id = risk_factors_physiological, type='physiological')
node_list4 <- data.frame(id = 'risk engine', type = 'engine')
node_list5 <- data.frame(id = outcomes, type = 'disease')
node_list6 <- data.frame(id = 'lifestyle', type= 'stock')

node_list7 <- data.frame(id = 'physiological', type= 'stock')
node_list8 <- data.frame(id = 'demographic', type= 'stock')

nodelist <- reduce(list(node_list1,
node_list2,
node_list3,
node_list4,
node_list5,
node_list6,
node_list7,
node_list8),rbind) %>%  
  mutate(label=id,
         color='rgb(25,65,105)',
         shadow=FALSE) %>% 
  mutate(color = case_when(
    type %in% c('engine') ~ 'red',
    type %in% c('stock') ~ 'lightgrey',
    type == 'disease' ~ 'orange',
    T ~ 'lightgreen'))

visNetwork(nodelist,edgelist)

a <- expand.grid(risk_factors_demographic,risk_factors_lifestyle)
b <- expand.grid(c(risk_factors_lifestyle,risk_factors_physiological),outcomes)


g <- rbind(a,b)

names(g) <- c('id','name')

#x <- igraph::graph_from_data_frame()
#visIgraph(igraph=x, layout="layout_as_tree", flip.y = TRUE)
#y <- toVisNetworkData(x)

#plot(x,layout=layout_as_tree)

# visNetwork::visNetwork(nodes = y$nodes, edges = y$edges) %>%
#   visPhysics(solver = 'barnesHut')

# prevalence %>% 
# plot_ly( x = ~Age, y = ~Yes, type = 'scatter') %>%
#     layout(shapes = list(
#                     #vertical line
#     
#                     #horizontal line
#                     list(type = "line", x0 = 0, x1 = 1,
#                             y0 = 0, y1 = 20, xref = "paper"))) %>%
#     # allow to edit plot by dragging lines
#     config(edits = list(shapePosition = TRUE))
# 
