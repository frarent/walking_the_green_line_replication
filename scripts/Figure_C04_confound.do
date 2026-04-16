cap est drop _all
//++++++++++++++++++++++++++++++++++++++++++++
// Figure 3:  effect of an omitted confounding variable on the partial
//	correlation between Gvt R&D and five-year citations
//++++++++++++++++++++++++++++++++++++++++++++

use "${data_path}/db_for_restat_green_ipw.dta",clear

qui pcorr fwd_cits5 gvtRD nb_inventors nb_applicants originality ///
	$cpc_4d_green i.filing_year2

mat temp=r(p_corr)
local pcor_gvtRD=temp[1,1]

qui reghdfe fwd_cits5 gvtRD nb_inventors nb_applicants originality ///
	$cpc_4d_green i.filing_year2 [aw=w1], a(id_applicant) vce(robust)

qui reg fwd_cits5 gvtRD nb_inventors nb_applicants originality ///
	$cpc_4d_green i.filing_year2 i.id_applicant [aw=w1], vce(robust)


qui konfound gvtRD


twoway function (`pcor_gvtRD' - x)/(1-x), ra(-0.002 0.02) ///
ytitle("Partial correlation between Gvt R&D and # of five-year cit") ///
xtitle("Effect of main controls and omitted confounding variable (EOCV)") ///
xline(-.0002, lcolor(gs13) lpattern(dash)) ///
xline(.0009, lcolor(gs11) lpattern(dash)) ///
xline(.003, lcolor(gs9) lpattern(dash)) ///
xline(0.0109, lcolor(gs7) lpattern(dash)) ///
text(0.046 0.0109 "EOCV",size(small) color(gs7)) ///
text(0.043 .003 "team size",size(small) color(gs9)) ///
text(0.035 .0009 "originality", size(small) color(gs11)) ///
text(0.03 -.0002 "# of applicants", size(small) color(gs13))
graph export "${output_figures}/figure_C04.png", replace wid(2000)


