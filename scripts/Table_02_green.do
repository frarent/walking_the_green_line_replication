cap est drop _all
//++++++++++++++++++++++++++++++++++++++++++++
// TABLE 3 - GREEN SAMPLE
//++++++++++++++++++++++++++++++++++++++++++++
use "${data_path}/db_for_restat_green.dta",clear

*column 1
qui reg fwd_cits5 i.gvtRD originality nb_inventors nb_applicants $cpc_4d_green ///
	i.filing_year2, vce(robust)
est store est1

estadd scalar r_sq=e(r2):est1
estadd scalar obs=e(N):est1
estadd local  filing "Yes":est1
estadd local  tech "Yes":est1
estadd local  assignee "No":est1
estadd local  reweight "No":est1

*Rel ATE*
qui margins gvtRD , post coefleg
qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
mat b=e(b)
mat v=e(V)
estadd scalar rel_ATE=b[1,1]:est1
estadd scalar rel_ATE_se=sqrt(v[1,1]):est1
estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):est1


*column 2
use "${data_path}/db_for_restat_green_ipw.dta",clear

qui reg fwd_cits5 i.gvtRD nb_inventors nb_applicants originality $cpc_4d_green ///
	i.filing_year2 [aw=w1] , vce(robust)
est store est2

estadd scalar r_sq=e(r2):est2
estadd scalar obs=e(N):est2
estadd local  filing "Yes":est2
estadd local  assignee "No":est2
estadd local  tech "Yes":est2
estadd local  reweight "IPW":est2

*Rel ATE*
qui margins gvtRD [aw=w1], post coefleg
qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
mat b=e(b)
mat v=e(V)
estadd scalar rel_ATE=b[1,1]:est2
estadd scalar rel_ATE_se=sqrt(v[1,1]):est2
estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):est2



*column 3
qui reghdfe fwd_cits5 i.gvtRD nb_inventors nb_applicants originality $cpc_4d_green ///
	i.filing_year2 [aw=w1], a(id_applicant) vce(robust)
est store est3


estadd scalar r_sq=e(r2):est3
estadd scalar obs=e(N):est3
estadd local  filing "Yes":est3
estadd local  assignee "Yes":est3
estadd local  tech "Yes":est3
estadd local  reweight "IPW":est3

*Rel ATE*
qui margins gvtRD [aw=w1], post coefleg
qui nlcom (_b[1.gvtRD]-_b[0bn.gvtRD])/_b[0bn.gvtRD],post
mat b=e(b)
mat v=e(V)
estadd scalar rel_ATE=b[1,1]:est3
estadd scalar rel_ATE_se=sqrt(v[1,1]):est3
estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):est3






esttab est* using "${output_tables}/table_02.html", align(center) ///
	drop(*fil* *4dig* 0.gvtRD _cons) starlevels(+ 0.1 * 0.05 ** 0.01) ///
	order(1.gvtRD  originality nb_inventors   nb_applicants ) ///
	varlabels( 1.gvtRD "Gvt R&D"  originality "originality" ///
	nb_inventors "team size"  nb_applicants "# of applicants") ///
	cells(b(star fmt(3)) ///
	se(par([ ]) fmt(3)))legend collabels(, none) ///
	stats (filing  tech assignee reweight  rel_ATE rel_ATE_se pvalue r_sq obs, labels ( ///
	"Filing year FE" "Technology FE" "Applicant FE"  "Weighting scheme" ///
	"Relative ATE" "Relative ATE SE" "Relative ATE pvalue" "R sq" "N (Patents)" ) ///
	fmt(0 0 0 0 3 3 3 3 0)) ///
	nogaps onecell ///
	nomtitles ///
	title ("Table 2: Effect of government sponsored R&D on subsequent technologies") ///
	replace

est drop _all