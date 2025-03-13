
# load packages
#######################################

library(shiny) 
library(dplyr) 

library(DT) 

library(ggplot2) 
library(gridExtra)  

# Load Data 
df <- read.csv("data.csv")


# summarizing data in a table
#######################################         

summarize_data <- function(df) {
  summary_list <- list()
  
  for (col in colnames(df)) {
    if (is.numeric(df[[col]]) && !all(df[[col]] %in% c(0, 1))) {
      # Continuous variable (% )excluding Binary)
      summary_list[[col]] <- data.frame(
        Variable = col,
        Type = "Continuous",
        Category = "-",
        Mean = round(mean(df[[col]], na.rm = TRUE), 2),
        Median = round(median(df[[col]], na.rm = TRUE), 2),
        Min = round(min(df[[col]], na.rm = TRUE), 2),
        Max = round(max(df[[col]], na.rm = TRUE), 2),
        Q1 = round(quantile(df[[col]], 0.25, na.rm = TRUE), 2),
        Q3 = round(quantile(df[[col]], 0.75, na.rm = TRUE), 2),
        Count = sum(!is.na(df[[col]])),
        Missing = sum(is.na(df[[col]]))
      )
    } else {
      # Categorical variable 
      cat_summary <- df %>%
        group_by(!!sym(col)) %>%
        summarise(Freq = n(), .groups = "drop") %>%
        mutate(Percentage = round(100 * Freq / sum(Freq), 2)) %>%
        rename(Category = !!sym(col)) %>%
        mutate(Category = as.character(Category)) 
      
      cat_summary <- cat_summary %>%
        mutate(Variable = col, Type = ifelse(all(df[[col]] %in% c(0, 1)), "Binary", "Categorical")) %>%
        select(Variable, Type, Category, Freq, Percentage)
      
      summary_list[[col]] <- cat_summary
    }
  }
  
  # combining all row wise
  summary_table <- bind_rows(summary_list) 
  
  return(summary_table)
}


# defining UI
#######################################

ui <- fluidPage(
  titlePanel("Cohort Description Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      width = 2, 
      style = "padding: 2px;", 
      
      selectInput("geo_filter", "Geographical Atrophy Status:", 
                  choices = c("All" = "", "0" = 0, "1" = 1), selected = ""),
      
      selectInput("sex_filter", "Select Sex:", choices = c("All", "Male", "Female"),
                  selected = "All"),
      
      sliderInput("age_range", "Age Range:", 
                  min = round(min(df$Age, na.rm = TRUE), 1),
                  max = round(max(df$Age, na.rm = TRUE), 1), 
                  value = c(round(min(df$Age, na.rm = TRUE), 1), 
                            round(max(df$Age, na.rm = TRUE), 1)),
                  step = 1),
      
      selectInput("race_filter", "Select Race:", choices = c("All", "Race1", "Race2", "Race3", "Race4"),
                  selected = "All", multiple = TRUE),
    
      selectInput("smoke_filter", "Select Smoking Status:", 
                  choices = c("All" = "", "0" = 0, "1" = 1), selected = ""),
      
      selectInput("diabetic_filter", "Select Diabetic Status:", 
                  choices = c("All" = "", "0" = 0, "1" = 1), selected = ""),
      
      selectInput("wAMD_filter", "Select wAMD Status:", 
                  choices = c("All" = "", "0" = 0, "1" = 1), selected = ""),
      
      selectInput("AntiVEGF_Medications_filter", "Select AntiVEGF Medications Status:", 
                  choices = c("All" = "", "0" = 0, "1" = 1), selected = ""),
      
      ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Cohort Summary", DTOutput("cohort_table"),  
                 downloadButton("download_summary", "Download Summary")),
        tabPanel("Demographics & Lifestyle", plotOutput("demographics_plot")),
        tabPanel("Clinical Variables", plotOutput("clinical_plot"))
      )
    )
  )
)




