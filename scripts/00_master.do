*=============================================================================*
* Project title: Walking the Green Line: Government Sponsored R&D
*                and Clean Technologies in the US
* Created by: Francesco Rentocchini and Gianluca Orsatti
* Date: 16/04/2026
*=============================================================================*

// Clear Memory
*=============================================================================*
clear all
macro drop _all


// Create file paths
*=============================================================================*

cap mkdir "data"
cap mkdir "data/data_for_analysis"
cap mkdir "data/raw_data"

cap mkdir "temp"

cap mkdir "output"
cap mkdir "output/tables"
cap mkdir "output/figures"

cap mkdir "logs"

cap mkdir "scripts"
cap mkdir "scripts/auxiliary"

cap mkdir "stata_packages"


// Set your file paths (relative to project root)
*=============================================================================*

global data_path         "data/data_for_analysis"
global raw_data_path     "data/raw_data"
global temp_path         "temp"

global script_path       "scripts"
global aux_path          "scripts/auxiliary"

global output            "output"
global output_tables     "output/tables"
global output_figures    "output/figures"
global log_path          "logs"

global rootdir `"`c(pwd)'"'


// Use included packages (local stata_packages folder)
*=============================================================================*

cap adopath - PERSONAL
cap adopath - PLUS
cap adopath - SITE
cap adopath - OLDPLACE
adopath + "stata_packages"
net set ado "stata_packages"


// Set options (0 = skip; 1 = run)
*=============================================================================*

// Install required packages
global install_packages  0

// Build analysis datasets from raw CSVs
// (not needed for replication — pre-built DTA files are in data/raw_data/)
global build_data        0

// Run main manuscript tables (Table 02–04)
global tables_main       1

// Run main manuscript figures (Figure 01–02)
global figures_main      1

// Run appendix tables (Table B01, Table C02–C16)
global tables_appendix   1

// Run appendix figures (Figure B01+B02, Figure C01–C04)
global figures_appendix  1

// Run housekeeping (clear temp and dta folders)
global housekeep         1

// Set table output format (0 = html; 1 = tex)
global table_tex         0


// Initialize log and record system parameters
*=============================================================================*

cap log close
local datetime : di %tcCCYY.NN.DD!-HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'
local logfile "$log_path/`datetime'.log.txt"
log using "`logfile'", text

di "Begin date and time: $S_DATE $S_TIME"
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Variant:       `=cond( c(MP),"MP",cond(c(SE),"SE",c(flavor)) )'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"

// Set date
global date = subinstr("$S_DATE", " ", "-", .)

// Stata version
version 16

// Screen width for log files
set linesize 255

// Table format
if $table_tex == 1 {
	global tab_fmt tex
	global tex booktabs fragment
}
else {
	global tab_fmt html
}

// Allow screen to move without clicking more
set more off

// Drop everything in mata
matrix drop _all


// Fixed effects macros
*=============================================================================*

include "${aux_path}/AUX_01_fe_macros.do"


// Run do-files
*=============================================================================*

// Install required packages
if $install_packages == 1 {
	include "${script_path}/00a_packages_install.do"
}


// Build analysis datasets from raw CSVs
if $build_data == 1 {
	include "${script_path}/00b_databuild.do"
}


// Main manuscript tables
if $tables_main == 1 {
	include "${script_path}/Table_02_green.do"
	include "${script_path}/Table_03_cit_types.do"
	include "${script_path}/Table_04_SSIV.do"
}


// Main manuscript figures
if $figures_main == 1 {
	include "${script_path}/Figure_01_cleantech_share.do"
	include "${script_path}/Figure_02_event_study.do"
}


// Appendix tables
if $tables_appendix == 1 {
	include "${script_path}/Table_B01_pscore.do"
	include "${script_path}/Table_C02_strict.do"
	include "${script_path}/Table_C03_7yr.do"
	include "${script_path}/Table_C04_portsize.do"
	include "${script_path}/Table_C05_ppml.do"
	include "${script_path}/Table_C06_cluster.do"
	include "${script_path}/Table_C07_treated_rw.do"
	include "${script_path}/Table_C08_sipw.do"
	include "${script_path}/Table_C09_cem.do"
	include "${script_path}/Table_C10_aipw.do"
	include "${script_path}/Table_C11_ipwra.do"
	include "${script_path}/Table_C12_techXyr.do"
	include "${script_path}/Table_C13_grant_lag.do"
	include "${script_path}/Table_C14_funding.do"
	include "${script_path}/Table_C15_samplesel.do"
	include "${script_path}/Table_C16_rob_samplesel.do"
}


// Appendix figures
if $figures_appendix == 1 {
	include "${script_path}/Figure_B01+B02_balance.do"
	include "${script_path}/Figure_C01+C02_cem.do"
	include "${script_path}/Figure_C03_falsification.do"
	include "${script_path}/Figure_C04_confound.do"
}


// Housekeeping (clear temp folder)
*=============================================================================*
if $housekeep == 1 {
	local temp: dir "${temp_path}" files "*"
	dis `temp'

	foreach file of local temp {
		cap erase "${temp_path}/`file'"
	}
}


// End log
*=============================================================================*
di "End date and time: $S_DATE $S_TIME"
log close
