cap est drop _all

//++++++++++++++++++++++
// TABLE C16: Robustness check on sample selection from never-treated applicants
//+++++++++++++++++++++
import delimited "${raw_data_path}/db_samplesel_expanded.csv", varnames(1) ///
	case(preserve) encoding(ISO-8859-2) clear


** Col 1
qui reg fwd_cits5 insample i.gvtRD originality nb_inventors nb_applicants ///
	$cpc_4d_green i.filing_year2, robust
est store est1
 distinct id_samplesel_exp if e(sample)


estadd scalar ftest=e(F):est1
estadd scalar r_sq=e(r2):est1
estadd scalar obs2 = r(ndistinct):est1
estadd local  filing "Yes":est1
estadd local  assignee "No":est1
estadd local  tech "Yes":est1


*col 2
qui reghdfe fwd_cits5 insample i.gvtRD originality nb_inventors nb_applicants ///
	$cpc_4d_green i.filing_year2, absorb(id_applicant_samplesel_exp) vce(robust)
est store est2
qui distinct id_samplesel_exp if e(sample)


estadd scalar r_sq=e(r2):est2
estadd scalar obs2 = r(ndistinct):est2
estadd local  filing "Yes":est2
estadd local  assignee "Yes":est2
estadd local  tech "Yes":est2

*col 3
qui reg fwd_cits5 insample i.gvtRD originality nb_inventors nb_applicants ///
	$cpc_4d_green i.filing_year2 if e(sample), robust 
est store est3
qui distinct id_samplesel_exp if e(sample)

estadd scalar r_sq=e(r2):est3
estadd scalar obs2 = r(ndistinct):est3
estadd local  filing "Yes":est3
estadd local  assignee "No":est3
estadd local  tech "Yes":est3




esttab est* using "${output_tables}/table_C16.html", align(center) nomtitles  ///
	drop(*fil* d_ei_* 0.gvtRD _cons) starlevels(+ 0.1 * 0.05 ** 0.01) ///
	order(1.gvtRD insample originality nb_inventors   nb_applicants ) ///
	varlabels( 1.gvtRD "Gvt R&D" insample "in-sample" originality "originality" ///
	nb_inventors "team size"  nb_applicants "# of applicants") ///
	cells(b(star fmt(3)) ///
	se(par([ ]) fmt(3)))legend collabels(, none) ///
	stats (filing  tech assignee r_sq obs2, fmt(0 0 0 3 0) labels ( ///
	"Filing year FE" "Technology FE" "Applicant FE" "R sq" "N (Patents)")) ///
	nogaps onecell ///
	title ("Table C 16: Robustness check on sample selection from never-treated applicants") ///
	replace

est drop _all