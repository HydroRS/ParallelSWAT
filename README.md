# Parallel_spatially_stepwise_calibration-SWAT

Parallel computing-based and Spatially stepwise calibration of SWAT with streamflow observaitons and Satellite-based ET

We have uploaded three versions of codes,i.e., Parallel_SWAT_SetUp, Parallel_SWAT_Modelling and Parallel_SWAT_SUFI_Modeling, which can be used for different purposes.

Please feel free to contact me if you have any questions, zhanglingky@lzb.ac.cn


We here give a brief description and usage of the codes
 
## 1. Parallel_SWAT_SetUp 

Setup the SWAT-CUP is a time-consuming task, here we have wrote a program that can automatically finishe some tasks. This will save a lot a time

(1) automatically update the paramter ranges and the best paramters from last interation

(2) automaticaly update the observations at different time scales over different period

(3) auomatically configuring the SWAT model, such as the time step, number of years to be skipped, and the beginning and end of the simulation, and etc.

## 2. Parallel_SWAT_Modelling
Run SWAT sequentially for an iteartion batch will consume a lot a time, here we share a non-liscienced farework for running SWAT in parallel

(1) The SWAT run in parallel depending on how many precessor cores tha your PC have. For instance, if you have 10 cores, the 300 simulations will reduce to 300/10=30 times.

(2) THe parallel computing framework is compatiable with SWAT-CUP, which means that you can set up, visualize the calibration resutls with the SWAT-CUP, but runing the SWAT in parallel.

(3) The framework is coded with the Matlab language. It is easy to modify the codes

(4) Before the usage of the parallel SWAT modeling, the users should first copy Bat_files in the folder 'Source' to the SWAT-CUP excuting folder, such as: .\test_data\muti_sptail.Sufi2.SwatCup. 

## 3. Parallel_SWAT_SUFI_Modeling
This version of code is used to spatially optimize the objective function for each sub-wateshed in a parallel mamner. The optimization strategt could move beyond the “average effect” of the combined objective optimization, and can make the best use of the spatial and temporal information provided by the satellite-based product.

The test data has been provided in the folder 'test_data'. More details regarding the programs can be found within the codes.

## Citation
Please cite these programs as: Ling Zhang, et al., 2020, A parallel computing-based and spatially stepwise strategy for constraining a semi-distributed hydrological model with streamflow observations and satellite-based evapotranspiration, in preparation. 

