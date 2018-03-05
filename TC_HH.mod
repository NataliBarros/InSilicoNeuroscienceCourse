TITLE Hippocampal HH channels
: EI, from ModelDB, accession no. 279
:
: Fast Na+ and K+ currents responsible for action potentials
: Iterative equations
:
: Equations modified by Traub, for Hippocampal Pyramidal cells, in:
: Traub & Miles, Neuronal Networks of the Hippocampus, Cambridge, 1991
:
: range variable vtraub adjust threshold
:
: Written by Alain Destexhe, Salk Institute, Aug 1992
:

INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms)}

NEURON {
	SUFFIX TC_HH
	USEION na READ ena WRITE ina
	USEION k READ ek WRITE ik
	RANGE gna_max, gk_max, vtraub, i_rec
	RANGE m_inf, h_inf, n_inf
	RANGE tau_m, tau_h, tau_n
	RANGE m_exp, h_exp, n_exp
}


UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
	(S)  = (siemens)
}

PARAMETER {
	gna_max	= 1.0e-1 	(S/cm2)  : Destexhe et al., 1998; 1.0e-2 Amarillo et al., 2014
	gk_max	= 1.0e-1 	(S/cm2)  :       "		; 2.0e-3 Amarillo et al., 2014

 	ena	= 45	(mV)		 :	 Amarillo et al., 2014
	ek	= -99	(mV)             :       Amarillo et al., 2014
	celsius         (degC)
	dt              (ms)
	v               (mV)
	vtraub	= -63	(mV)
}

STATE {
	m h n
}

ASSIGNED {
	ina	(mA/cm2)
	ik	(mA/cm2)
	i_rec	(mA/cm2)
	m_inf
	h_inf
	n_inf
	tau_m
	tau_h
	tau_n
	m_exp
	h_exp
	n_exp
	tcorr
}


BREAKPOINT {
	SOLVE states METHOD cnexp
	ina   = gna_max * m*m*m*h * (v - ena)
	ik    = gk_max * n*n*n*n * (v - ek)
	i_rec = ina + ik
}


DERIVATIVE states {   : exact Hodgkin-Huxley equations, EI: should work with CVODE
	evaluate_fct(v)
	m' = (m_inf - m) / tau_m
	h' = (h_inf - h) / tau_h
	n' = (n_inf - n) / tau_n
}

:PROCEDURE states() {	: exact when v held constant
:	evaluate_fct(v)
:	m = m + m_exp * (m_inf - m)
:	h = h + h_exp * (h_inf - h)
:	n = n + n_exp * (n_inf - n)
:	VERBATIM
:	return 0;
:	ENDVERBATIM
:}

UNITSOFF
INITIAL {
	m = 0
	h = 0
	n = 0
:
:  Q10 was assumed to be 3 for both currents
:
: original measurements at roomtemperature?

	tcorr = 3.0 ^ ((celsius-36)/ 10 )
}

PROCEDURE evaluate_fct(v(mV)) { LOCAL a,b,v2

	v2 = v - vtraub : convert to traub convention

	a = 0.32 * (13-v2) / ( exp((13-v2)/4) - 1)
	b = 0.28 * (v2-40) / ( exp((v2-40)/5) - 1)
	tau_m = 1 / (a + b) / tcorr
	m_inf = a / (a + b)

	a = 0.128 * exp((17-v2)/18)
	b = 4 / ( 1 + exp((40-v2)/5) )
	tau_h = 1 / (a + b) / tcorr
	h_inf = a / (a + b)

	a = 0.032 * (15-v2) / ( exp((15-v2)/5) - 1)
	b = 0.5 * exp((10-v2)/40)
	tau_n = 1 / (a + b) / tcorr
	n_inf = a / (a + b)

	m_exp = 1 - exp(-dt/tau_m)
	h_exp = 1 - exp(-dt/tau_h)
	n_exp = 1 - exp(-dt/tau_n)
}

UNITSON






