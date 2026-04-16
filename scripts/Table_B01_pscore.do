cap est drop _all
//+++++++++++++++++++++++++++++++++++++++++++
// Table B 1: Selection into clean tech government sponsored ///
//	 R&D – propensity score
//+++++++++++++++++++++++++++++++++++++++++++

use "${raw_data_path}/db_green.dta",clear


qui probit gvtRD originality nb_inventors nb_applicants ///
	$cpc_4d_green i.filing_year2, vce(robust)
	
estadd scalar ftest=e(chi2)
estadd scalar r_sq=e(r2_p)
estadd scalar obs=e(N)
estadd local  filing "Yes"
estadd local  tech "Yes"

predict ps if e(sample)
est store est_ps_first


esttab est_ps_first using "${output_tables}/table_B01.html", align(center) ///
	nomtitles nodep ///
	drop(*fil* _cons) starlevels(+ 0.1 * 0.05 ** 0.01) ///
	varlabels(originality "originality" ///
	nb_inventors "team size"  nb_applicants "# of applicants" ///
	d_ei_4dig_Y02A "CC adaptation (Y02A)" d_ei_4dig_Y02B ///
	"CCMT buildings (Y02B)" d_ei_4dig_Y02C "GHG capture (Y02C)" ///
	d_ei_4dig_Y02D "CCMT ICT (Y02D)" d_ei_4dig_Y02E "GHG energy (Y02E)" ///
	d_ei_4dig_Y02P "CCMT production (Y02P)" d_ei_4dig_Y02T ///
	"CCMT transport (Y02T)" d_ei_4dig_Y02W "CCMT waste (Y02W)" ///
	d_ei_4dig_Y04S "ICT for energy (Y04S)") ///
	cells(b(star fmt(3)) ///
	se(par([ ]) fmt(3)))legend collabels(, none) ///
	stats (filing  r_sq obs, labels ( ///
	"Filing year FE" "McFadden's R sq" "N (Patents)" ) ///
	fmt(0 3 0)) ///
	nogaps onecell nobaselevels eqlabel(none) ///
	title ("Table B 1: Selection into clean tech government sponsored R&D – propensity score") ///
	replace

	est drop _all