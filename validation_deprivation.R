
library(readxl)
soa_mdm <- read_excel('./data/NIMDM17_SOAresults.xls',sheet='MDM')
soa_mdm<- soa_mdm[1:5]
names(soa_mdm) <- 
c("LGD2014NAME",                                                             
"Urban",                                                
"SOA2001",                                                                 
"SOA2001_name",                                                            
"mdm_rank")


soa <- soa_pop %>% 
  left_join(soa_mdm, 
            by=c('area_code' = 'SOA2001',
                 'area_name' = 'SOA2001_name')) %>% 
  left_join(townsend,
            by=c('LGD1992'='townsend_geo_label')) 


#------------------------------------------------------
soa_pop %>% 
  distinct(LGD1992,area_code)%>% 
  
  left_join(soa_mdm, 
            by=c('area_code' = 'SOA2001') )  %>% 
  group_by(LGD1992) %>% 
  summarise(avg_mdm = mean(mdm_rank)) %>% 
  
  left_join(townsend,
            by=c('LGD1992'='townsend_geo_label')) %>% 
  
  ggplot()+
  geom_point(aes(avg_mdm, townsend_TDS))+
  geom_smooth(method = 'lm',aes(avg_mdm, townsend_TDS))

#-------------------------------------------------
soa_pop %>% 
  distinct(LGD1992,area_code)%>% 
  
  left_join(soa_mdm, 
            by=c('area_code' = 'SOA2001') )  %>% 
  
  left_join(townsend,
            by=c('LGD1992'='townsend_geo_label')) %>% 
  
  ggplot()+
  geom_point(aes(mdm_rank, townsend_TDS),alpha=0.3) +
   geom_smooth(method = 'lm',aes(mdm_rank, townsend_TDS))

    #-------------------------------------------------
################    THIS IS THE WAY !!!!!! ##################

tsa <- read_csv( col_names = FALSE ,"data/new.csv")
tsa <- tsa[c(2,4,5)]
names(tsa) <- c('sa','townsend_score','townsend_quintile')

#mdm10_oa <- read_excel(sheet='MDM 2010',"data/Copy of NIMDM_2010_Results_OA (1).xls")

mdm17_sa <- read_excel("data/NIMDM17_SA - for publication (2).xls", 
    sheet = "MDM")

mdm17_sa <- mdm17_sa[c(3,5)] 

names(mdm17_sa) <- c('sa', 'mdm')

mdm <- mdm17_sa %>% left_join(tsa)

mdm %>% 
  ggplot(aes(x = mdm,townsend_score) ) +
  geom_point(alpha=0.4) 
  
mdm %>% 
  ggplot(aes(x = I(sqrt( mdm)),townsend_score)) +
  geom_point(alpha=0.4) +
  geom_smooth(method = 'loess')
summary(lin)
lin = lm(data = mdm[c('townsend_score','mdm')],formula = townsend_score ~ I(sqrt( mdm)))
plot(x = lin$fitted.values, mdm$townsend_score)

mdm$new=
  -0.15*sqrt(mdm$mdm)+7

(1-accumulate(.f=function(x,y){x*y},.x = rep(0.96,15),.init=0.96)) %>% 
  plot() %>% 
  line(xy.coords(c(0,0),c(16,0.47)))

