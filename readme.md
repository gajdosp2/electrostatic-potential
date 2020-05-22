# Instructions for script electrostatic_potential.sh

## Compile DelPhi (for Linux simple single thread)

1. download DelPhi from http://compbio.clemson.edu/delphi
2. check if you are using:
  - C++ compiler such as GCC 5.4.0 and above
  - boost library installed in /usr/include and its path is recognized in the user environment
3. tar -xf Delphicpp_v8.2_Linux.tar
4. cd Delphicpp_v8.2_Linux
5. cd Release
6. make all
7. delphicpp_release is compiled executable file
8. set relative path to delphicpp_release file in DELPHI varianble in electrostatic_potential.sh

For more information use delphi compilation manual (v8.2): http://compbio.clemson.edu/downloadDir/delphi/delphi_compilation_man_for_v8.2.pdf

## Compile APBS and PDB2PQR
1. download APBS and PDB2PQR from SourceForge:
  - APBS: https://sourceforge.net/projects/apbs/
  - PDB2PQR: https://sourceforge.net/projects/pdb2pqr/
2. set relative path to PDB2PQR in PDB2PQR variable in electorstatic_potential.sh
3. set relative path to APBS in APBS variable in electrostatic_potential.sh

For more information use APBS and PDB2PQR documentation: http://server.poissonboltzmann.org/documentation

## Usage
~~~
./electorstatic_potential.sh
-l | --library => choose library to use
-f | --file => path to the .pdb file
-ff | --forcefield => forcefield to use for computing electrostatic potential
-o | --output => path to the output folder

~~~
#### available libraries
- delphi
- apbs

#### available forcefields:
- for delphi are availabale amber, charmm, parse and opls
- for apbs are available amber, charmm, parse, tyl06, peoepb and swanson

#### default values
- the default library is set to delphi and default forcefield is set to amber
