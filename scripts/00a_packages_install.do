//-----------------------------------------------------------------
//EXTERNAL PACKAGES
//-----------------------------------------------------------------

*packages
foreach name in  psmatch2 estout cem imb ///
konfound indeplist moss matsort ftools reghdfe ///
require ivreghdfe ivreg2 ranktest ///
ppmlhdfe distinct ///
csdid drdid {
		cap which `name'
		if _rc==111 {
			ssc install `name'
			}
		else {
			dis in red "`name' package already installed"
			}
	}

*graph scheme pack
foreach name in schemepack {
cap	set scheme white_tableau ,perm
		if _rc==111 {
			ssc install `name'
			cap	set scheme white_tableau ,perm
			}
		else {
			dis in red "`name' package already installed"
			}
	}

