# Image analysis scripts
1: RGB extraction from adaxial leaf images taken with a set of color standards (Post-CCM).
2: Callose quantification from longitudinal sections stained with aniline blue and imaged using fluorescent microscopy. 

## 1 - RGB extraction: 

Remove image background noise and extract RGB values from senescing leaves. 
The final output is a summary table with intensity values per color channel, pixel counts, estimated anthocyanin area, and indices to assess change in color channels over time (S_red, S_green, S_blue).

Indices and other photography considerations: 

Del Valle JC, Gallardo-López A, Buide ML, Whittall JB, Narbona E. (2018). Digital photography provides a fast, reliable, and noninvasive method to estimate anthocyanin pigment concentration in reproductive and vegetative plant tissues. Ecol Evol. Feb 16;8(6):3064-3076. doi: 10.1002/ece3.3804. PMID: 29607006; PMCID: PMC5869271.

Sunoj, S., Igathinathane, C., Saliendra, N., Hendrickson, J., & Archer, D. (2018). Color calibration of digital images for agriculture and other applications. ISPRS journal of photogrammetry and remote sensing, 146, 221-234.

## 2 - Callose quantification:

This macro is a modified version of a protocol by Zavaliev and Epel (2015) originally used for confocal images. 
Several preprocessing steps are required to analyze fluorescent microscopy images, including delineating/recording an ROI space and refining image selection.

Added code includes user prompts to select a target and a saved image folder. Users must determine a global scale for their images, set individual parameters,  and use the most appropriate auto-local threshold type for their images. Phansalker thresholding was selected for fluorescent imaging of callose deposits in the phloem, as this form of thresholding was created to process low-contrast imaging (Neerad et al., 2011). 


Source:
Neerad Phansalkar, Sumit More, Ashish Sabale, & Madhuri Joshi. (2011). Adaptive local thresholding for detection of nuclei in diversity stained cytology images. In 2011 International Conference on Communications and Signal Processing. IEEE. doi:10.1109/iccsp.2011.5739305

Zavaliev, R., Epel, B.L. (2015). Imaging Callose at Plasmodesmata Using Aniline Blue: Quantitative Confocal Microscopy. Methods in Molecular Biology. Methods in Molecular Biology, pp. 105–119.. https://doi.org/10.1007/978-1-4939-1523-1_7
