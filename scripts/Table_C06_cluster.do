cap est drop _all
//++++++++++++++++++++++++++++++++++++++++++++
// Table C 6: Effect of government sponsored R&D on subsequent 
//	technologies, clustered robust standard errors
//++++++++++++++++++++++++++++++++++++++++++++

use "${raw_data_path}/db_green_ipw.dta",clear

// NUMBER OF CPC CLASSES PER PATENT
egen n_cpc=rowtotal($cpc_4d_green ),missing

// TECH_X_YEAR CLUSTERS (144 clusters)

g cse_techXyear=0

local j=0
foreach var of varlist  d_ei_4dig_* {
	forvalues i=1999(1)2014 {
	local j=`j'+1
	recode cse_techXyear (0=`j') if `var'==1 & filing_year2==`i'
	}
}

di 16*9
qui sum cse_techXyear
di r(max)


global cse cse_techXyear

keep if n_cpc==1 //use only patents with one CPC assigned


*col 1
qui reghdfe fwd_cits7 i.gvtRD originality nb_inventors nb_applicants ///
	$cpc_4d_green i.filing_year2 [aw=w1], absorb(id_applicant) vce(cluster $cse)
est store est1

estadd scalar r_sq=e(r2):est1
estadd scalar obs=e(N):est1

*Rel ATE*
qui margins gvtRD, post coefleg
qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
mat b=e(b)
mat v=e(V)
estadd scalar rel_ATE=b[1,1]:est1
estadd scalar rel_ATE_se=sqrt(v[1,1]):est1
estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):est1



*cols 2-7 
global y cit7_noself_nostrict cit7_noself_strict cit7_out_nostrict ///
	cit7_out_strict  cit7_US cit7_country_breadth

foreach var of global y {
	di in red "**********"
	di in red "***`var'***"
	di in red "**********"
	qui reghdfe `var' 1.gvtRD originality nb_inventors nb_applicants ///
		$cpc_4d_green i.filing_year2  [aw=w1], absorb(id_applicant) vce(cluster $cse)
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
	
	
esttab e* using "${output_tables}/table_C06.html", align(center) ///
	drop(*fil* *4dig* _cons 0.gvtRD originality nb_inventors nb_applicants) ///
	starlevels(+ 0.1 * 0.05 ** 0.01) ///
	varlabels( 1.gvtRD "Gvt R&D"  originality "originality index" ///
	nb_inventors "team size"  nb_applicants "# of applicants") ///
	cells(b(star fmt(3)) ///
	se(par([ ]) fmt(3)))legend collabels(, none) ///
	stats (rel_ATE rel_ATE_se pvalue r_sq obs, labels ( ///
	"Relative ATE" "Relative ATE SE" "Relative ATE pvalue" "R sq" "N (Patents)" ) ///
	fmt(3 3 3 3 0)) ///
	nogaps onecell ///
	title ("Table C 6: Effect of government sponsored R&D on subsequent technologies, clustered robust standard errors") ///
	mtitles("# five-year cit " "noself nostrict" "noself strict" "out nostrict" "out strict" "cit US" "geo breadth") ///
	replace
est drop _all