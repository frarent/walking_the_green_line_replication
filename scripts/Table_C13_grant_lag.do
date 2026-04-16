cap est drop _all
//++++++++++++++++++++++++++++++++++++++++++++
// Table C 13: Effect of government sponsored R&D on subsequent 
//	technologies, controlling for the patent grant lag
//++++++++++++++++++++++++++++++++++++++++++++

use "${raw_data_path}/db_green_ipw.dta",clear
gen lag=granting_year-filing_year2

*col 1
qui reghdfe fwd_cits5 i.gvtRD nb_inventors nb_applicants originality ///
	$cpc_4d_green lag [aw=w1], a(id_applicant) vce(robust)
est store est1

estadd scalar r_sq=e(r2):est1
estadd scalar obs=e(N):est1
estadd local  filing "No":est1


*Rel ATE*
qui margins gvtRD [aw=w1], post coefleg
qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
mat b=e(b)
mat v=e(V)
estadd scalar rel_ATE=b[1,1]:est1
estadd scalar rel_ATE_se=sqrt(v[1,1]):est1
estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):est1

*col 2
qui reghdfe fwd_cits5 i.gvtRD nb_inventors nb_applicants originality ///
	$cpc_4d_green i.filing_year2 lag [aw=w1], a(id_applicant) vce(robust)
est store est2

estadd scalar r_sq=e(r2):est2
estadd scalar obs=e(N):est2
estadd local  filing "Yes":est2

*Rel ATE*
qui margins gvtRD [aw=w1], post coefleg
qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
mat b=e(b)
mat v=e(V)
estadd scalar rel_ATE=b[1,1]:est2
estadd scalar rel_ATE_se=sqrt(v[1,1]):est2
estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):est2


esttab est* using "${output_tables}/table_C13.html", align(center) ///
	drop(*fil* *4dig* 0.gvtRD _cons originality ///
	nb_inventors  nb_applicants) starlevels(+ 0.1 * 0.05 ** 0.01) ///
	order(1.gvtRD  lag originality nb_inventors  nb_applicants ) ///
	varlabels( 1.gvtRD "Gvt R&D" lag "grant lag" originality "originality" ///
	nb_inventors "team size"  nb_applicants "# of applicants") ///
	cells(b(star fmt(3)) ///
	se(par([ ]) fmt(3)))legend collabels(, none) ///
	stats (filing rel_ATE rel_ATE_se pvalue r_sq obs, labels ( ///
	"Filing year FE" "Relative ATE" "Relative ATE SE" ///
	"Relative ATE pvalue" "R sq" "N (Patents)" ) ///
	fmt(0 3 3 3 3 0)) ///
	nomtitles ///
	nogaps onecell ///
	title ("Table C 13: Effect of government sponsored R&D on subsequent technologies, controlling for the patent grant lag") ///
	replace

est drop _all


