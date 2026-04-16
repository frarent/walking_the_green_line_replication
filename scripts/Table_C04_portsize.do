cap est drop _all
//+++++++++++++++++++++++++++++++++++++++++++
// Table C 4: Green government R&D and subsequent technologies, 
//	weighting by the size of the clean tech patent portfolio
//+++++++++++++++++++++++++++++++++++++++++++

use "${raw_data_path}/db_green_ipw.dta",clear


bysort id_applicant: gen n_pat_green = _N 
g w=1/n_pat_green
drop if n_pat_green==1


*col 1
qui reghdfe fwd_cits5 1.gvtRD nb_inventors nb_applicants originality ///
	$cpc_4d_green i.filing_year2 [aw=w], vce(robust)
est store est1

	estadd scalar r_sq=e(r2):est1
	estadd scalar obs=e(N):est1

	*Rel ATE*
	qui margins gvtRD [aw=w], post coefleg
	qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD] ,post
	mat b=e(b)
	mat v=e(V)
	estadd scalar rel_ATE=b[1,1]:est1
	estadd scalar rel_ATE_se=sqrt(v[1,1]):est1
	estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):est1


*cols 2-7
global y cit5_noself_nostrict cit5_noself_strict cit5_out_nostrict cit5_out_strict  cit5_US cit5_country_breadth

foreach var of global y {
di in red "**********"
di in red "***`var'***"
di in red "**********"
	qui reghdfe `var' 1.gvtRD originality nb_inventors nb_applicants ///
		$cpc_4d_green i.filing_year2 [aw=w], vce(robust)
	est store e_`var'
	estadd scalar r_sq=e(r2):e_`var'
	estadd scalar obs=e(N):e_`var'

	*Rel ATE*
	qui margins gvtRD [aw=w], post coefleg
	qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
	mat b=e(b)
	mat v=e(V)
	estadd scalar rel_ATE=b[1,1]:e_`var'
	estadd scalar rel_ATE_se=sqrt(v[1,1]):e_`var'
	estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):e_`var'

	

	}


esttab e* using "${output_tables}/table_C04.html", align(center) ///
	drop(*fil* *4dig* _cons originality nb_inventors nb_applicants) ///
	starlevels(+ 0.1 * 0.05 ** 0.01) ///
	varlabels( 1.gvtRD "Gvt R&D"  originality "originality" ///
	nb_inventors "team size"  nb_applicants "# of applicants") ///
	cells(b(star fmt(3)) ///
	se(par([ ]) fmt(3)))legend collabels(, none) ///
	stats (rel_ATE rel_ATE_se pvalue r_sq obs, labels ( ///
	"Relative ATE" "Relative ATE SE" "Relative ATE pvalue" "R sq" "N (Patents)" ) ///
	fmt(3 3 3 3 0)) ///
	nogaps onecell ///
	title ("Table C 4: Green government R&D and subsequent technologies, weighting by the size of the clean tech patent portfolio") ///
	mtitles("# five-year cit" "noself nostrict" "noself strict" "out nostrict" "out strict"   "cit US" "geo breadth") ///
	replace

est drop _all