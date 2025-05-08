library(shiny)
library(dplyr)
library(htmltools)
library(glue)
library(rlang)
library(shinythemes)
library(shinyWidgets)

# Data
load(url("https://raw.githubusercontent.com/nrennie/tidytuesday/main/data/all_weeks.RData"))
all_titles <- all_weeks$title
long_pkgs <- all_weeks |>
  dplyr::select(code_type, pkgs) |>
  dplyr::mutate(code_type = factor(code_type, levels = c("JavaScript", "Python", "R"))) |>
  tidyr::separate_longer_delim(pkgs, ", ") |>
  dplyr::distinct() |>
  dplyr::arrange(code_type, stringr::str_to_lower(pkgs))
pkg_choices <- c(list("Any package" = list("Any package")), lapply(split(long_pkgs$pkgs, long_pkgs$code_type), as.list))

# Define UI for app that draws a histogram ----
ui <- fluidPage(

  theme = shinytheme("darkly"),

  titlePanel("TidyTuesday"),

  sidebarLayout(

    sidebarPanel(
      markdown("
TidyTuesday is a weekly data challenge where each week a new dataset is posted alongside a chart or article related to that dataset, and participants are asked to explore the data. You can access the data and find out more on [GitHub](https://github.com/rfordatascience/tidytuesday/blob/master/README.md).

My contributions can be found on [GitHub](https://github.com/nrennie/tidytuesday), and you can use this Shiny app to explore my visualisations with links to code for each individual plot.
"),
htmltools::hr(),
shinyWidgets::pickerInput(
  inputId = "pkg_select",
  "Only show plots that use:",
  choices = pkg_choices
),
# choose a plot
shiny::uiOutput("select_img"),
# display information
shiny::textOutput("pkgs_used"),
htmltools::br(),
shiny::htmlOutput("code_link"),
htmltools::br(),
shiny::htmlOutput("r4ds_link"),
htmltools::br(),
width = 6
    ),

mainPanel(
  shiny::htmlOutput("plot_img"),
  htmltools::br(),
  width = 6
)
  )
)

server <- function(input, output) {
  # Get data
  all_titles <- reactive({
    req(input$pkg_select)
    if (input$pkg_select == "Any package") {
      all_titles <- all_weeks$title
    } else {
      all_titles <- all_weeks %>%
        dplyr::filter(!!rlang::sym(input$pkg_select) == 1) %>%
        dplyr::pull(title)
    }
  })

  # Select title
  output$select_img <- renderUI({
    shinyWidgets::pickerInput(
      inputId = "plot_title",
      "Select a plot:",
      choices = rev(all_titles())
    )
  })

  # Get data
  week_data <- reactive({
    req(input$plot_title)
    dplyr::filter(all_weeks, title == input$plot_title)
  })

  ## Image display
  img_path <- shiny::reactive({
    glue::glue("https://raw.githubusercontent.com/nrennie/tidytuesday/main/{week_data()$img_fpath}")
  })

  output$plot_img <- shiny::renderText({
    c('<img src="', img_path(), '" width="100%">')
  })

  ### List of packages
  output$pkgs_used <- shiny::renderText({
    glue::glue(
      "This plot uses the following packages or libraries: {week_data()$pkgs}"
    )
  })

  ### Code link
  code_path <- shiny::reactive({
    glue::glue(
      "https://github.com/nrennie/tidytuesday/tree/main/{week_data()$code_fpath}"
    )
  })

  output$code_link <- shiny::renderText({
    glue::glue(
      '<b>Code is available at</b>: <a href="{code_path()}"  target="_blank">{code_path()}</a>.'
    )
  })

  ### R4DS link
  r4ds_path <- shiny::reactive({
    if (week_data()$year == "2021") {
      reformat_week <- as.character(as.Date(week_data()$week, format = "%d-%m-%Y"))
      glue::glue(
        "https://github.com/rfordatascience/tidytuesday/blob/master/data/{week_data()$year}/{reformat_week}/readme.md"
      )
    } else {
      glue::glue(
        "https://github.com/rfordatascience/tidytuesday/blob/master/data/{week_data()$year}/{week_data()$week}/readme.md"
      )
    }
  })

  output$r4ds_link <- shiny::renderText({
    glue::glue('<b>DSLC data source</b>: <a href="{r4ds_path()}"  target="_blank">{r4ds_path()}</a>.')
  })
}

shinyApp(ui = ui, server = server)
