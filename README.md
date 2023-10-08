# #TidyTuesday Shiny App

#TidyTuesday is a weekly data challenge aimed at the R community. Every week a new dataset is posted alongside a chart or article related to that dataset, and ask participants explore the data. You can access the data and find out more on [GitHub](https://github.com/rfordatascience/tidytuesday/blob/master/README.md).

My contributions can be found on [GitHub](https://github.com/nrennie/tidytuesday), and you can use this Shiny app to explore my visualisations with links to code for each individual plot. You can also follow my attempts on Mastodon at [fosstodon.org/@nrennie](https://fosstodon.org/@nrennie).

This Shiny app allows you to display and explore my #TidyTuesday plots, and allows a you to see examples that use specific packages. Links to the original #TidyTuesday data alongside links to code scripts on GitHub are provided. A list of packages found in each script is provided. 

<p align="center">
<img src="https://raw.githubusercontent.com/nrennie/tidytuesday-shiny-app/main/tidytuesday-shiny-app.png" width = "90%" alt="Screenshot of shiny app showing scatter plot">
</p>

## Deployment

This Shiny app is deployed via GitHub pages using [shinylive](https://posit-dev.github.io/r-shinylive/) with [webR](https://docs.r-wasm.org/webr/latest/). See [Rami Krispin's tutorial](https://github.com/RamiKrispin/shinylive-r) for details on how to deploy your own R Shiny app using shinylive.

A couple of small gotchas:

* I had to load external data using `load(url("url_to_file/file.RData"))
* Not all packages (including `shinythemes`) are supported so not all parts of the original (non-shinylive) app could be directly transported over.
* When viewing the app with some of these bugs in it, it simply returned a `404 Not found` error. Using the [shinylive editor mode](https://shinylive.io/r/editor/) was really helpful.

Find a bug? [Report as a GitHub issue](https://github.com/nrennie/tidytuesday-shiny-app/issues).
`
