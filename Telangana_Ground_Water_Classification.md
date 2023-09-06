# Telangana Ground Water Classification

## Introduction

Groundwater plays a vital role in sustaining agricultural activities in India. However, there has been a concerning decline not only 
in groundwater levels but also in its quality. Poor-quality groundwater can lead to issues such as salinity, ion toxicity, and soil 
infiltration problems, all of which can have detrimental effects on crop production. To address these critical challenges,we aim to 
leverage machine learning techniques to classify groundwater quality based on its chemical composition. This classification will enable
us to assess the suitability and safety of groundwater for various agricultural purposes. Also, help Farmers to efficiently use the water
based on the quality of water they already have.

## Objectives
* To use Machine Learning models to classify the quality of groundwater for the
purpose of irrigation.
* To know Which type of crops should be selected according to the quality of water.
* Based on the quality of water whether irrigation is possible for the existing type of
soil in the region.

## Source 
https://data.telangana.gov.in/search/type/dataset

## Data Variables
* Groundwater Level (gwl)-
* pH 
* Electric Conductivity (E.C) 
* Carbonate and Bicarbonate (CO3 2- and HCO3-) 
* Chlorine (Cl) 
* Fluorine (Fl) 
* Nitrate (NO3) 
* Sulphate (SO4) 
* Sodium (Na) 
* Potassium (K) 
* Calcium (Ca) 
* Magnesium (Mg)
* Total Hardness (T.H) -T.H=(2.497*ca) +(4.118*mg)
* Total Dissolved Solids (TDS) -TDS=0.64*E.C
* Sodium Absorption Ratio (SAR) -SAR=(Na*0.043498)/(sqrt(((Ca*0.049903) +(Mg*0.082288))/2))
## Classification 
The samples collected from the monitoring wells in Telangana fall into 9
classes as described below.
* C1S1: Low salinity and low sodium waters are good for irrigation and can be used with
most crops with no restriction on use on most of the soils.
* C2S1: Medium salinity and low sodium waters are good for irrigation and can be used on
all most all soils with little danger of development of harmful levels of exchangeable
sodium if a moderate amount of leaching occurs. Crops can be grown without any special
consideration for salinity control.
* C3S1: The high salinity and low sodium waters require good drainage. Crops with good
salt tolerance should be selected.
* C3S2: The high salinity and medium sodium waters require good drainage and can be used
on coarse - textured or organic soils having good permeability.
* C3S3: These high salinity and high sodium waters require special soil management, good
drainage, high leaching and organic matter additions. Gypsum amendments make feasible
the use of these waters.
* C4S1: Very high salinity and low sodium waters are not suitable for irrigation unless the
soil must be permeable and drainage must be adequate. Irrigation waters must be applied
in excess to provide considerable leaching. Salt tolerant crops must be selected.
* C4S2: Very high salinity and medium sodium waters are not suitable for irrigation on fine
textured soils and low leaching conditions and can be used for irrigation on coarse textured
or organic soils having good permeability.
* C4S3: Very high salinity and high sodium waters produce harmful levels of exchangeable
sodium in most soils and will require special soil management, good drainage, high
leaching, and organic matter additions. The Gypsum amendment makes feasible the use of
these waters.
* C4S4: Very high salinity and very high sodium waters are generally unsuitable for
irrigation purposes. These are sodium chloride types of water and can cause sodium
hazards. It can be used on coarse-textured soils with very good drainage for very high salt-
tolerant crops. Gypsum amendments make feasible the use of these waters.
## Data Variables Measurement of Scales
* Ratio Scale-GWL, E.C, TDS, CO3, HCO3, Cl,F, NO3, SO4, NA, K, Ca, Mg, T.H, SAR
* Interval Scale-pH
* Nominal Scale-Classification
