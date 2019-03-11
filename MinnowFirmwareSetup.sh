mkdir Firmware
cd Firmware

# make sure you have nasm, uuid-devel, libuuid-devel, acpica-tools
# also make sure you use gcc-4.x and g++-4.x, gcc-4.8 is recommeded
sudo apt install nasm uuid-dev acpica-tools gcc-4.8 g++-4.8

# pull all the needed files from GIT
git clone https://github.com/tianocore/edk2-platforms.git
cd edk2-platforms/
git checkout 74a5c7c849543cd98424bb299ab82e1d131c75bb
cd ..

git clone https://github.com/tianocore/edk2-BaseTools-win32.git
cd edk2-BaseTools-win32/
git checkout ea691aec89b06aa83474100df1de000a875b4ea0 
cd ..
mv edk2-BaseTools-win32 edk2-platforms/BaseTools/Bin

cd edk2-platforms

# copy AudioSsdtUpdate application
#cp -r ../../AudioSsdtUpdate Vlv2TbltDevicePkg/Application/AudioSsdtUpdate
# Symlink to code
cd Vlv2TbltDevicePkg/Application
ln -s  ../../../../AudioSsdtUpdate/ AudioSsdtUpdate
cd ../../

# get binary objects
curl -k -O https://firmware.intel.com/sites/default/files/MinnowBoard_MAX-0.95-Binary.Objects.zip
unzip MinnowBoard_MAX-0.95-Binary.Objects.zip
mv MinnowBoard_MAX-0.95-Binary.Objects/* . # move all objects to current directory

# get OpenSSL, patch it and compile it in workspace
curl -O https://www.openssl.org/source/openssl-1.0.2d.tar.gz
cd CryptoPkg/Library/OpensslLib
tar xf ../../../openssl-1.0.2d.tar.gz
cd openssl-1.0.2d
patch -p0 -i ../EDKII_openssl-1.0.2d.patch
cd ..
./Install.sh
cd ../../../

# make required scripts executable
chmod +x ./edksetup.sh ./Vlv2TbltDevicePkg/bld_vlv.sh ./Vlv2TbltDevicePkg/Build_IFWI.sh ./Vlv2TbltDevicePkg/GenBiosId

# last step before compilation, fix GCC issues and add AudioSsdtUpdate
patch -p1 < ../../MinnowFirmware.patch

echo "MinnowFirmware now setup"
cd ../..
