October 29, 2013
Eric Wilcox-Freeburg
Rev. 0.1b

Purpose:
This MATLAB script was written to assist in making objective morphological assessments of objects in light microscopy imagery.

Notes:
This software is functional as is, so I am considering it in beta stages.  Since I have only used this software for analysis of one type of sample within light microscopy imagery, I'm not fully convinced it will work for all sample types.

Given a clean image, this software is able to objectively detect items in the photograph, allowing for manual item identification post hoc.  This technique allowed for automatic objective determination of up to six items in a given field of view for our purposes and allowed for manual labeling for dataset construction.  Currently, the output file records the sample name, as derived from the filename, and adds the object identifier, calculates area in pixels^2, perimeter, major axis, and minor axis.  Additional functionality is possible since additional parameters can be easily evaluated and saved to a dataset.  If other parameters are wanted, a simple change in the parameters hard coded into the script is possible.