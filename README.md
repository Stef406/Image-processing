# Image-processing
This project provides an image processing approach to determine the void fraction distribution in fluidized beds. 

The main steps are the following:

- Select a rectangle where the bed is in the Fixed image. The inensity of this subimage is the void fraction of the packed or fixed bed.
- Select a rectangle where the freeboard is in the Fixed image (bright area). The inensity of this subimage is the maximum void fraction when only gas and no particles are present.
- Select a Region Of Interest (ROI) to determine the average void fraction distribution over time for a certain number of images. You can change the number of images to process by changing frame_i and frame_f.

This code has been developed for fluidized beds. However, it may be adapted and applied to other multiphasse systems.
