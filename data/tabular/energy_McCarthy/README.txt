Notes on well energy cost estimates
Communication with Ben McCarthy
2020-10-13

Data from:
McCarthy, B., R. Anex, †Y. Wang, †A.D. Kendall, A. Anctil, E. Haacker, and D.W. Hyndman, 2020-accepted, Trends in Water, Energy, and Carbon Emissions from Irrigation: Role of Shifting Technologies and Energy Sources, Environmental Science and Technology

Ben estimated the direct energy (lift energy) to pump groundwater for each WIMAS well ptdiv. This creates an energy estimate for each well each year in MJ.

Methods overview
WIMAS gives you water volume and pump type for each pdiv. You then found the lift energy required based on depth to water. This depth was calculated from groundwater level maps; teh aquifer saturated thickness + hydraulic conductivity was used to estimate the cone of depression around each well and added to the water level depth (depth of cone+depth to water+pressurization lift = total lift). This gives you the direct energy. This direct energy was then scale based on known efficiencies from each well’s energy source and pump types (based on FRIS). 

depth of cone+depth to water+pressurization lift = total lift

Data description
File: AT_AE_Converted_withPump.csv
Ben processed this file for me by taking the lift energy and scaling based on pump efficiencies by energy source found from Yong

Columns
FPDIV_KEY - unique well identifier
LIFT_ENERGY - direct energy (MJ)
EnergyPump - scaled direct energy by pump efficiency (MJ)