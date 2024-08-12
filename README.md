# Isaac_et_al_2024_mPFC_sex_diff

Link to biorxiv - https://www.biorxiv.org/content/10.1101/2023.03.09.531947v3

This repository (*currently being updated) contains codes and sample data to recreate part of figure 2 and Supplementary figure 7 of the paper. Naviagte to the `codes` folder and run the codes - `suppFig7.m` or `figure2.m` as needed. Associated functions to run the code are saved in `codes\functions\` folder. All figures created are saved as .pdf and .pngs in the `figures` folder. 

Data for the codes is uploaded on figShare (DOI to be available soon). Once downloaded, add the folder ("data") to the main directory above. The `data` folder contains animal subject's files in subfolders `male` and `female` for  the `full_Water_Access` condition (find more details in the paper). Each .mat file (called variables_for_analysis_tracklight.mat) contains the preprocessed calcium traces (&#916;F/F) along with timestamps of behavioral events of interest, (such as choice pokes, and reward consumption) and the animal's behavioral tracking (done through centroid tracking on bonsai). Each .mat file is then concatenated and time-sliced around behaviors of interest to create Supplementary figure 7 panels a-d. Similarly, neurons signficantly responding to the behaviors are identified and used to plot panels g-h of Figure 2. 

Code maintained by the Murugan Lab - https://www.muruganlab.com/
