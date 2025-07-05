
library(shiny)
# library(RSQLite)
# library(shinyalert)
library(stringr)
# library(AzureRMR)
# library(AzureStor)
# library(keyring)
library(tidyverse)
# library(sqldf)
library(odbc)
library(tibble)

ui <- fluidPage(
  
  actionButton('input', 'input'),
  numericInput('no_input',label = 'insert value into db',value = 100,min=1,max=1000),
  selectizeInput(inputId = 'server',label='label',
                 choices = list(
                   'prod' = 'swhscphipprduks01.sql.azuresynapse.net',
                   'dev' = 'swhscphipdevuks01.sql.azuresynapse.net')),
  selectizeInput(inputId ='auth',label='label',
                 choices = c('service_principle','pw'))
  
)

server_prd <- 'swhscphipprduks01.sql.azuresynapse.net'
Sys.setenv('server_prod'='swhscphipprduks01.sql.azuresynapse.net')
server_dev <- 'swhscphipdevuks01.sql.azuresynapse.net'
Sys.setenv('server_prod'='swhscphipprduks01.sql.azuresynapse.net')
tenant_id <- '9c9a30de-d8d7-4aa4-9600-4be7625ff6c5'
Sys.setenv('server_prod'='swhscphipprduks01.sql.azuresynapse.net')
client_id <- '65019715-c715-4f4f-abbc-2eb220e34215'
Sys.setenv('server_prod'='swhscphipprduks01.sql.azuresynapse.net')
secret <- 'HJj8Q~7belVreOG4lJwcJJpSeXoZ3vW.tkrZsc4L'
Sys.setenv('server_prod'='swhscphipprduks01.sql.azuresynapse.net')


database <- "exploratorydb"
driver <- "{ODBC Driver 17 for SQL Server}"#"{SQL SERVER DRIVER}" #




# odbc::dbGetQuery(con,statement = '
# SELECT TOP (100) [SOA2001]
# ,[SOA2001_name]
# ,[Deprivation Index]
# ,[DeprivationScore]
# FROM [dbo].[Deprivation]')
# 
# odbc::dbGetQuery(con,statement = 'SELECT TOP (100) [col1]
#  FROM [dashboard_configuration].[aaronG_dashboard_read_write]') 


  server <- 'swhscphipprduks01.sql.azuresynapse.net'
  server = 'swhscphipdevuks01.sql.azuresynapse.net'
  tenant_id <- '9c9a30de-d8d7-4aa4-9600-4be7625ff6c5'
  client_id <- '65019715-c715-4f4f-abbc-2eb220e34215'
  secret <- 'HJj8Q~7belVreOG4lJwcJJpSeXoZ3vW.tkrZsc4L'
  #gen2_user <- Sys.getenv("GEN2_USER")
  #gen2_pw <- Sys.getenv("GEN2_PW")

server <- function(input, output, session){
  
  observeEvent(input$input,{
    if(input$auth == 'pw'){
      UID = 'aaron.gorman@hscni.net'
      PWD = 'Ireland2@'
      Authentication = 'ActiveDirectoryPassword'
    }else{
      UID = client_id
      PWD = secret
      Authentication = 'ActiveDirectoryServicePrincipal'
    }
    server <- input$server
    con <- dbConnect(
      odbc::odbc(),
      Driver = driver,
      Database = database,
      Server = server,
      UID = UID,
      PWD = PWD,
      Authentication = Authentication
      # UID = client_id,
      # PWD = secret,
      # Authentication = 'ActiveDirectoryServicePrincipal',
      #  Authentication = 'ActiveDirectoryMsi'
    )
    
    odbc::dbGetQuery(con,statement = paste0('INSERT INTO [dashboard_configuration].[Table] (col1)
VALUES (',input$no_input,');'))
    
  })
  


  
  session$onSessionEnded(function() { })
  
}

shinyApp (ui=ui , server=server)
