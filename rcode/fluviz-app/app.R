library(shiny)
library(knitr)
library(ggplot2)
library(tidyverse)
library(ggnewscale)
library(plotly)
library(ggtree)
library(treeio)
library(readxl)
library(readr)

source("fn_combine_metadata_shiny.R")
source("fn_metamap.R")
source("fn_snpplot_shiny.R")

ui <-  navbarPage(title = "fluviz", 
             tabPanel(title = "Introduction", 
                      tags$h1("fluviz"), 
                      tags$h4("Visualization of Influenza Sequences and Metadata"), 
                      includeMarkdown("README.md")
                      ),
             tabPanel(title = "combine metadata", 
                      sidebarLayout(
                        sidebarPanel(tags$h3("combine GISAID metadata with a Flu Suite line list"),
                          wellPanel(
                            fluidRow(
                              fileInput(inputId = "mxls", label = "GISAID metadata Excel file:", 
                                               accept = c(".xls", ".xlsx")), 
                              fileInput(inputId = "llcsv", label = "Line List CSV file:", 
                                               accept = ".csv"), 
                              radioButtons(inputId = "label", 
                                                 label = "Select which column contains sequence labels:", 
                                           choices = c("Isolate_Name", "Isolate_Id"))
                            ),
                            fluidRow(
                              actionButton(inputId = "upload", label = "Combine Metadata", 
                                           style ="color: #fff; background-color: #337ab7; border-color: #2e6da4"))
                            )
                        ),
                        mainPanel(
                          dataTableOutput("data")
                        )
                      )),
             tabPanel(title = "import phylogenetic tree", 
                      sidebarLayout(
                        sidebarPanel(tags$h3("import a phylogenetic tree using treeio"),
                                     tags$em("if your file type is not listed here see the Tutorial section for more information"),
                          wellPanel(
                            fileInput(inputId = "phyl", label = "Phylogenetic tree file:", 
                                      accept = c(".nhx", ".nwk", ".nexus")), 
                            radioButtons(inputId = "ext", 
                                        label = "Select the type of tree file you are using:", 
                                        choices = c("Newick: .nwk" = "nwk",
                                          "Nexus: .nexus" = "nexus",
                                          "New Hampshire: .nhx" = "nhx"), 
                                        selected = character(0)),
                           actionButton(inputId = "ggtree", label = "Generate Tree", 
                                        style ="color: #fff; background-color: #337ab7; border-color: #2e6da4") 
                          ),
                        width = 4), 
                        mainPanel(
                          wellPanel(
                            plotOutput("phylo")
                          ),
                        width = 8)
                      )),
             tabPanel(title = "plot metadata heatmap",
                      sidebarLayout(
                        sidebarPanel(tags$h3("plot a heatmap of your metadata using ggtree"),
                          wellPanel(
                            fluidRow(column(4, offset = 3,
                              actionButton(inputId = "auto", label = "Load my data", 
                                           style ="color: #fff; background-color: #337ab7; border-color: #2e6da4"))),
                          ),
                          wellPanel(fluidRow(
                            checkboxGroupInput(inputId = "choose",
                                                      label = "Choose columns to plot:", 
                                                      choices = c("Clade", "Subtype", "Host"), 
                                                      selected = "Clade")
                          ),
                          fluidRow(column(4, offset = 4,
                            actionButton(inputId = "go", label = "Plot", 
                                         style ="color: #fff; background-color: #337ab7; border-color: #2e6da4"))
                          ))),
                        mainPanel(
                          fluidRow(
                            plotOutput("metamap")
                            )
                          )
                        )
                      ),
             tabPanel(title = "interactive snpplot", 
                      tags$h3("generate an interactive SNP plot using plotly"),
                      fluidRow(column(12, 
                                      fileInput(inputId = "clade", 
                                                label = "Choose a CSV clade definition file:", 
                                                accept = ".csv"),
                                      actionButton(inputId = "plotly", label = "Generate Interactive Plot",
                                                   style ="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                                      selectizeInput(inputId = "leg", 
                                                     label = "Colour by:", 
                                                     choices = c("SNP Chemistry" = "snp.group",
                                                                 "Clade Assignment" = "clade", 
                                                                 "Canonical Clade Sites" = "clade.def.pos", 
                                                                 "Flags" = "flag") 
                                                     )
                                      )),
                      fluidRow(column(6, plotOutput("metamap2")
                                      ), 
                               column(6, plotlyOutput("snpplot", width = 1200, height = 750)
                                      )
                               ))
  )
