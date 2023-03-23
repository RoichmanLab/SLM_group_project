# SLM_group_project
## A group project
### The purpose of this project:
Finding errors and improve the excisting matlab codes.
All the codes here are currently (20230305) work with the green laser (532nm)
For any other wavelength the user needs to make a few additional changes - calculate and save new holograms for the calibration code - circle, grid and a vortex.
Currently (20230305), to use the code, the user needs to proveid "SLM_Screen" before runnig the code. Can be found using gds function on matlab.
Currently (20230305), to use the code, all the information (calibration files and precalculated holograms) must be saved on the user computer and the user needs to provide the correct path in order to run the code.  
### Tasks:
1. We need to improve the code and maybe add a line that identifies the device number.
2. We need to save the calibration files and other information on a cloud and add the correct path to the codes or maybe find a better way to do it.   
These are the problems I remember we talked about in our last meeting. 
Fill free to add any suggestions or comments here. 
Ron.
3. We need to write a list of possible reasons for errors and ways to solve them.

## Manual - Instaling SLM System
### Alignment
Before starting anything - mane sure that your system is aligned!
### Thechnicals
* The SLM controller should be connected to four different cables:
1. Controller - Computer.
2. Controller - SLM (crystal).
3. Controller - Power.
4. Controller - 

* Change the SLM screen properties to:

1. Resolution of 600 x 800 pixles.
2. Rate of 60.317 Hz.

### Optical system
* Polarizer - the beam should be linearly polarized.
* Telescope before the SLM - you need the beam to cover the whole crystal.
* Two converging lenses after the SLM - you need it to go into the microscope.

### Codes
* Open a directory with the following files:
1.  `SLM_Screen.mat` - For now (20230323) this is the solution for our code to correctly detect the SLM screen - will be fixed. - check if it is the correct number.
2. 'wavelength.mat'
3. 'dim.mat'
4. 'grid_for_532.mat'
5. 'circle_for_532.mat'
* Open a directory with the following code files (It can be the same directory)
6. 'calibrate.m'
7. 'ccdcenter.m'
8. 'dsphase.m'
9. 'fastphase.m'
10. 'fullscreen.m'
11. 'load_calibration.m'
12. 'script_calibrate.m' 
13.  'vortex.m'
14.  'blank_slm.m'
#### User necessary modifications
##### Will not be necessary after the code future modifications. 
Before running the code the user must do some changes in the current codes and files:
1. 'SLM_Screen.mat' - change it to the correct number.
2. 'wavelength.mat' - Check if it is the correct number. 
3. 'dim.mat' - The resolution of your SLM device - shuold be 600 x 800
4. 'grid_for_532.mat' - change it to the correct wavelength, calculate the hologram using 'GridGen.m' if needed.
5. 'circle_for_532.mat' - change it to the correct wavelength, calculate the hologram using 'CircGen.m' if needed.
6. 'calibrate.m' - Find the line with load function and change the path to your directory.
7. 'ccdcal.m' - Find the line with load function and change the path to your directory.
8. 'ccdcenter.m' - Find the line with load function and change the path to your directory.
