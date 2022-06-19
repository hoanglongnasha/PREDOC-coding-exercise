// Washtenaw County code: 26161 (Michigan state code: 26)
cd "D:\STATA\PRE Workshop coding exercise\Data\Part1"

// Make the datasets into STATA ready format
import delimited "county_county_sci.tsv", clear
save county_sci, replace
import delimited "county_description.csv", clear
save county_description, replace

// Merge the SCI dataset to show county of users
* Merge first for the user
use county_sci, clear
rename user_loc county_fips
merge m:1 county_fips using county_description, keep(master match) keepusing(county_name state_name)
rename county_name user_county
rename state_name user_state
rename county_fips user_loc
drop _merge

* Merge second time for friend
rename fr_loc county_fips
merge m:1 county_fips using county_description, keep(master match) keepusing(county_name state_name)
rename county_name fr_county
rename state_name fr_state
rename county_fips fr_loc

* Drop missing values
drop if missing(user_county) | missing(fr_county)
drop _merge
save interim1, replace

// Graphs
* Summarize the distribution of Washtenaw's Social Connectedness Index to other counties
preserve
drop if user_county != "Washtenaw"
collapse (mean) mean_sci = scaled_sci (count) count = scaled_sci, by(fr_county)
gsort -mean_sci
graph hbar mean_sci in 1/20 if fr_county != "Washtenaw", over(fr_county, sort(1) descending) ytitle("Mean of SCI") name(first_graph) //First graph
graph save first_graph "Graph 1", replace
restore

* Merge distance data
import delimited sf12010countydistancemiles, replace
save distance, replace
rename county1 user_loc
rename county2 fr_loc
merge 1:m user_loc fr_loc using interim1, keep(match using)
rename mi_to_county distance
drop _merge
replace distance = 0 if distance == . & user_loc == fr_loc

preserve
drop if user_county != "Washtenaw"
collapse (mean) mean_sci distance, by(user_county fr_county)
gen log_sci = log(mean_sci)
scatter log_sci distance if fr_county != "Washtenaw" & distance < 2000, mcolor(blue%10) || qfit log_sci distance if fr_county != "Washtenaw" & distance < 2000 || lpoly log_sci distance if fr_county != "Washtenaw" & distance < 2000, name(graph1, replace)
scatter log_sci distance if fr_county != "Washtenaw" & distance >= 2000, mcolor(blue%10) || qfit log_sci distance if fr_county != "Washtenaw" & distance >= 2000 || lpoly log_sci distance if fr_county != "Washtenaw" & distance >= 2000, name(graph2, replace)
graph combine graph1 graph2, ycommon altshrink name(graph_combined) //Graph 2
graph save graph_combined "Graph 2", replace
restore

// Measure of network concentration, i.e., how connected is one county to itself (SCI of that state to itself)
keep if user_loc == fr_loc
drop fr_loc fr_county fr_state
rename user_loc county_fips
rename user_county county 
rename user_state state
save interim2, replace

* Merge demographics data
import delimited county_demographics.csv, clear
reshape wide value, i(county_fips) j(measure) string
rename value* *
save county_demographics, replace

user interim2, clear
merge 1:1 county_fips using county_demographics
save merged_demo, replace
