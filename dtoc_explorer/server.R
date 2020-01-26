
library(tidyverse)

load("../all_data.Rdata")

function(input, output) {
    
    # render UI
    
    output$regionInput <- renderUI({
        
        selectInput("regionSelect", "Select region",
                    choices = unique(granular_data$`Provider Parent Name`))
    })

    output$paretoPlot <- renderPlot({

        granular_data %>% 
            filter(`Provider Parent Name` == input$regionSelect) %>% 
            group_by(`Reason For Delay`) %>% 
            summarise(nhs_dtoc = sum(`NHS DTOC beds`)) %>% 
            arrange(-nhs_dtoc) %>% 
            mutate(`Reason For Delay` = factor(`Reason For Delay`, levels = `Reason For Delay`)) %>% 
            mutate(csum = cumsum(nhs_dtoc)) %>% 
            ggplot(aes(x = `Reason For Delay`)) + 
            geom_bar(aes(y = nhs_dtoc), stat = "identity") + 
            geom_point(aes(y = csum)) +
            geom_path(aes(y = csum, group = 1)) +
            theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))
    })
    
    output$spcAllCauses <- renderPlot({
        
        time_granular %>% 
            filter(`Provider Parent Name` == input$regionSelect) %>% 
            group_by(Date) %>% 
            summarise(nhs_dtoc = sum(`NHS DTOC beds`, na.rm = TRUE)) %>% 
            qic(Date, nhs_dtoc, 
                data     = .,
                chart    = 'i',
                title     = 'All DTOCs',
                ylab     = 'Total DTOCs',
                xlab     = 'Month')
    })
}
