cap est drop _all
//+++++++++++++++++++++++++++++++++++++++++++
// Table C 12: Effect of green government sponsored R&D on 
// subsequent technologies– technology-by-year fixed effects
//+++++++++++++++++++++++++++++++++++++++++++


use "${data_path}/db_for_restat_green_ipw.dta",clear

*col 1
qui reghdfe fwd_cits5 i.gvtRD nb_inventors nb_applicants originality  [aw=w1], a(id_applicant i.filing_year2 ///
	$cpc_4d_green ///
	$techXyear) vce(robust)
est store est1

estadd scalar r_sq=e(r2):est1
estadd scalar obs=e(N):est1


*Rel ATE*
qui margins gvtRD [aw=w1], post coefleg
qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
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
	qui reghdfe `var' 1.gvtRD originality nb_inventors nb_applicants [aw=w1], absorb(id_applicant i.filing_year2 ///
		$cpc_4d_green ///
		$techXyear) vce(robust)
	est store e_`var'
	estadd scalar r_sq=e(r2):e_`var'
	estadd scalar obs=e(N):e_`var'

		*Rel ATE*
	qui margins gvtRD [aw=w1], post coefleg
	qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
	mat b=e(b)
	mat v=e(V)
	estadd scalar rel_ATE=b[1,1]:e_`var'
	estadd scalar rel_ATE_se=sqrt(v[1,1]):e_`var'
	estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):e_`var'


	}
	
esttab e* using "${output_tables}/table_C12.html",align(center) drop(0.gvtRD ///
	_cons originality nb_inventors nb_applicants) starlevels(+ 0.1 * 0.05 ** 0.01) ///
	varlabels( 1.gvtRD "Gvt R&D"  originality "originality" ///
	nb_inventors "team size"  nb_applicants "# of applicants") ///
	cells(b(star fmt(3)) ///
	se(par([ ]) fmt(3)))legend collabels(, none) ///
	stats (rel_ATE rel_ATE_se pvalue r_sq obs, labels ( ///
	"Relative ATE" "Relative ATE SE" "Relative ATE pvalue" "R sq" "N (Patents)" ) ///
	fmt(3 3 3 3 0)) ///
	nogaps onecell ///
	mtitles("# five-year cit" "noself nostrict" "noself strict" "out nostrict" "out strict"   "cit US" "geo breadth") ///
	title ("Table C 12: Effect of green government sponsored R&D on subsequent technologies, technology-by-year fixed effects") ///
	replace

est drop _all