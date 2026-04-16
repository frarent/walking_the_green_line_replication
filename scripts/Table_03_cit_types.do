//++++++++++++++++++++++++++++++++++++++++++++
// TABLE 3 - CITATIONS BREAKDOWN
//++++++++++++++++++++++++++++++++++++++++++++

use "${data_path}/db_for_restat_green_ipw.dta",clear

global y cit5_noself_nostrict cit5_noself_strict cit5_out_nostrict cit5_out_strict  cit5_US cit5_country_breadth

foreach var of global y {
di in red "**********"
di in red "***`var'***"
di in red "**********"
qui	reghdfe `var' i1.gvtRD originality nb_inventors nb_applicants ///
i.filing_year2 $cpc_4d_green [aw=w1], absorb(id_applicant) vce(robust)
	est store e_`var'
	estadd scalar r_sq=e(r2):e_`var'
	estadd scalar obs=e(N):e_`var'
	estadd local  filing "Yes":e_`var'
	estadd local  assignee "Yes":e_`var'
	estadd local  tech "Yes":e_`var'
	estadd local  reweight "IPW":e_`var'
	
	*Rel ATE*
	qui margins gvtRD [aw=w1], post coefleg
	qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
	mat b=e(b)
	mat v=e(V)
	estadd scalar rel_ATE=b[1,1]:e_`var'
	estadd scalar rel_ATE_se=sqrt(v[1,1]):e_`var'
	estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):e_`var'

	}

esttab e_* using "${output_tables}/table_03.html", align(center) ///
	drop(*fil* *4dig* _cons) starlevels(+ 0.1 * 0.05 ** 0.01) ///
	order(1.gvtRD  originality nb_inventors   nb_applicants ) ///
	varlabels( 1.gvtRD "Gvt R&D"  originality "originality" ///
	nb_inventors "team size"  nb_applicants "# of applicants") ///
	cells(b(star fmt(3)) ///
	se(par([ ]) fmt(3)))legend collabels(, none) ///
	stats (filing  tech assignee reweight rel_ATE ///
	rel_ATE_se pvalue r_sq obs, labels ( ///
	"Filing year FE" "Technology FE" "Applicant FE"  "Weighting scheme" ///
	"Relative ATE" "Relative ATE SE" "Relative ATE pvalue" "R sq" "N (Patents)" ) ///
	fmt(0 0 0 0 3 3 3 3 0)) ///
	nogaps onecell ///
	title ("Table 3: Effect of government sponsored R&D considering different kinds of spillovers") ///
	mtitles("noself nostrict" "noself strict" "out nostrict" "out strict"   "cit US" "geo breadth") ///
	replace

est drop _all
