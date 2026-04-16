cap est drop _all
//++++++++++++++++++++++
// Table C 15: Comparison of non-treated clean tech patents with clean //
//	tech patents of never-treated applicants (n= 155,498)
//+++++++++++++++++++++

import delimited "${raw_data_path}/db_samplesel.csv", varnames(1) ///
	case(preserve) encoding(ISO-8859-2) clear
qui reg fwd_cits5 originality nb_inventors

qui xi: estpost	ttest fwd_cits5 originality nb_inventors ///
	if gvtRD==0&e(sample) ,by(insample)
mat b1=e(N_1)
mat b2=e(N_2)
estadd scalar obs1=b1[1,1]
estadd scalar obs2=b2[1,1]

label var fwd_cits5 "# of five-year cit"
label var originality "originality"
label var nb_inventors "team size"
label var nb_applicants "# of applicants"

esttab using "${output_tables}/table_C15.html", align(center) cell((mu_2(fmt(%12.3fc) label("non-treated" ///
	"(n=33,918)")) mu_1(fmt(%12.3fc) label("never-treated" ///
	"(n=121,580)")) t(fmt(%12.3fc) star label("difference t test")) )) label varwidth(40) ///
	starlevels(+ 0.1 * 0.05 ** 0.01) ///
	title (Table C 15 Comparison of non-treated clean tech patents with ///
	clean tech patents of never-treated applicants (n= 155,498)) noobs nonum ///
	replace

est drop _all