# tf-fm-analysis
This repository contains the code used for the analysis of data for ThinkForward's FutureMe programme. The findings from this analysis are described in the report produced by Dartington Service Design Lab in March 2024.

## Getting started 
* Clone the repository.
* Populate the folder `Datasets` in order for the code to run, according to the datasets specified under each notebook below.
* Run the notebooks in the order specified below. 

## Notebooks

### v3_cleaning.Rmd 
Cleaning and reshaping the demographics & Ready4Work Passport activity dataset (these were provided as a single dataset) and the follow-up calls dataset. Run this notebook first.

#### Required datasets:
* `v3_dem_r4w.csv`
* `v3_followups.csv`

### v3_status_change_analysis.Rmd
Contains the code for plotting the follow-up status graphs and producing the status change table. Requires `v3_cleaning.Rmd` to run first.
