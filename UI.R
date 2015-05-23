library(shiny)
library(ggplot2)
shinyUI(fluidPage(theme = "bootstrap.css",
                  titlePanel("Cluster Analysis: K-means versus Kernel K-means"),
                  
                  plotOutput('plot'),
                  hr(),
                  navbarPage("",
                 tabPanel("Instructions",
                      h3("Overview:"),
                      p("This shiny application is designed to show the different effects k-means and
                        kernel k-means cluster modelling has on a non linear data set. It is only a
                        demonstration on a small dataset, but will give the user a general idea of the
                        differences."),
                      h4("How to Use:"),
                      p("Got to the Input selection tab. Use the slider bar to choose number of clusters,
                       and the drop down selector to choose the type of K-means model to be used. When
                       you select Kernel K-means, another slider bar for the Sigma level will be
                       displayed, adjust this as well"),
                      p("When the cluster level is set to 2, the application will cross-validate 
                       against a known truth file, to give an exact answer. For any other number of
                       clusters, the application will generate a random truth matrix to cross-validate
                       against. This is for demonstration purposes."),
                      p("For a more detailed overview of this shiny application visit my",
                       a("Github Repository", href = "https://github.com/lxdnz254/ShinyApp"))
                       ),
             tabPanel("Input Selection",
                  fluidRow(
                       column(5,
                          selectInput('kernel','Type of cluster model:',
                                      c("K-means"="linear","Kernel K-means"="RBF"))
                              ),
                       column(3,
                          sliderInput('k', 'Number of clusters', 
                                      2, min = 2, max = 8, step = 1),
                          uiOutput("kkmeans.ui")
                              ),
                       column(3, offset = 1,
                          h3('Clustering Validation'),
                          h4('Purity'),
                          verbatimTextOutput("purity"),
                          h4('NMI'),
                          verbatimTextOutput("NMI")
                              )
                ))
        )
))