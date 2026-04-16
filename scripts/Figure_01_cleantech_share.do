cap est drop all

//++++++++++++++++++++++++++++++++++++++++++++
// Figure 1: Share of government sponsored and non-sponsored patents ///
//	by type of clean technology
//++++++++++++++++++++++++++++++++++++++++++++

use "${data_path}/db_for_restat_green.dta",clear

keep d_ei_4dig_* gvtRD
gen id=_n
rename (d_ei_4dig_*) (cpc#), addnumber(1)
reshape long cpc, i(id) j(which)


lab def which 1 "Y02A - adaptation to CC" 2 "Y02B - CCMT buildings" ///
	3 "Y02C - GHG sequestration" 4 "Y02D - CCMT for ICT" ///
	5 "Y02E - GHG reduction for energy" 6"Y02P - CCMT for production" ///
	7"Y02T - CCMT for transportation" ///
	8"Y02W - CCMT for waste" 9"Y04S - ICT for energy"
lab values which which

gen cpc_gvtRD=cpc if gvtRD==1
gen cpc_nogvtRD=cpc if gvtRD==0

collapse cpc_gvtRD cpc_nogvtRD,by(which)

graph hbar cpc*, over(which,label(angle(25) labsize(vsmall))) ///
	ytitle("Share of cleantech patents",size(small)) ///
	legend(label(1 "Gvt R&D") label(2 "No Gvt R&D") pos(6) row(1))

graph export "${output_figures}/figure_01.png", replace wid(2000)