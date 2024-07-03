#!/bin/bash

sourse .variables

cd eq
pmemd.cuda -O -i eq1.in -o eq1.out -p ../$topologia -c ../min/min.rst7 -r eq1.rst7 -x eq1.nc -ref ../min/min.rst7
sh check_com.sh eq1.rst7 &> eq1.image.log
pmemd.cuda -O -i eq2.in -o eq2.out -p ../$topologia -c eq1.rst7 -r eq2.rst7 -x eq2.nc -ref eq1.rst7
sh check_com.sh eq2.rst7 &> eq2.image.log
pmemd.cuda -O -i eq3.in -o eq3.out -p ../$topologia -c eq2.rst7 -r eq3.rst7 -x eq3.nc -ref eq2.rst7
sh check_com.sh eq3.rst7 &> eq3.image.log
pmemd.cuda -O -i eq4.in -o eq4.out -p ../$topologia -c eq3.rst7 -r eq4.rst7 -x eq4.nc -ref eq3.rst7
sh check_com.sh eq4.rst7 &> eq4.image.log
pmemd.cuda -O -i eq5.in -o eq5.out -p ../$topologia -c eq4.rst7 -r eq5.rst7 -x eq5.nc -ref eq4.rst7
sh check_com.sh eq5.rst7 &> eq5.image.log
