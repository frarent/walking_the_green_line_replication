*=============================================================================*
* AUX_01_fe_macros.do
* Fixed effects macro definitions for the Walking the Green Line project
* Called by: scripts/00_master.do
*=============================================================================*

* 3-digit CPC dummies — full sample estimates
global cpc_3d d3_A01 d3_A21 d3_A22 d3_A23 d3_A24 d3_A41 d3_A42 d3_A43 d3_A44 ///
	d3_A45 d3_A46 d3_A47 d3_A61 d3_A62 d3_A63 d3_B01 d3_B02 d3_B03 d3_B04 ///
	d3_B05 d3_B06 d3_B07 d3_B08 d3_B09 d3_B21 d3_B22 d3_B23 d3_B24 d3_B25 ///
	d3_B26 d3_B27 d3_B28 d3_B29 d3_B30 d3_B31 d3_B32 d3_B33 d3_B41 d3_B42 ///
	d3_B43 d3_B44 d3_B60 d3_B61 d3_B62 d3_B63 d3_B64 d3_B65 d3_B66 d3_B67 ///
	d3_B68 d3_B81 d3_B82 d3_C01 d3_C02 d3_C03 d3_C04 d3_C05 d3_C06 d3_C07 ///
	d3_C08 d3_C09 d3_C10 d3_C11 d3_C12 d3_C13 d3_C14 d3_C21 d3_C22 d3_C23 ///
	d3_C25 d3_C30 d3_C40 d3_D01 d3_D02 d3_D03 d3_D04 d3_D05 d3_D06 d3_D07 ///
	d3_D10 d3_D21 d3_E01 d3_E02 d3_E03 d3_E04 d3_E05 d3_E06 d3_E21 d3_F01 ///
	d3_F02 d3_F03 d3_F04 d3_F05 d3_F15 d3_F16 d3_F17 d3_F21 d3_F22 d3_F23 ///
	d3_F24 d3_F25 d3_F26 d3_F27 d3_F28 d3_F41 d3_F42 d3_G01 d3_G02 d3_G03 ///
	d3_G04 d3_G05 d3_G06 d3_G07 d3_G08 d3_G09 d3_G10 d3_G11 d3_G12 d3_G16 ///
	d3_G21 d3_H01 d3_H02 d3_H03 d3_H04 d3_H05  d3_Y10

* 4-digit CPC dummies — clean-tech sample estimates
global cpc_4d_green d_ei_4dig_Y02A d_ei_4dig_Y02B d_ei_4dig_Y02C ///
	d_ei_4dig_Y02D d_ei_4dig_Y02E d_ei_4dig_Y02P d_ei_4dig_Y02T ///
	d_ei_4dig_Y02W d_ei_4dig_Y04S

* Technology-by-year fixed effects — clean-tech sample
global techXyear i.filing_year2#i.d_ei_4dig_Y02A ///
	i.filing_year2#i.d_ei_4dig_Y02B i.filing_year2#i.d_ei_4dig_Y02C ///
	i.filing_year2#i.d_ei_4dig_Y02D i.filing_year2#i.d_ei_4dig_Y02E ///
	i.filing_year2#i.d_ei_4dig_Y02P i.filing_year2#i.d_ei_4dig_Y02T ///
	i.filing_year2#i.d_ei_4dig_Y02W i.filing_year2#i.d_ei_4dig_Y04S
