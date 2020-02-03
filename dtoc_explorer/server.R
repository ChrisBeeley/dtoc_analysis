
library(readxl)
library(tidyverse)
library(tidylog)
library(qicharts2)
library(lubridate)
library(qicharts2)
library(prophet)

load("all_data.Rdata")

function(input, output) {
    
    # reactive dataset----
    
    filter_data <- reactive({
        
        filter_df <- time_granular %>% 
            filter(`Provider Parent Name` == input$regionSelect)
        
        if(input$trustSelect != "All"){
            
            filter_df <- filter_df %>% 
                filter(`Provider Org Name` == input$trustSelect)
        }
        
        return(filter_df)
    })
    
    # render UI----
    
    output$regionInput <- renderUI({
        
        selectInput("regionSelect", "Select region",
                    choices = unique(time_granular$`Provider Parent Name`))
    })
    
    output$trustInput <- renderUI({
        
        choices <- time_granular %>% 
            filter(`Provider Parent Name` == input$regionSelect) %>%  
            arrange(`Provider Org Name`) %>% 
            pull(`Provider Org Name`) %>% 
            unique()
        
        selectInput("trustSelect", "Select Trust",
                    choices = c("All", choices))
    })
    
    # outputs----
    
    output$paretoPlot <- renderPlot({
        
        filter_data() %>% 
            group_by(`Reason For Delay`) %>% 
            summarise(nhs_dtoc = sum(`NHS DTOC beds`)) %>% 
            arrange(-nhs_dtoc) %>% 
            mutate(`Reason For Delay` = factor(`Reason For Delay`, levels = `Reason For Delay`)) %>% 
            mutate(csum = cumsum(nhs_dtoc)) %>% 
            ggplot(aes(x = `Reason For Delay`)) + 
            geom_bar(aes(y = nhs_dtoc), stat = "identity") + 
            geom_point(aes(y = csum)) +
            geom_path(aes(y = csum, group = 1)) +
            theme(axis.text.x = element_text(angle = 60, vjust = 1, hjust=1))
    })
    
    output$spcAllCauses <- renderPlot({
        
        filter_data() %>% 
            group_by(Date) %>% 
            summarise(nhs_dtoc = sum(`NHS DTOC beds`, na.rm = TRUE)) %>% 
            qic(Date, nhs_dtoc, 
                data     = .,
                chart    = 'i',
                title     = 'All DTOCs',
                ylab     = 'Total DTOCs',
                xlab     = 'Month')
    })
    
    output$dtocForecast <- renderPlot({
        
        time_granular %>% 
            filter(`Provider Parent Name` == input$regionSelect) %>% 
            group_by(Date) %>% 
            summarise(nhs_dtoc = sum(`NHS DTOC beds`, na.rm = TRUE)) %>% 
            ggplot(aes(x = Date, y = nhs_dtoc)) + geom_line() +
            geom_smooth()
        
        
    })
}
