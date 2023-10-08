webr::install("dplyr")
webr::install("htmltools")
webr::install("glue")
webr::install("rlang")
webr::install("bslib")

library(dplyr)

# Data
load(url("https://raw.githubusercontent.com/nrennie/tidytuesday-shiny-app/main/data/all_weeks.RData"))
all_titles <- all_weeks$title
all_pkgs <- dplyr::select(all_weeks, -c(year, week, title, pkgs, code_fpath, img_fpath))
all_pkgs <- colnames(all_pkgs)

# Define UI
ui <- bootstrapPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "morph"),
  htmltools::div(
    class = "container-fluid",
    htmltools::br(),
    titlePanel("#TidyTuesday"),
    htmltools::div(
      class = "row",
      htmltools::div(
        class = "col-lg-6",
        markdown("[Nicola Rennie](https://github.com/nrennie)

#TidyTuesday is a weekly data challenge aimed at the R community. Every week a new dataset is posted alongside a chart or article related to that dataset, and ask participants explore the data. You can access the data and find out more on [GitHub](https://github.com/rfordatascience/tidytuesday/blob/master/README.md).

My contributions can be found on [GitHub](https://github.com/nrennie/tidytuesday), and you can use this Shiny app to explore my visualisations with links to code for each individual plot. You can also follow my attempts on Mastodon at [fosstodon.org/@nrennie](https://fosstodon.org/@nrennie).
"),
        htmltools::hr(),
        # packages
        htmltools::tags$details(
          htmltools::tags$summary("Filter R packages (click to expand):"),
          shiny::radioButtons("pkg_select",
            "Only show plots that use:",
            choices = c("Any package", all_pkgs),
            selected = NULL,
            inline = TRUE
          )
        ),
        # choose a plot
        shiny::uiOutput("select_img"),
        # display information
        shiny::textOutput("pkgs_used"),
        htmltools::br(),
        shiny::htmlOutput("code_link"),
        htmltools::br(),
        shiny::htmlOutput("r4ds_link"),
        htmltools::br()
      ),
      htmltools::div(
        class = "col-lg-6",
        # show plot
        shiny::htmlOutput("plot_img")
      )
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
    shiny::selectInput("plot_title",
      "Select a plot:",
      choices = rev(all_titles()),
      width = "90%"
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
      "This plot uses the following packages: {week_data()$pkgs}"
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
    glue::glue(
      "https://github.com/rfordatascience/tidytuesday/blob/master/data/{week_data()$year}/{week_data()$week}/readme.md"
    )
  })

  output$r4ds_link <- shiny::renderText({
    glue::glue('<b>R4DS GitHub link</b>: <a href="{r4ds_path()}"  target="_blank">{r4ds_path()}</a>.')
  })
}

# Create Shiny app
app <- shinyApp(ui = ui, server = server)
