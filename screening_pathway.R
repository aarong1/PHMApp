funnel <- data.frame(
  stage = c("Tests", "Preassesment", "Colonoscopy"),
  value = c(80, 30, 20)
)

funnel <- funnel |>
  e_charts(x = stage) |>
  e_funnel(value, stage) |> 
  e_tooltip()

#######----------------------------###########

sankey <- tribble(
  ~source, ~target, ~value,
"Tests", "Negative", 98,
"Tests", "Preasesssment", 2,
# "Negative",  'Tests', ,
#"Colonoscopy", 'Dropout', 25,
"Preasesssment", "Dropout",  25,
"Preasesssment", "Colonoscopy", 75,
"Colonoscopy", 'Dropout', 5,
"Colonoscopy", 'Cancer', 7,
'Colonoscopy', 'Adenoma/Other high risk' ,50,
"Colonoscopy", 'Other Surveillance', 33,
  )

# sankey <- sankey |> 
#   mutate(
#    value = ceiling(rnorm(n(), 10, 1))
# )

sankey <- sankey |>
  e_charts() |>
  e_sankey(source, target, value,
           itemStyle = list(borderColor = "white", borderWidth = 1),
           lineStyle = list(color = "source"),
           emphasis = list(label = list(show = TRUE, fontSize = 16)))
