# fluviz
Influenza sequence visualization in R/RStudio.  
![Image of metamap](https://github.com/mopratt/fluviz/blob/master/images/metamap_image.png)
![Image of snpplot](https://github.com/mopratt/fluviz/blob/master/images/snpplot_image.png)

These visualization tools are intended to be used with the [Influenza Classification Suite](https://github.com/Public-Health-Bioinformatics/flu_classification_suite).  
The **Influenza Classification Suite** assigns clades to influenza protein sequences and extracts antigenic sites, which are then mapped to a reference. The ouput of the classification workflow is a line list containing an antigenic site alignment and associated metadata.  
  
**Influenza Classification Suite Workflow:**  
![Image of Classification Suite Workflow](https://github.com/mopratt/fluviz/blob/master/images/class-suite-wrkflw.jpg)  

The R functions available here allow for visualization of the influenza sequences and metadata and provide an interactive visualization of the line list output. A tutorial is provided in R Markdown format in the **docs/** folder, and the individual R functions are available under **rcode/**.  
If you would like to run the entire workflow on Galaxy before running the visualization, example data for the Classification Suite is available in **example_data/classification_suite/** or in the [Flu Suite GitHub repository](https://github.com/Public-Health-Bioinformatics/flu_classification_suite/tree/master/tools) for each individual tool. Example data for completing the fluviz tutorial on its own is available in **example_data/visualization/**.  
  
### Usage  
To follow the tutorial, download the latest versions of R and RStudio to your computer. Download the .Rmd file in the **/docs** folder and open it in RStudio or, copy/paste the text into a new .Rmd file. You may be required to install new packages. Next, click on "Knit" to generate the tutorial document in markdown.  
  
### Packages  
fluviz is built in R. It uses the following main packages: **tidyverse**, **ggplot2**, **treeio**, **ggtree**, and **plotly**. To read more about these and about the Influenza Classification Suite please see below:  

**R:** R Core Team (2019). R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria. URL https://www.R-project.org/.  
**Flu Classification Suite:** Eisler D, Fornika D, Tindale LC, Chan T, Sabaiduc S, Hickman R, et al (2020). Influenza Classification Suite: An automated Galaxy workflow for rapid influenza sequence analysis. Influenza Other Respir Viruses. May;14(3):358–62.  
**tidyverse:** Wickham et al., (2019). Welcome to the tidyverse. Journal of Open Source Software, 4(43), 1686, https://doi.org/10.21105/joss.01686  
**ggplot2:** H. Wickham. (2016). ggplot2: Elegant Graphics for Data Analysis. Springer-Verlag New York.  
**treeio:** LG Wang, TTY Lam, S Xu, Z Dai, L Zhou, T Feng, P Guo, CW Dunn, BR Jones, T Bradley, H Zhu, Y Guan, Y Jiang, G Yu (2020). treeio: an R package for phylogenetic tree input and output with richly annotated and associated data. Molecular Biology and Evolution. 37(2):599-603. doi: 10.1093/molbev/msz240  
**ggtree:** G Yu, D Smith, H Zhu, Y Guan, TTY Lam. ggtree: an R package for visualization and annotation of phylogenetic trees with their covariates and other associated data. Methods in Ecology and Evolution 2017, 8(1):28-36. doi:10.1111/2041-210X.12628  
**plotly:**  C. Sievert. Interactive Web-Based Data Visualization with R, plotly, and shiny. Chapman and Hall/CRC Florida, 2020.
