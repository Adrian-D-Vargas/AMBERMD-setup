
#!/bin/bash

# Función para generar el contenido de las cadenas
generar_contenido_cadenas() {
    local contenido=""
    local inicio_residuo=1

    for (( i=1; i<=num_cadenas; i++ )); do
        fin_residuo=$(( inicio_residuo + longitudes[i-1] - 1 ))
        contenido+="    center :${inicio_residuo}-${fin_residuo} mass origin\n"
        contenido+="image origin center byres familiar\n"
        inicio_residuo=$(( fin_residuo + 1 ))
    done

    echo "$contenido"
}

# Definir el número de cadenas y las longitudes de residuos
num_cadenas=15
longitudes=(107 425 489 488 491 302 163 67 168 167 166 107 106 426 425)

# Generar el contenido de las cadenas
contenido_cadenas=$(generar_contenido_cadenas)

# Definir las variables necesarias
source .variables
mask="'${residuos}' & !@H="  # Asegúrate de que las comillas simples estén correctamente colocadas

rst=$1
exeptraj=cpptraj

# Modify output names according to the version of ptraj used (ptraj/cpptraj)
if [ "$exeptraj" == 'ptraj' ]; then ext=".1"; else ext=""; fi

# write PDB of atoms in mask (reference structure)
$exeptraj ../$topologia << EOF 
trajin ../$coordenadas
strip '@H*'
strip '!(:${mask})'
trajout tmp0.pdb pdb nobox
EOF

# calculate Center Of Mass
com1=$(grep ^ATOM tmp0.pdb$ext | perl -e 'while(<>){$x+=substr($_,30,8);$y+=substr($_,38,8);$z+=substr($_,46,8);$n++};printf "%.3f %.3f %.3f\n",$x/$n,$y/$n,$z/$n;')

# write PDB of atoms in mask (current restart file)
$exeptraj ../$topologia << EOF 
trajin $rst
strip '@H*'
strip '!(:${mask})'
trajout tmp.pdb pdb nobox
EOF

# calculate Center Of Mass
com2=$(grep ^ATOM tmp.pdb$ext | perl -e 'while(<>){$x+=substr($_,30,8);$y+=substr($_,38,8);$z+=substr($_,46,8);$n++};printf "%.3f %.3f %.3f\n",$x/$n,$y/$n,$z/$n;')

# calculate Distance
d=$(echo "$com1 $com2" | awk '{printf "%i", sqrt(($1-$4)^2 + ($2-$5)^2 + ($3-$6)^2)}')
rm tmp0.pdb$ext tmp.pdb$ext

# Translate if necessary
if [ "$d" -gt "5" ]; then
    xyz=$(echo "$com1" | awk '{printf "x %.7f y %.7f z %.7f",$1, $2, $3}')
    
    # Insertar el contenido generado de las cadenas
    $exeptraj ../$topologia << EOF 
    trajin $rst
$contenido_cadenas
    center ':${mask}' origin
    translate :* $xyz
    trajout ${rst%.rst}_translated.rst restart
EOF

    mv $rst ${rst%}_save

    # Take coordinates (+2 header lines) from new file (ptraj does not preserve velocity information)
    n1=$(wc -l ${rst%.rst}_translated.rst$ext | awk '{printf "%i",3+(($1-3)/2)}')
    sed ''$n1',$d' ${rst%.rst}_translated.rst$ext > $rst

    # Take velocities (+x box info) from old file
    n2=$(wc -l ${rst%}_save | awk '{printf "%i",2+(($1-3)/2)}')
    sed '1,'$n2'd' ${rst}_save >> $rst
fi

