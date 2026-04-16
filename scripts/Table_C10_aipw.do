cap est drop _all
//+++++++++++++++++++++++++++++++++++++++++++
// Table C 10: Effect of green government R&D on subsequent 
//	technologies, augmented inverse-probability-weighted estimator
//+++++++++++++++++++++++++++++++++++++++++++

use "${data_path}/db_for_restat_green_ipw.dta",clear


qui teffects aipw (fwd_cits5 nb_inventors nb_applicants originality ///
	$cpc_4d_green i.filing_year2 ) (gvtRD  nb_inventors nb_applicants ///
	originality $cpc_4d_green ///
	i.filing_year2,probit), coeflegend vce(robust)  nolog



estadd scalar obs=e(N)
est store est1

qui nlcom _b[ATE:r1vs0.gvtRD]/ _b[POmean:0.gvtRD],post
mat b=e(b)
mat v=e(V)
estadd scalar rel_ATE=b[1,1]:est1
estadd scalar rel_ATE_se=sqrt(v[1,1]):est1
estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):est1





global y cit5_noself_nostrict cit5_noself_strict cit5_out_nostrict cit5_out_strict  cit5_US cit5_country_breadth

foreach var of global y {
di in red "**********"
di in red "***`var'***"
di in red "**********"
	qui teffects aipw (`var' nb_inventors nb_applicants originality ///
		$cpc_4d_green i.filing_year2 ) (gvtRD  nb_inventors ///
		nb_applicants originality $cpc_4d_green ///
		i.filing_year2,probit), coeflegend vce(robust)  nolog
		
	
	estadd scalar obs=e(N)
	est store e_`var'

	qui nlcom _b[ATE:r1vs0.gvtRD]/ _b[POmean:0.gvtRD],post
	mat b=e(b)
	mat v=e(V)
	estadd scalar rel_ATE=b[1,1]:e_`var'
	estadd scalar rel_ATE_se=sqrt(v[1,1]):e_`var'
	estadd scalar pvalue = 2*normal(-abs(b[1,1]/sqrt(v[1,1]))):e_`var'

	}

esttab e*  using "${output_tables}/table_C10.html", align(center) ///
	keep(r1vs0.gvtRD) starlevels(+ 0.1 * 0.05 ** 0.01) ///
	varlabels( r1vs0.gvtRD "Gvt R&D"  originality "originality" ///
	nb_inventors "team size"  nb_applicants "# of applicants") ///
	cells(b(star fmt(3)) ///
	se(par([ ]) fmt(3)))legend collabels(, none) ///
	stats (rel_ATE rel_ATE_se pvalue obs, labels ( ///
	"Relative ATE" "Relative ATE SE" "pvalue" "N (Patents)" ) ///
	fmt(3 3 3 0)) ///
	nogaps onecell ///
	mtitles("# five-year cit" "noself nostrict" "noself strict" "out nostrict" ///
	"out strict"   "cit US" "geo breadth") ///
	title ("Table C 10: Effect of green government R&D on subsequent technologies – augmented inverse-probability-weighted estimator") ///
	replace

est drop _all