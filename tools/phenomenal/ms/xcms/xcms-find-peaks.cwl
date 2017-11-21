#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

baseCommand: findPeaks.r

hints:
  SoftwareRequirement:
    packages:
      xcms:
        specs: [ https://identifiers.org/rrid/RRID:SCR_015538 ]
  DockerRequirement:
    dockerPull: biocontainers/xcms

inputs:
  spectra:
    type: File[]
    format: edam:format_3244 # mzML
    inputBinding:
      prefix: input=
      separate: false

  ppm: float
  peakwidthLow: float
  peakwidthHigh: float
  noise: float
  polarity: string
  realFileName: string

outputs:
  deconvoluted_peaks:
    type: File
    outputBinding:
      glob: output.Rdata

arguments:
 - output=output.Rdata
 - ppm=$(inputs.ppm)
 - peakwidthLow=$(inputs.peakwidthLow)
 - peakwidthHigh=$(inputs.peakwidthHigh)
 - noise=$(inputs.noise)
 - polarity=$(inputs.polarity)
 - realFileName=$(inputs.realFileName)


label: Find peaks in mzML file and generate a xcmsSet using XCMS centWave algorithm.

$namespaces: 
  iana: "https://www.iana.org/assignments/media-types/"
  edam: "http://edamontology.org"

#$schemas:
#  - http://edamontology.org/EDAM_1.19.owl

#   <inputs>
#    label="mzML file" help="A mzML file that includes data from a MS measurement" />
#     <param name="ppm" type="text" value="10"  label="PPM" help="Maxmial tolerated m/z deviation in consecutive scans, in ppm (parts per million)" />
#     <param name="peakwidthLow" type="text" value="4"  label="PeakWidthLow" help="Minimum value of chromatographic peak width in seconds" />
#     <param name="peakwidthHigh" type="text" value="30"  label="PeakWidthHigh" help="Maximum value of chromatographic peak width in seconds" />
#     <param name="noise" type="text" value="1000"  label="Noise" help="Argument which is useful for data that was centroided without any intensity threshold, centroids with intensity smaller noise are omitted from ROI detection" />
#     <param name="polarity" type="select" value="positive" label="Polarity" help="Filter raw data for positive/negative scans">
#       <option value="positive" selected="True">positive</option>
#       <option value="negative" selected="False">negative</option>
#     </param>
#     <param name="infilecvs" type="data" format="csv" optional="True" multiple="False" label="Input CSV file for setting the phenotype (see the help)" />
#     <param name="phenocol" type="text" optional="True" label="Column name showing the class of the raw files (the phenotype file)"/>
#   </inputs>
#   <outputs>
#     <data name="xcms_find_peaks_output_1" type="data" format="rdata" label="xcms-find-peaks data" />
#   </outputs>
#   <help>
#  
# .. class:: infomark
# 
# | **Tool update: See the 'NEWS' section at the bottom of the page**
# 
# ---------------------------------------------------
# 
# .. class:: infomark
# 
# **Authors**
# 
# | **Payam Emami (payam.emami@medsci.uu.se)** and **Christoph Ruttkies (christoph.ruttkies@ipb-halle.de)** wrote and maintain this wrapper for XCMS-Set generation and peak detection.
# 
# ---------------------------------------------------
# 
# .. class:: infomark
# 
# **Please cite**
# 
# R Core Team (2013). R: A language and Environment for Statistical Computing. http://www.r-project.org
# 
# ---------------------------------------------------
# 
# .. class:: infomark
# 
# **References**
# 
# | Smith, C.A., Want, E.J., O'Maille, G., Abagyan,R., Siuzdak and G. (2006). "XCMS: Processing mass spectrometry data for metabolite profiling using nonlinear peak alignment, matching and identification." Analytical Chemistry, 78, pp. 779-787.
# | Tautenhahn R, Boettcher C and Neumann S (2008). "Highly sensitive feature detection for high resolution LC/MS." BMC Bioinformatics, 9, pp. 504.
# | Benton HP, Want EJ and Ebbels TMD (2010). "Correction of mass calibration gaps in liquid chromatography-mass spectrometry metabolomics data." BIOINFORMATICS, 26, pp. 2488.
# 
# ---------------------------------------------------
# 
# =====================
# XMCS Find Peaks
# =====================
# 
# -----------
# Description
# -----------
# 
# | This module handles the construction of XCMS-Set objects from mzML input files and finds peaks in batch mode.
# 
# -----------
# Input files
# -----------
# 
# +------------------------------+------------+
# | File                         |   Format   |
# +==============================+============+
# | 1) mzML file   	       |    mzML    |
# +------------------------------+------------+
# | 2) CSV file                  |    CSV     |
# +------------------------------+------------+
# 
# 
# ----------
# Parameters
# ----------
# 	  
# mzML file
# 	| A mzML file that includes data from a MS measurement
#         |
# 
# PPM
#         | Maxmial tolerated m/z deviation in consecutive scans, in ppm (parts per million)
#         |
# 
# PeakWidthLow
# 	| Minimum value of chromatographic peak width in seconds
# 	|
# 
# PeakWidthHigh
# 	| Maximum value of chromatographic peak width in seconds
# 	|
# 
# Noise
# 	| Argument which is useful for data that was centroided without any intensity threshold, centroids with intensity smaller noise are omitted from ROI detection
# 	|
# 
# Polarity
# 	| Filter raw data for positive/negative scans
# 	|
# 
# CSV file
#         | This file is used to set class of the samples being analyzed. The file should have at least two column: the first column is showing the raw file name and extension (for example sample1.mzML) and the second column should show it's phenotype type. This file is a comma separated file and should container header (see the example).
# 	|
# 
# +----------------+----------+
# | RawFile        | Class    |
# +----------------+----------+
# | Sample1.mzML   | Sample   |
# +----------------+----------+
# | Sample2.mzML   | Sample   |
# +----------------+----------+
# | Sample3.mzML   | Sample   |
# +----------------+----------+
# | Sample4.mzML   | Sample   |
# +----------------+----------+
# | Blank1.mzML    | Blank    |
# +----------------+----------+
# | Blank2.mzML    | Blank    |
# +----------------+----------+
# | Blank3.mzML    | Blank    |
# +----------------+----------+
# | D1.mzML        | D1       |
# +----------------+----------+
# | D2.mzML        | D2       |
# +----------------+----------+
# | D3.mzML        | D3       |
# +----------------+----------+
# 
# Phenotype column
#         | This should show the column name in the CSV file representing the class of the metabolite. In the case of the above table it should be set to "Class" (without quotation).
#         |
# 
# ------------
# Output files
# ------------
# 	
# xcms_find_peaks_output_1.rdata
# 	| A rdata file containing a XCMS-Set generated from the input mzML file
#         |
# 
# ---------------------------------------------------
# 
# ----
# NEWS
# ----
# 
# CHANGES IN VERSION 0.2
# ========================
# 
# Adding class information using a CSV file
# 
# CHANGES IN VERSION 0.1
# ========================
# 
# First version
#   
#   </help>
# </tool>
