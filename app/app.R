library(shiny)
all_weeks <- openxlsx::read.xlsx("https://github.com/nrennie/tidytuesday-shiny-app/raw/main/data/all_weeks.xlsx")
all_titles <- all_weeks$title
all_pkgs <- all_weeks |>
  dplyr::select(-c(year, week, title, pkgs, code_fpath, img_fpath)) |>
  colnames()

# Define UI
ui <- shiny::fluidPage(
  theme = shinythemes::shinytheme("superhero"),
  htmltools::includeMarkdown("intro.md"),
  hr(),
  # packages
  htmltools::tags$details(
    htmltools::tags$summary("Filter R packages (click to expand):"),
    radioButtons("pkg_select",
                 "Only show plots that use:",
                 choices = c("Any package", all_pkgs),
                 selected = NULL,
                 inline = TRUE
    )
  ),
  # choose a plot
  selectInput("plot_title",
              "Select a plot:",
              choices = rev(all_titles),
              width = "100%"
  ),
  # display information
  textOutput("pkgs_used"),
  htmlOutput("code_link"),
  htmlOutput("r4ds_link"),
  br(),
  # show plot
  htmlOutput("plot_img"),
  br()
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
    
    updateSelectInput(session, "plot_title",
                      label = "Select a plot:",
                      choices = rev(all_titles)
    )
  })
  
  ### Image display
  img_path <- reactive({
    glue::glue("https://raw.githubusercontent.com/nrennie/tidytuesday/main/{week_data()$img_fpath}")
  })
  
  output$plot_img <- renderText({
    c('<img src="', img_path(), '" width="100%">')
  })
  
  ### List of packages
  output$pkgs_used <- renderText({
    glue::glue("This plot uses the following packages: {week_data()$pkgs}")
  })
  
  ### Code link
  code_path <- reactive({
    glue::glue("https://github.com/nrennie/tidytuesday/tree/main/{week_data()$code_fpath}")
  })
  
  output$code_link <- renderText({
    glue::glue('<b>Code is available at</b>: <a href="{code_path()}"  target="_blank">{code_path()}</a>.')
  })
  
  ### R4DS link
  r4ds_path <- reactive({
    glue::glue(
      "https://github.com/rfordatascience/tidytuesday/blob/master/data/{week_data()$year}/{week_data()$week}/readme.md"
    )
  })
  
  output$r4ds_link <- renderText({
    glue::glue('<b>R4DS GitHub link</b>: <a href="{r4ds_path()}"  target="_blank">{r4ds_path()}</a>.')
  })
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)