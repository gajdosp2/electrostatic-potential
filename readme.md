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

## Use APBS and PDB2PQR

### Set PDB2PQR
1. download PDB2PQR from SourceForge:
  - PDB2PQR: https://sourceforge.net/projects/pdb2pqr/
2. set relative path to PDB2PQR to PDB2PQR variable in electorstatic_potential.sh

### Compile APBS (for Linux)
1. git clone git@github.com:Electrostatics/apbs-pdb2pqr.git
2. check if you are using
  - cmake
  - python3 for file.cube results of apbs
3. cd apbs-pdb2pqr

4. git submodule init
5. git submodule update

6. cd apbs
7. mkdir build
8. cd  build
9. cmake -DENABLE_PYTHON=ON -DCMAKE_C_FLAGS="-fPIC" -DBUILD_SHARED_LIBS=OFF ..
10. cmake --build .
11. set relative path to APBS(apbs-pdb2pqr/apbs/build/bin) to APBS variable in electorstatic_potential.sh

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
