#!/bin/bash


DELPHI="../Delphicpp_v8.4.3_Linux/Release"
APBS="../apbs-pdb2pqr/apbs/build/bin"
#PDB2PQR="../apbs-pdb2pqr/pdb2pqr"
PDB2PQR="../pdb2pqr-linux-bin64-2.1.0"

FILE="../dna_datasets/eval/1lfu.pdb"
OUTPUT="results"
LIBRARY="delphi"
FORCEFIELD="amber"

ARGUMENTS=()

valid_file() {
  if [ ! -f "$1" ]
  then
    echo "file: "$1" does not exist"
    exit
  fi
}
valid_output() {
  if [ ! -d "$1" ]
  then
    echo "outpus is not folder"
    exit
  fi
}
valid_library() {
  case "$1" in
    "delphi" | "apbs" )
      return 0
    ;;
    *)
      return 1
    ;;
  esac
}
valid_delphi_forcefield() {
  case "$1" in
    "amber" | "charmm" | "parse" | "opls" )
      return 0
    ;;
    *)
      return 1
    ;;
  esac
}
valid_apbs_forcefield() {
  case "$1" in
    "amber" | "charmm" | "parse" | "tyl06" | "peoepb" | "swanson" )
      return 0
    ;;
    *)
      return 1
    ;;
  esac
}

run_delphi() {
  echo "$1"
  echo "$2"
  echo "$3"

  FILENAME=$(basename "$2")
  PRMFILE="tmp/${FILENAME%.*}/delphi-${FILENAME%.*}.prm"
  CUBEFILE="$3/${FILENAME%.*}/delphi-${FILENAME%.*}.cube"
  LOGFILE="$3/${FILENAME%.*}/delphi-${FILENAME%.*}.log"


  if [ ! -d "tmp/${FILENAME%.*}/" ]
  then
    mkdir "tmp/${FILENAME%.*}/"
  fi



  if [ ! -d "$3/${FILENAME%.*}/" ]
  then
    mkdir "$3/${FILENAME%.*}/"
  fi

  touch "$PRMFILE"
  echo > "$PRMFILE"
  touch $LOGFILE
  echo > $LOGFILE
  touch $CUBEFILE
  echo > $CUBEFILE

  echo "scale=2.0" >> $PRMFILE
  echo "perfil=70.0" >> $PRMFILE
  echo 'in(pdb,file="'$2'")' >> $PRMFILE
  echo 'in(siz,file="./delphi_parameters/'$1'.siz")' >> $PRMFILE
  echo 'in(crg,file="./delphi_parameters/'$1'.crg")' >> $PRMFILE
  echo 'indi=2.0' >> $PRMFILE
  echo 'exdi=80.0' >> $PRMFILE
  echo 'prbrad=1.4' >> $PRMFILE
  echo 'salt=0.00' >> $PRMFILE
  echo 'bndcon=2' >> $PRMFILE
  echo 'maxc=0.0001' >> $PRMFILE
  echo 'linit=800' >> $PRMFILE
  echo 'out(phi,file="'$CUBEFILE'", format=cube)' >> $PRMFILE
  echo 'energy(s,c,g)' >> $PRMFILE

  $DELPHI"/delphicpp_release" $PRMFILE >> $LOGFILE 2>&1

}
run_apbs() {
  echo "$1"
  echo "$2"
  echo "$3"

  FILENAME=$(basename "$2")
  LOGFILE="$3/${FILENAME%.*}/apbs-${FILENAME%.*}.log"
  CUBEFILE="$3/${FILENAME%.*}/apbs-${FILENAME%.*}.cube"
  #run pdb2pqr
  if [ ! -d "tmp/${FILENAME%.*}/" ]
  then
    mkdir "tmp/${FILENAME%.*}/"
  fi
  #$(python3 $PDB2PQR"/pdb2pqr.py" --ff=$1 $2 "tmp/${FILENAME%.*}/${FILENAME%.*}" --apbs-input)
  $PDB2PQR"/pdb2pqr" --ff=$1 $2 "tmp/${FILENAME%.*}/${FILENAME%.*}" --apbs-input
  echo "pdb2pqr created apbs input file"


  path=$(echo $PWD)
  INPUTFILE=$path"/tmp/${FILENAME%.*}/${FILENAME%.*}.in"
  sed -i "s/mol pqr /mol pqr tmp\/${FILENAME%.*}\//" $INPUTFILE
  #python dx2cube.py

  #INPUTFILE="/home/petra/Desktop/p2rank_dna/electrostatic_potential/tmp/1lfu/1lfu.in"

  $APBS"/apbs" $INPUTFILE

  if [ ! -d "$3/${FILENAME%.*}/" ]
  then
    mkdir "$3/${FILENAME%.*}/"
  fi

  DX2CUBE=$APBS"/../../../pdb2pqr/tools"

  python3 $DX2CUBE"/dx2cube.py" "tmp/${FILENAME%.*}/${FILENAME%.*}.dx" "tmp/${FILENAME%.*}/${FILENAME%.*}" $CUBEFILE



}

while [[ $# -gt 0 ]]
do
  ARG="$1"

  case $ARG in
    -f | --file )
    FILE="$2"
    shift
    shift
    ;;
    -o | --output )
    OUTPUT="$2"
    shift
    shift
    ;;
    -l | --library )
    LIBRARY="$2"
    shift
    shift
    ;;
    -ff | --forcefield )
    FORCEFIELD="$2"
    shift
    shift
    ;;
    *)
    ARGUMENTS+=("$1")
    shift
    ;;
  esac

done

valid_file "$FILE"
valid_output "$OUTPUT"

if ! valid_library "$LIBRARY"
then
  echo "the library does not exist"
fi

case "$LIBRARY" in
  "delphi" )
    if ! valid_delphi_forcefield $FORCEFIELD
    then
      echo "the forcefield does not exist"
      exit
    fi

    run_delphi $FORCEFIELD $FILE $OUTPUT
  ;;
  "apbs" )
    if ! valid_apbs_forcefield $FORCEFIELD
    then
      echo "the forcefield does not exist"
      exit
    fi

    run_apbs $FORCEFIELD $FILE $OUTPUT
  ;;
esac
