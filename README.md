# Single-Exposure-Coded-Snapshot

Implemented Video compressive sensing architecture from the paper on [single shot video](https://www.cs.columbia.edu/CAVE/projects/single_shot_video/) published in ICCV 2011  
Name of the paper: Video from a Single Coded Exposure Photograph using a Learned Over-Complete Dictionary  
Link to paper: https://www.cs.columbia.edu/CAVE/publications/pdfs/Hitomi_ICCV2011.pdf

## Abstract about Coded Snapshot

The aim is to get higher temporal gains in video acquisition without a significant loss in spatial resolution.  
The Single Exposure image is a coded superposition (summation) of T sub-frames within a unit integration time of the video camera.  
It overcomes space-time tradeoff using pre-pixel coded exposure pattern.  
For better reconstruction, there are restrictions on the coded exposure pattern. However, here we have assumed a symmetric bernoulli distribution is used for the pattern (**C**).  
We pose the above relation in form of a sparse coding problem, with **C** forms the sensing matrix **S** and the frames are sparse in 2D DCT **Phi**.  
**I** = **C** * **Phi** * **Theta**, where **I** is the coded snapshot and **Theta** are the sparse coefficients.  
We use Orthogonal Matching Pursuit (OMP) to solve for **Theta** given **I** and known **C** and **Phi**.

## Code

Code for OMP is present in form of a function in <tt>omp.m</tt>  
Code for Experiments is present in form of a function in <tt>main.m</tt>
