# fluviz
Influenza sequence visualization in R/RStudio.  
![Image of FluViz outputs]()  
These visualization tools are intended to be used with the [Influenza Classification Suite](https://github.com/Public-Health-Bioinformatics/flu_classification_suite). The Classification Suite assigns clades to influenza protein sequences and extracts antigenic sites, which are then mapped to a reference. The ouput of the classification workflow is a line list containing an antigenic site alignment and associated metadata. The R functions available here allow for visualization of the influenza sequences and metadata and provide an interactive visualization of the line list output. A walkthrough is provided in R Markdown format in the **tutorials/** folder and the individual R functions are available under **rcode/**. Example data for the Classification Suite is available in **example_data/classification_suite/** or in the [Flu Suite GitHub repository](https://github.com/Public-Health-Bioinformatics/flu_classification_suite/tree/master/tools) for each individual tool. Example data for completing the fluviz tutorial is available in **example_data/visualization/**
