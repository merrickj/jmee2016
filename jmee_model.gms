$TITLE jmee_model

* James Merrick, Stanford University
* GAMS code for numeric model described in paper submitted to Energy Economics
* June 2015 & tidied April 2016

* Further tidying for committing to Github, August 2021

* Model built upon:
* Master's Thesis of James Merrick, TPP/Course 6, Massachusetts Institute of Technology, 2010
* in turn built upon GAMS code originally developed by Andres Ramos,  Universidad Pontificia Comillas


Option iterlim = 10000000 ;
Option reslim = 80000 ;

$if not set carbontax $set carbontax 0

$set slash /
$if set windows $set slash \

SETS
   p     periods
   tr    generators /
$include "datafiles%slash%tr_jmee.txt"
                    /
   trw(tr) subset of generators (wind)  / wind-60*wind-62  /
   trs(tr) subset of generators (solar)   /solar-60*solar-65,solar-67/
   trr(tr) subset of generators (renewables)   /
                                               solar-61*solar-65,
					       solar-67,
					       wind-60*wind-62  /
   atg   Generator attributes
        / pmx, cvr, cfj,fc, tcf,  co2 /
;

ALIAS (p,pp)

SCALARS
   carbontax/%carbontax%/
   incdem         demand scaling factor
   inc            increment in demand  / 0.486/
*ERCOT load growth 1.2% per year for 20 year horizon -> 1.02**20 = 1.486
;
incdem =  1+inc ;

PARAMETERS
   dem(p)                         system-wide demand in each period
   w(p)                           weight of each hour
   windfactor(p,trw)              wind availability in each period
   solarinsolationfactor(p,trs)   solar availability in each period
   pf(p,tr)                       generator availability in each period
;

* Load in temporal data
$if not set segmode $set segmode 8760
$gdxin "datafiles%slash%temporal_%segmode%.gdx"
$load p,dem,windfactor,solarinsolationfactor,w=dur

* Populate pf
pf(p,tr) = 1;
pf(p,trw) = windfactor(p,trw);
pf(p,trs) = solarinsolationfactor(p,trs)/1000;

* Load up generator data
$include "datafiles%slash%dtgt_jmee.txt"

* Factor to annualise capital cost
dtgt(tr,'tcf') = 0.1;

*Convert to mega dollars
dtgt(tr,'cvr') = dtgt(tr,'cvr')/1e6;
dtgt(tr,'FC')  = dtgt(tr,'FC')/1e6;
dtgt(tr,'cfj') = dtgt(tr,'CFJ')/1e6;
carbontax = carbontax / 1e6;


* Set capital cost adjustments for solar
* scale=20, 0.5$/W PV case
* scale=40,  1$/W PV case
scalar scale/20/;
$if set instance scale=%instance%;
dtgt(trs,'FC')=dtgt(trs,'FC')*(scale/100);
dtgt(trs,'cfj')=dtgt(trs,'CFJ')*(scale/100);


* Convert from MW to GW
dtgt(tr,'pmx')     = dtgt(tr,'pmx')     / 1e3 ;
dem(p)             = dem(p)             / 1e3 ;


VARIABLES
   G(p,tr)        Generation (GW)
   I(tr)          Capacity investment (GW)
   Z              Value of objective function (mega dollars)
   CO2var         CO2 Emissions
;

POSITIVE VARIABLES  G, I, co2var;

EQUATIONS
   FO              objective function
   KR1(p)          supply demand constraint
   PRDTRM(p,tr)    generation must be less than available capacity
   carbontrack     Constraint to keep track of carbon
;


FO .. Z =E=
      SUM((tr),    I(tr)    * dtgt(tr,'cfj')*dtgt(tr,'tcf') )
      +      SUM((tr),    ((I(tr)+dtgt(TR,'PMX'))    * dtgt(tr,'FC')))
      +      SUM((p,tr),    dtgt(tr,'cvr') * G(p,tr)    * w(p))
      +      (co2var*carbontax)
;

KR1(p) ..
   SUM(tr, G(p,tr))
   =e=
   dem(p)*incdem
 ;

PRDTRM(p,tr) ..
   G(p,tr) =l= (dtgt(tr,'pmx') + I(tr)) * PF(p,tr);

carbontrack ..
    CO2VAR =e= sum((p,tr),(dtgt(tr,'CO2')*G(p,tr)*w(p)));


MODEL PLGNRD   /
      FO,
      KR1,
      PRDTRM,
      carbontrack
      /;


$ifthen.simple set simple
G.UP(p,"wind-62") = 0;
G.UP(p,"wind-60") = 0;
G.UP(p,trs)$(not sameas(trs,"solar-61")) = 0;
$endif.simple


plgnrd.dictfile=0;
option solvelink=0      ;
plgnrd.optfile=1;
option optcr=0.0001;


SOLVE PLGNRD USING LP MINIMIZING Z ;


* Reporting parameters
Parameters
    Generation_Tech(tr) 
    SUMGeneration 
    Generation_PCNT(tr) 
    TotalCO2
    gen(p,tr)
    cap(tr)
    co2
    existcap(tr)
    Marginal_Cost(p)
    nodalgen(p)
    carboncost;

Generation_Tech(tr) = SUM(p, G.l(p,tr) * w(p));
sumgeneration = SUM((p,tr), G.l(p,tr) * w(p));
Generation_PCNT(tr) = (Generation_tech(tr) / sumgeneration)*100;
TotalCO2 = sum((p,tr), (dtgt(tr,'CO2') * G.l(p,tr)));
gen(p,tr) = G.l(p,tr);
existcap(tr) = dtgt(tr,'pmx');
cap(tr) = I.l(tr);
co2 = CO2var.l;
Marginal_Cost(p) = (KR1.m(p)*1000) / w(p);
carboncost = CO2VAR.l * carbontax;
