library(shiny)
library(fpc)
library(cluster)
library(clue)
library(kernlab)
library(ggplot2)

shinyServer(
        function(input, output, session) {
                set.seed(12345)
                data   <- read.table("self_test.data", skip = 1)
                colnames(data) <- c("x","y")
                
 class <- reactive({
                if (input$k == "2"){
                        gr <- read.table("self_test.ground", skip = 1)
                        gr[1:nrow(gr),]+1
                } else
                        sample(input$k,nrow(data),rep=TRUE)
                })
                
 compute <- reactive({
                if (input$kernel=="linear") {
                        Kclust <- kmeans(data ,input$k)
                        list(kmean.result = data.frame(data, 
                                cluster=as.factor(Kclust$cluster)),
                                centers = as.data.frame(Kclust$centers),
                                model = Kclust)
                                                                
                } else if (input$kernel=="RBF") {
                        Kclust <- kkmeans(as.matrix(data), input$k, kernel="rbfdot", 
                                  kpar=list(sigma=1/(2*input$sig^2)))
                        list(kmean.result = data.frame(data, cluster=as.factor(Kclust@.Data)),
                             centers = data.frame(x=Kclust@centers[,1],
                                                  y=Kclust@centers[,2]),
                             model = Kclust)
                }
        })
                
 result <- reactive({
         
              if (input$kernel=="linear") {
                      cls <- class()
                      com <- compute()
                 fit1 <- com$model
                 fit1.f1 <- as.cl_hard_partition(fit1$cluster)
                 fit1.f2 <- as.cl_hard_partition(cls)
                 
                 purity <- as.numeric(cl_agreement(fit1.f1, fit1.f2, method="purity"))
                 NMI <- as.numeric(cl_agreement(fit1.f1, fit1.f2, method="NMI"))
                 list(pur=purity,nmi=NMI)
                 
         } else if (input$kernel=="RBF") {
                 cls <- class()
                 com <- compute()
                 fit5 <- com$model
                 fit5.f1 <- as.cl_hard_partition(unlist(fit5))
                 fit5.f2 <- as.cl_hard_partition(cls)
                 
                 purity <- as.numeric(cl_agreement(fit5.f1, fit5.f2, method="purity"))
                 NMI <- as.numeric(cl_agreement(fit5.f1, fit5.f2, method="NMI"))
                 list(pur=purity,nmi=NMI)
         }
 })
 
 output$kkmeans.ui <- renderUI({
         sel <- NULL
         if (input$kernel == "RBF"){
                 sel <- sliderInput('sig', 'Sigma (used with Kernel K-Means)',
                                    4, min = 0.2, max = 7.2, step =0.2)
         }
         sel
         
 })
 
 output$plot <- renderPlot({
                dat=compute()
                ggplot(data=dat$kmean.result, aes(x=x, y=y, color=cluster)) +
                        geom_point(size=3) + geom_point(data=dat$centers,
                                        aes(x=x, y=y, color='Center'), pch=17, size=7) +
                        ggtitle("Non-linear data example") 
                }, bg="transparent")

 output$purity <- renderText({
         text <- result()
         text$pur
 })

 output$NMI <- renderText({
         text <- result()
         text$nmi
 })
                
        }
)