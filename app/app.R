# Data
all_weeks <- openxlsx::read.xlsx("https://github.com/nrennie/tidytuesday-shiny-app/raw/main/data/all_weeks.xlsx")
all_titles <- all_weeks$title
all_pkgs <- all_weeks |>
  dplyr::select(-c(year, week, title, pkgs, code_fpath, img_fpath)) |>
  colnames()

# Define UI
ui <- shiny::bootstrapPage(
  title = "#TidyTuesday",
  theme = shinythemes::shinytheme("superhero"),
  htmltools::div(
    class = "container-fluid",
    htmltools::div(
      class = "row",
      htmltools::div(
        class = "col-lg-6",
        htmltools::includeMarkdown("intro.md"),
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
        shiny::selectInput("plot_title",
          "Select a plot:",
          choices = rev(all_titles),
          width = "90%"
        ),
        # display information
        shiny::textOutput("pkgs_used"),
        shiny::htmlOutput("code_link"),
        shiny::htmlOutput("r4ds_link")
      ),
      htmltools::div(
        class = "col-lg-6",
        # show plot
        htmltools::br(),
        shiny::htmlOutput("plot_img"),
        htmltools::br()
      )
    )
  )
)

server <- function(input, output, session) {
  # Get data
  week_data <- reactive({
    all_weeks |>
      dplyr::filter(title == input$plot_title)
  })

  observe({
    if (input$pkg_select == "Any package") {
      all_titles <- all_weeks$title
    } else {
      all_titles <- all_weeks |>
        dplyr::filter(!!rlang::sym(input$pkg_select) == 1) |>
        dplyr::pull(title)
    }

    shiny::updateSelectInput(session, "plot_title",
      label = "Select a plot:",
      choices = rev(all_titles)
    )
  })

  ### Image display
  img_path <- shiny::reactive({
    glue::glue("https://raw.githubusercontent.com/nrennie/tidytuesday/main/{week_data()$img_fpath}")
  })

  output$plot_img <- shiny::renderText({
    c('<img src="', img_path(), '" width="100%">')
  })

  ### List of packages
  output$pkgs_used <- shiny::renderText({
    glue::glue(
      "This plot uses the following packages: {week_data()$pkgs}")
  })

  ### Code link
  code_path <- shiny::reactive({
    glue::glue(
      "https://github.com/nrennie/tidytuesday/tree/main/{week_data()$code_fpath}")
  })

  output$code_link <- shiny::renderText({
    glue::glue(
      '<b>Code is available at</b>: <a href="{code_path()}"  target="_blank">{code_path()}</a>.')
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

# Create Shiny app ----
shiny::shinyApp(ui = ui, server = server)
