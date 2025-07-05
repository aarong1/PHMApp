library(readxl)
library(readODS)

lgd_pop <- read_excel("data/MYE22-gender-SYA-lgd2014.xlsx", 
    sheet = "Flat")

# View(lgd_pop)

lgd_pop %>% 
  filter(area_code!='N92000002', # exclude Northern Ireland
         year==max(year),
         sex != 'All persons') %>% 
  select(-c(year,area))

# https://www.nisra.gov.uk/publications/2020-mid-year-population-estimates-northern-ireland
soa_pop <- read_excel("data/MYE20-SOA-WARD (1).xlsx", 
    sheet = "Flat")
#View(soa_pop)

soa_pop <- soa_pop %>% 
  filter( 
  area=='1. Super Output Areas', # exclude Northern Ireland
         year==max(year),
         gender != 'All persons',
  age!='All ages') %>% 
    select(-c(year,area))

names(soa_pop)[c(5,6)] <- c('ageband','pop')

#https://statistics.ukdataservice.ac.uk/dataset/2011-uk-townsend-deprivation-scores 
#local authority
townsend <- read_csv("data/townsend Scores- 2011 UK Local Authority.csv")
names(townsend) <- paste0('townsend_',names(townsend))
# View(townsend)

#https://www.nisra.gov.uk/publications/nimdm17-soa-level-results
soa_mdm <- read_excel('./data/NIMDM17_SOAresults.xls',sheet='MDM')
soa_mdm<- soa_mdm[1:5]
names(soa_mdm) <- 
c("LGD2014NAME",                                                             
"Urban",                                                
"SOA2001",                                                                 
"SOA2001_name",                                                            
"mdm_rank")

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