server <- function(input, output, session) {
  # Combine metadata:
  gisaid <- eventReactive(input$upload, {
    excel <- input$mxls
    excel$datapath
  })
  linelist <- eventReactive(input$upload, {
    csv <- input$llcsv
    csv$datapath
  })
  label <- eventReactive(input$upload, {
    input$label
  })
  mdata <- eventReactive(input$upload, {
    combine_metadata_shiny(metadata = gisaid(), 
                           line_list = linelist(),
                           label_col = label())
  })
  output$data <- renderDataTable({mdata()})
  # Phylogenetic tree import: 
  phylo <- eventReactive(input$ggtree, {
    phyl <- input$phyl
    phyl$datapath
  })
  tree1 <- eventReactive(input$ggtree, {
    getFunction(paste0("read.", input$ext))((phylo()))
  })
  output$phylo <- renderPlot({
    as.phylo(tree1()) %>% ggtree(branch.length = "none") +
      geom_tiplab(size=3) + ggplot2::xlim(0,17)
  })
  # Metamap plotting:
  cols <- eventReactive(input$auto, {
    names(mdata())
  })
  observeEvent(input$auto, {
    updateCheckboxGroupInput(session, "choose", 
                             label = "Choose columns from your data to plot:", 
                             choices = cols(), 
                             selected = "Clade")
  })
  choices <- eventReactive(input$choose, {
    input$choose
  })
  map <- eventReactive(input$go, {
    metamap(tree = tree1(), metadata = mdata(), 
            cols = choices())
  })
  output$metamap <- renderPlot({map()}, width = 1500, height = 1000)
  # Interactive SNP Plot:
  cladedef <- eventReactive(input$plotly, {
    cd <- input$clade
    cd$datapath
  })
  p <- eventReactive(input$plotly, {
    snpplot_shiny(tree = tree1(), metadata = mdata(), line_list = linelist(), clade_def = cladedef())
  })
  output$metamap2 <- renderPlot({map()}, width = 1200, height = 750)
  output$snpplot <- renderPlotly({
    req(input$plotly)
    myColours <- c("#E41A1C", "#FFFF33", "#984EA3", "#377EB8", "#4DAF4A", "#FF7F00")
    colScale <- scale_colour_manual(name = input$leg, values = myColours)
    p1 <- ggplot(data = p(), aes(x = pos, y = y)) + geom_point(aes(shape = 22, color= get(input$leg), 
                                                   text = paste("Label:", label, "\n",    
                                                                "Clade Assignment:", clade, "\n",
                                                                "Position:", pos, "\n",
                                                                "Identity:", snp.ID, "\n", 
                                                                "Reference ID:", ref.ID, "\n",
                                                                "Canonical Clade Site:", clade.def.pos, "\n",
                                                                "Expected AA in Clade:", expected.aa)), 
                                               shape = 15, size = 1) + 
      scale_x_continuous(breaks = seq(0, 320, 20)) +
      theme_classic() + colScale + theme(axis.text.y=element_blank(),
                                         axis.ticks.y = element_blank(),
                                         axis.title.y = element_blank()) +
      labs(title = "Antigenic Amino Acid Substitutions", x = "position")
    ggplotly(p1, tooltip = "text")
  })
  }

shinyApp(ui = ui, server = server)
