

townsend <- read.fst('./preprocessed_data/townsend.fst')
lgd_pop <- read.fst('./preprocessed_data/lgd_pop.fst')
soa_pop <- read.fst('./preprocessed_data/soa_pop.fst')
soa_mdm <- read.fst('./preprocessed_data/soa_mdm.fst')

# soa_lgd24 <- read_ods(skip = 2,
#          sheet = 'SOA2001_2_LGD2014',
#          path='./data/Lookup-Table-SA-OA-and-SOA-to-LGD2014-(statistical-geographies)-2013.ods')

soa <- soa_pop %>% 
  
  left_join(soa_mdm, 
            by=c('area_code' = 'SOA2001',
                 'area_name' = 'SOA2001_name')) %>% 
  
  left_join(townsend,
            by=c('LGD1992'='townsend_geo_label')) %>% 
  
  # left_join(soa_lgd24,
  #           by=c('area_code' = 'SOA2001'))

  mutate(bottom_bound = 
           case_when(
    ageband == '00-15' ~ 0,
    ageband == '16-39' ~ 16,
    ageband == '40-64' ~ 40,
    ageband == '65+'  ~ 65),
    
   top_bound = 
           case_when(
    ageband == '00-15' ~ 15,
    ageband == '16-39' ~ 39,
    ageband == '40-64' ~ 64,
    ageband == '65+'  ~ 90)) %>% 
  mutate(sample_weight=pop/sum(pop)) %>% 
  rename(soa_code = area_code, soa_name = area_name) %>% 
  rowwise() %>% 
  mutate(Age = round(runif(n = 1,min=bottom_bound-0.5,max=top_bound+0.5)))

# https://www.nisra.gov.uk/publications/geography-lookup-tables


#Age
# deprivation
# gender

(
  soa %>%
    count(Age,wt = pop,name = 'pop') %>% 
    e_charts(Age) %>%
    e_theme_custom('{"color":["black","rgb(85,172,189)","rgb(255, 0, 255)","rgb(255, 165, 0)","rgb(255, 215, 0)"]}') %>%
    e_bar(serie = pop)
  )