# Define Server Logic
#######################################

server <- function(input, output) {
  
  # Filtering Data
  filtered_data <- reactive({
    df %>%
      filter(
        (input$geo_filter == "" | Geographical_Atrophy_Status == input$geo_filter) &
        (input$sex_filter == "All" | Sex == input$sex_filter) &
        (Age >= input$age_range[1] & Age <= input$age_range[2]) &
        (input$race_filter == "All" | Race %in% input$race_filter) &
        (input$diabetic_filter == "" | Smoking_Status == input$diabetic_filter) &
        (input$smoke_filter == "" | Smoking_Status == input$smoke_filter) &
        (input$wAMD_filter == "" | wAMD == input$wAMD_filter) &
        (input$AntiVEGF_Medications_filter == "" | AntiVEGF_Medications == input$AntiVEGF_Medications_filter) 
      )
  })
  
  # summary table
  output$cohort_table <- renderDT({
    summary_table <- summarize_data(filtered_data())
    datatable(summary_table, 
              options = list(pageLength = 10, autoWidth = TRUE),
              rownames = FALSE)
  })
  
  # download button 
  output$download_summary <- downloadHandler(
    filename = function() {
      paste("Cohort_Summary_", Sys.Date(), ".csv")
    },
    content = function(file) {
      summary_table <- summarize_data(filtered_data())
      write.csv(summary_table, file, row.names = FALSE)
    }
  )
  
  
  # demographics & lifestyle
  output$demographics_plot <- renderPlot({
    
    # age
    p1 <- ggplot(filtered_data(), aes(x = Age)) +
      geom_density(fill = "skyblue", alpha = 0.6) +
      ggtitle("Age Distribution") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5))  
    
    # race
    p2_data <- filtered_data() %>%
      count(Race) %>%
      mutate(Percentage = n / sum(n) * 100)
    
    p2 <- ggplot(p2_data, aes(x = "", y = Percentage, fill = Race)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar(theta = "y") +
      ggtitle("Race") +
      theme_void() +  # No axis / background
      scale_fill_brewer(palette = "Set3") +  # Using color set
      theme(plot.title = element_text(hjust = 0.5)) +  
      theme(legend.position = "right") +
      geom_text(aes(label = paste0(round(Percentage, 1), "%")), position = position_stack(vjust = 0.5))
    
    # sex
    p3_data <- filtered_data() %>%
      count(Sex) %>%
      mutate(Percentage = n / sum(n) * 100)
    
    p3 <- ggplot(p3_data, aes(x = "", y = Percentage, fill = Sex)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar(theta = "y") +
      ggtitle("Sex") +
      theme_void() +  # No axis / background
      scale_fill_manual(values = c("pink", "lightblue")) +
      theme(plot.title = element_text(hjust = 0.5)) + 
      theme(legend.position = "right") +
      geom_text(aes(label = paste0(round(Percentage, 1), "%")), position = position_stack(vjust = 0.5))
    
    # smoking
    p4_data <- filtered_data() %>%
      count(Smoking_Status) %>%
      mutate(Percentage = n / sum(n) * 100)
    
    p4 <- ggplot(p4_data, aes(x = factor(Smoking_Status), y = Percentage, fill = factor(Smoking_Status))) +
      geom_bar(stat = "identity") +
      ggtitle("Smoking Status") +
      xlab("Smoking Status") +  # x axis label
      theme_minimal() +
      scale_x_discrete(labels = c("0" = "No", "1" = "Yes")) +  # labeling values
      scale_fill_manual(values = c("lightgreen", "salmon")) + 
      theme(plot.title = element_text(hjust = 0.5)) +  
      geom_text(aes(label = paste0(round(Percentage, 1), "%")), 
                position = position_dodge(width = 0.9), vjust = 0.5, size = 4) + 
      guides(fill = "none")  # Remove legend
    
      # four as one plot
    grid.arrange(p1, p2, p4, p3, ncol = 2, nrow = 2, heights = c(2, 2), widths = c(2, 2))
    
  }, height = 600, width = 1100)
  
  

  
  # Clinical Cohort & Study-specific 
  output$clinical_plot <- renderPlot({
    
    # triglycerides
    p1 <- ggplot(filtered_data(), aes(x = Triglycerides)) + 
      geom_density(fill = "skyblue", alpha = 0.5) + 
      ggtitle("Triglycerides Density Plot") + 
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5))  
    
    # diabetic  
    p2_data <- filtered_data() %>%
      count(Diabetic_Status) %>%
      mutate(Percentage = n / sum(n) * 100)
    
    p2 <- ggplot(p2_data, aes(x = factor(Diabetic_Status), y = Percentage, fill = factor(Diabetic_Status))) +
      geom_bar(stat = "identity") +
      ggtitle("Diabetic Status") +
      xlab("Diabetic Status") +  # x axis label 
      scale_x_discrete(labels = c("0" = "No", "1" = "Yes")) +  
      scale_fill_manual(values = c("darkgreen", "tomato")) +  
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5)) +  
      guides(fill = "none") +  # Remove legend
      geom_text(aes(label = paste0(round(Percentage, 1), "%")), 
                position = position_dodge(width = 0.9), vjust = 0.5, size = 4)  
    
    # anti-VEGF Medications
    p3_data <- filtered_data() %>%
      count(AntiVEGF_Medications) %>%
      mutate(Percentage = n / sum(n) * 100)
    
    p3 <- ggplot(p3_data, aes(x = "", y = Percentage, fill = factor(AntiVEGF_Medications))) +
      geom_bar(stat = "identity", width = 1) +
      geom_bar(aes(x = "", y = 0), stat = "identity", width = 0.5, fill = "white") + 
      coord_polar(theta = "y") +  
      ggtitle("Anti-VEGF Medications") +
      scale_fill_manual(values = c("lightcoral", "lightseagreen")) + 
      theme_void() +
      theme(plot.title = element_text(hjust = 0.5)) +
      guides(fill = guide_legend(title = NULL)) +  
      geom_text(aes(label = paste0(round(Percentage, 1), "%")), position = position_stack(vjust = 0.5))  
    
    # visual acuity
    p4 <- ggplot(filtered_data(), aes(x = Visual_Acuity)) + 
      geom_density(fill = "lightgreen", alpha = 0.5) + 
      ggtitle("Visual Acuity Density Plot") + 
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5)) 
    
    # wAMD 
    p5_data <- filtered_data() %>%
      count(wAMD) %>%
      mutate(Percentage = n / sum(n) * 100)
    
    p5 <- ggplot(p5_data, aes(x = "", y = Percentage, fill = factor(wAMD))) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar(theta = "y") +  
      ggtitle("wAMD Status") +
      scale_fill_manual(values = c("skyblue", "orange")) + 
      theme_void() +
      theme(plot.title = element_text(hjust = 0.5)) +
      guides(fill = guide_legend(title = NULL)) +  
      geom_text(aes(label = paste0(round(Percentage, 1), "%")), position = position_stack(vjust = 0.5))  
    
    # Time in Cohort 
    p6 <- ggplot(filtered_data(), aes(x = Time_in_Cohort)) + 
      geom_density(fill = "purple", alpha = 0.5) + 
      ggtitle("Time in Cohort Density Plot") + 
      theme_minimal()+
      theme(plot.title = element_text(hjust = 0.5))  
    
    
    # all the plots
    grid.arrange(p1, p4, p3, p2, p6, p5, ncol = 3, nrow = 2,heights = c(2, 2), widths = c(4, 3, 2))
  }, height = 600, width = 1100)
  
  
}



# Run the Shiny App
#######################################
shinyApp(ui = ui, server = server)
