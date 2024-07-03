#!/bin/bash

### Datos de la Dinamica Molecular ###

replicas=5

residuos=1-100

topologia=archivo.parm7

coordenadas=archivo.rst7

nanosegundos=100

######

# Creacion de archivos y directorios
mkdir -p 01-min 02-eq

echo '&cntrl
imin=1, maxcyc=3000, 
ntpr=10,
ntr=1, restraint_wt=5.00, restraintmask=":'$residuos' & !@H=",
/' > 01-min/min.in

echo '&cntrl
imin=1, maxcyc=500, ntmin=3, 
ntpr=10,
ntr=1, restraint_wt=5.00, restraintmask=":'$residuos' & !@H=",
/' > 01-min/min1.in

echo '&cntrl
timlim=999999, imin=0,
ntx=1, iwrap=0,
ntxo=1, ntpr=500, ntwx=2500, ntwv=0, ntwe=0, ioutfm=1,
ntp=0, ntc=2,
ntb=1, ntf=2, cut=9.0,
ntt=3, temp0=150.0, tempi=100.0, ig=-1, gamma_ln=4.0,
nstlim= 50000, dt=0.004,
ntr=1, restraint_wt=5.00, restraintmask=":'$residuos' & !@H=",
&end' > 02-eq/eq1.in

echo '&cntrl
timlim=999999, imin=0,
ntx=5, irest=1, iwrap=0,
ntxo=1, ntpr=500, ntwx=2500, ntwv=0, ntwe=0, ioutfm=1,
ntp=0, ntc=2,
ntb=1, ntf=2, cut=9.0, 
ntt=3, temp0=200.0, ig=-1,  gamma_ln=4.0,
nstlim= 50000, dt=0.004,
ntr=1, restraint_wt=4.00, restraintmask=":'$residuos' & !@H=",
&end' > 02-eq/eq2.in

echo '&cntrl
timlim=999999, imin=0,
ntx=5, irest=1, iwrap=0,
ntxo=1, ntpr=500, ntwx=2500, ntwv=0, ntwe=0, ioutfm=1,
ntp=0, ntc=2,
ntb=1, ntf=2, cut=9.0, 
ntt=3, temp0=250.0, ig=-1,  gamma_ln=4.0,
nstlim= 50000, dt=0.004,
ntr=1, restraint_wt=3.00, restraintmask=":'$residuos' & !@H=",
&end' > 02-eq/eq3.in 

echo '&cntrl
timlim=999999, imin=0,
ntx=5, irest=1, iwrap=0,
ntxo=1, ntpr=500, ntwx=2500, ntwv=0, ntwe=0, ioutfm=1,
ntp=0, ntc=2,
ntb=1, ntf=2, cut=9.0, 
ntt=3, temp0=300.0, ig=-1,  gamma_ln=4.0,
nstlim= 50000, dt=0.004,
ntr=1, restraint_wt=1.00, restraintmask=":'$residuos' & !@H=",
&end' > 02-eq/eq4.in

echo '&cntrl
timlim=999999, imin=0,
ntx=5, irest=1, iwrap=0, ntc=2, 
ntxo=1, ntpr=500, ntwx=2500, ntwv=0, ntwe=0, ioutfm=1,
ntp=1, taup=2.0, pres0=1.0,
ntb=2, ntf=2, cut=9.0, barostat = 2
ntt=3, temp0=300.0, ig=-1,  gamma_ln=4.0,
nstlim=250000, dt=0.004,
&end' > 02-eq/eq5.in

# Itera desde 1 hasta el número de replicas
for i in $(seq 1 $replicas); do
   mkdir -p "03-md$i"
   echo '&cntrl
timlim=999999, imin=0,
ntx=5, irest=1, iwrap=1, ntc=2, 
ntxo=1, ntpr=2500, ntwx=2500, ntwv=0, ntwe=0, ioutfm=1,
ntp=1, taup=2.0, pres0=1.0,
ntb=2, ntf=2, cut=9.0, barostat = 2
ntt=3, temp0=300.0, ig=-1,  gamma_ln=4.0,
nstlim=250000, dt=0.004,

&end' > "03-md$i/md.in"
   echo '#!/bin/bash

cnt=1
cntmax='$nanosegundos'

while [ $cnt -le $cntmax ]; do
	if [ $cnt -eq 1 ]; then
		pmemd.cuda -O -i md.in -o md${cnt}.out -p ../'$topologia' -c ../eq/eq5.rst7 -r md${cnt}.rst7 -x md${cnt}.nc
	else
		pcnt=$((cnt - 1))
		pmemd.cuda -O -i md.in -o md${cnt}.out -p ../'$topologia' -c md${pcnt}.rst7 -r md${cnt}.rst7 -x md${cnt}.nc
	fi
	cnt=$((cnt + 1))
done' > "03-md$1/run_MD.sh"

done





echo 'replicas='$replicas'
residuos='$residuos'
topologia='$topologia'
coordenadas='$coordenadas'
' > .variables
