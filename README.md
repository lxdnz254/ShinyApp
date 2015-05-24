K-means versus Kernel Kmeans: Shiny Application
===============================================

This shiny application is designed to show the difference between the K-means and Kernel K-means
clustering methods.

Using a small non-linear data set, the user can select K-means or Kernel K-means algorithms and define the number of clusters and $$\sigma$$ (when using Kernel K-means).

The resulting output with be a plot above the user interface showing the clusters and their centers. It will also run a cross-validation check on a truth file when the cluster number is set to 2. If it is above two it will generate a random vector using `sample(input$k,nrow(data),rep=TRUE)` as the generator in the user file.

In the future, I aim to add more features to this app, including:

 * Selectable datasets with truth files
 * Different algorithms to choose from
 * Plot output options
 * More...
 
There is a slider presentation available at [this page](https://lxdnz-254.shinyapps.io/ClusterAnalysis/) or at [this Rpubs page](http://rpubs.com/lxdnz/Kmeans)
