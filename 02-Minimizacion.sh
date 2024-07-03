#!/bin/bash

source .variables

cd min

mpirun -np 14 --use-hwthread-cpus sander.MPI -O -i min1.in -o min1.out -p ../$topologia -c ../$coordenadas -r min1.rst7 -ref ../$coordenadas
mpirun -np 14 --use-hwthread-cpus pmemd.MPI -O -i min.in -o min.out -p ../$topologia -c min1.rst7 -r min.rst7 -ref min1.rst7
