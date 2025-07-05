
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
#https://learn.microsoft.com/en-us/sql/connect/odbc/using-azure-active-directory?view=sql-server-ver16
#https://stackoverflow.com/questions/55126935/how-to-connect-via-r-to-ms-sql-database-requiring-integrated-active-directory-au
#https://solutions.posit.co/connections/db/best-practices/drivers/
#Proxy gateway address - webgw.hscni.net
#Port - 8080
#If the application you use requires protocol for the proxy address, use [http://]http://

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
driver <- "{ODBC Driver 18 for SQL Server}"#"{SQL SERVER DRIVER}" #

  server <- 'swhscphipprduks01.sql.azuresynapse.net'
  server = 'swhscphipdevuks01.sql.azuresynapse.net'
  tenant_id <- '9c9a30de-d8d7-4aa4-9600-4be7625ff6c5'
  client_id <- '65019715-c715-4f4f-abbc-2eb220e34215'
  secret <- 'HJj8Q~7belVreOG4lJwcJJpSeXoZ3vW.tkrZsc4L'
  #gen2_user <- Sys.getenv("GEN2_USER")
  #gen2_pw <- Sys.getenv("GEN2_PW")

      UID = 'aaron.gorman@hscni.net'
      PWD = 'Ireland2@'
      Authentication = 'ActiveDirectoryPassword'

      
      UID = client_id
      PWD = secret
      Authentication = 'ActiveDirectoryServicePrincipal'

    con <- dbConnect(
      odbc::odbc(),
      Driver = driver,
      Database = database,
      Server = server,
      UID = UID,
      # PWD = PWD,
      Authentication = 'ActiveDirectoryIntegrated'
      #UID = client_id,
      # PWD = secret,
      #Authentication = 'ActiveDirectoryServicePrincipal',
      #Authentication = 'ActiveDirectoryMsi'
      #Authentication = 'ActiveDirectoryInteractive'

          )
    
    odbc::dbGetQuery(con,statement = paste0('INSERT INTO [dashboard_configuration].[Table] (col1)
VALUES (',input$no_input,');'))
    
 