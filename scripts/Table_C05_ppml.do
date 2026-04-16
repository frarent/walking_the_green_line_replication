cap est drop _all
//+++++++++++++++++++++++++++++++++++++++++++
// Table C 5: Effect of green government sponsored R&D on subsequent 
//	technologies, PPML with multiple fixed effects
//+++++++++++++++++++++++++++++++++++++++++++

use "${raw_data_path}/db_green_ipw.dta",clear


*col 1
qui ppmlhdfe fwd_cits5 i.gvtRD nb_inventors nb_applicants originality ///
	$cpc_4d_green i.filing_year2 [pw=w1], a(id_applicant) vce(robust) d nolog
est store est1
estadd scalar r_sq=e(r2_p):est1
estadd scalar obs=e(N):est1

*Rel ATE*
qui margins gvtRD [pw=w1], post coefleg
qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
mat b=e(b)
mat v=e(V)
estadd scalar rel_ATE=b[1,1]:est1
estadd scalar rel_ATE_se=sqrt(v[1,1]):est1
estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):est1





//++++++++++++++++++++++++++++++++++++++++++++
// CITATIONS BREAKDOWN
//++++++++++++++++++++++++++++++++++++++++++++

global y cit5_noself_nostrict cit5_noself_strict cit5_out_nostrict cit5_out_strict  cit5_US cit5_country_breadth

qui ppmlhdfe cit5_out_strict 1.gvtRD originality nb_inventors nb_applicants ///
	$cpc_4d_green i.filing_year2 [pw=w1], absorb(id_applicant)

keep if e(sample)

foreach var of global y {
di in red "**********"
di in red "***`var'***"
di in red "**********"

qui	ppmlhdfe `var' 1.gvtRD originality nb_inventors nb_applicants ///
	$cpc_4d_green i.filing_year2  [pw=w1] , absorb(id_applicant) vce(robust) d nolog
	est store est_`var'
	estadd scalar r_sq=e(r2_p):est_`var'

	*Rel ATE*
	qui margins gvtRD [pw=w1], post coefleg
	qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
	mat b=e(b)
	mat v=e(V)
	estadd scalar rel_ATE=b[1,1]:est_`var'
	estadd scalar rel_ATE_se=sqrt(v[1,1]):est_`var'
	estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):est_`var'

	}
	

esttab est* using "${output_tables}/table_C05.html", align(center) ///
	drop(*fil* *4dig* _cons 0.gvt* originality nb_inventors nb_applicants) ///
	starlevels(+ 0.1 * 0.05 ** 0.01) ///
	varlabels( 1.gvtRD "Gvt R&D"  originality "originality" ///
	nb_inventors "team size"  nb_applicants "# of applicants") ///
	cells(b(star fmt(3)) ///
	se(par([ ]) fmt(3)))legend collabels(, none) ///
	stats (rel_ATE rel_ATE_se pvalue r_sq N, labels ( ///
	"Relative ATE" "Relative ATE SE" "Relative ATE pvalue" "R sq" "N (Patents)" ) ///
	fmt(3 3 3 3 0)) ///
	nogaps onecell ///
	title ("Table C 5: Effect of green government sponsored R&D on subsequent technologies – PPML with multiple fixed effects") ///
	mtitles("# five-year cit" "noself nostrict" "noself strict" "out nostrict" "out strict"   "cit US" "geo breadth") ///
	replace
	
