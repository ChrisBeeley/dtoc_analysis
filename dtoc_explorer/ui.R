
fluidPage(

    # Application title
    titlePanel("DTOCs by region"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            uiOutput("regionInput")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabPanel("Causes of DTOC", plotOutput("paretoPlot")),
                tabPanel("SPC all causes", plotOutput("spcAllCauses"))
            )
        )
    )
)