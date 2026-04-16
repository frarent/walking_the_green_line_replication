cap est drop _all
//++++++++++++++++++++++++++++++++++++++++++++
// Figure B1: Variance ratio of residuals vs bias before and after matching
//++++++++++++++++++++++++++++++++++++++++++++

use "${data_path}/db_for_restat_green.dta",clear

qui xi: psmatch2 gvtRD originality nb_inventors nb_applicants ///
	$cpc_4d_green i.filing_year2, out(fwd_cits5) ate common trim(5)

pstest, both label scatter support(_support)  notable
graph export "${output_figures}/figure_B01.png", replace wid(2000)


//++++++++++++++++++++++++++++++++++++++++++++
// Figure B2: Covariate bias before and after matching 
//++++++++++++++++++++++++++++++++++++++++++++


qui xi: psmatch2 gvtRD originality nb_inventors nb_applicants ///
	$cpc_4d_green i.filing_year2, out(fwd_cits5) ate common trim(5)

pstest, both  label graph support(_support) notable
graph export "${output_figures}/figure_B02.png", replace wid(2000)

