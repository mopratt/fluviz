# fluviz
Influenza sequence visualization in R/RStudio.  
![Image of metamap](https://github.com/mopratt/fluviz/blob/master/images/metamap_image.png)
![Image of snpplot](https://github.com/mopratt/fluviz/blob/master/images/snpplot_image.png)

These visualization tools are intended to be used with the [Influenza Classification Suite](https://github.com/Public-Health-Bioinformatics/flu_classification_suite).  
The **Influenza Classification Suite** assigns clades to influenza protein sequences and extracts antigenic sites, which are then mapped to a reference. The ouput of the classification workflow is a line list containing an antigenic site alignment and associated metadata.  
  
**Influenza Classification Suite Workflow:**  
![Image of Classification Suite Workflow](https://github.com/mopratt/fluviz/blob/master/images/class-suite-wrkflw.jpg)  

The R functions available here allow for visualization of the influenza sequences and metadata and provide an interactive visualization of the line list output. A walkthrough is provided in R Markdown format in the **tutorials/** folder and the individual R functions are available under **rcode/**.  
If you would like to run the entire workflow on Galaxy before running the visualization, example data for the Classification Suite is available in **example_data/classification_suite/** or in the [Flu Suite GitHub repository](https://github.com/Public-Health-Bioinformatics/flu_classification_suite/tree/master/tools) for each individual tool. Example data for completing the fluviz tutorial on its own is available in **example_data/visualization/**
