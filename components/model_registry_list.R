library(shiny)
library(htmltools)
library(sparkline)
library(dplyr)
library(purrr)

# Example data backing your “registry”
models <- tibble::tibble(
  name      = c("Margaret Arellano", "Charles Robinson", "Michael Nguyen",
                "Robert Boyer", "Jade Curry", "Gregory Wilkins",
                "Carla Fernandez", "Daniel Chavez", "Mary Thomas", "Erin Smith"),
  email     = c("richard.stewart@hscni.net", "tyler.bright@hscni.net",
                "deanna.norris@hscni.net", "michelle.bradley@hscni.net",
                "dana.hernandez@hscni.net", "chelsea.reed@hscni.net",
                "emily.freeman@hscni.net", "alexis.day@hscni.net",
                "david.chen@hscni.net", "maria.bradley@hscni.net"),
  risk1     = "hypertension",
  risk2     = "cholesterol",
  age_band  = c("40-49","60-69","30-39","60-69","60-69",
                "20-29","30-39","40-49","60-69","80-89"),
  model_id  = 1:10,
  spark_vals = list(
    1:10,1:10,1:10,1:10,1:10,1:10,1:10,1:10,1:10,1:10
  )
)

render_model_registry <- function(df) {
  tags$div(
    style = "width:100%;font-size:80%;", #overflow:scroll;height:100vh;
    tags$div(
      class = "d-flex align-items-center justify-content-center m-5",
      tags$div(
        id    = "model_registry",
        class = "table table-borderless w-100",
        tags$div(
          tagList(
            imap(seq_len(nrow(df)), function(i, idx) {
              row <- df[i, ]

              # row_class <- if (i == 1) {
              #   "odd selected"
              # } else if (i %% 2 == 0) {
              #   "even"
              # } else {
              #   "odd"
              # }

              tags$div(
                class = 'row_class',
                # Col 1: person + tags
                tags$div(class = "d-inline",
                  div(
                    class = "p-2 hv d-inline",
                    h5(row$name),
                    p(class = "wdr-ui-element", row$email),
                    span(class = "badge rounded-pill text-bg-primary p-2", row$risk1),
                    span(class = "badge rounded-pill text-bg-warning d-inline p-2", row$risk2),
                    span(class = "badge rounded-pill text-bg-secondary d-inline p-2", row$age_band)
                  )
                ),
                # Col 2: model label + id
                tags$div(class = "d-inline ps-5",
                  h4(class = "d-inline","Model"),
                  h4(class = "d-inline", row$model_id),
                ),
                  p(class = "ps-5", 'ow[ejn;oe; qvon[oq qw[inv[oqengklqnvo[q')
                # Col 3: sparkline
                # tags$td(
                #   sparkline::sparkline(
                #     unlist(row$spark_vals),
                #     width  = 60,
                #     height = 20,
                #     lineColor = "green"
                #   )
                # )
              )
            })
          )
        )
      )
    )
  )
}

ui <- page_fluid(
  tags$head(
    tags$style(HTML("
      #model_registry div.row_class {
        padding:15px;
        transition: all 0.3s ease;
      }
      #model_registry div.row_class:hover {
        border-radius: 20px;
        box-shadow: 4px 4px 10px #bebebe, -4px -4px 10px #ffffff;
        transform: translateX(5px);
      }
    "))
  ),
  render_model_registry(models)
)

server <- \(input, output, session) {}

shinyApp(ui, server)
