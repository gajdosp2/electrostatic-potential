#!/bin/bash


DELPHI="../Delphicpp_v8.4.3_Linux/Release"
APBS="../APBS/bin"
PDB2PQR="../pdb2pqr/"

FILE="/home/petra/Desktop/p2rank_dna/dna_datasets/eval/1LFU.pdb"
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
  PRMFILE="tmp/${FILENAME%.*}.prm"
  CUBEFILE="$3/${FILENAME%.*}/${FILENAME%.*}.cube"
  LOGFILE="$3/${FILENAME%.*}/${FILENAME%.*}.log"

  if [ ! -d "$3/${FILENAME%.*}/" ]
  then
    mkdir "$3/${FILENAME%.*}/"
  fi

  touch $PRMFILE
  echo > $PRMFILE
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
    if ! valid_apbs_forcefield
    then
      echo "the forcefield does not exist"
      exit
    fi
  ;;
esac
