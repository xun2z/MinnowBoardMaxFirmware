mkdir Firmware
cd Firmware

# make sure you have nasm, uuid-devel, libuuid-devel, acpica-tools

# pull all the needed files from GIT
git clone https://github.com/tianocore/edk2.git -b UDK2017
cd edk2
git checkout vUDK2017
cd ..

git clone https://github.com/tianocore/edk2-platforms.git -b devel-MinnowBoardMax-UDK2017
cd edk2-platforms/
git checkout 2a5f80b862e46de213a3f3635c43394deacdfb05
cd ..

git clone https://github.com/tianocore/edk2-BaseTools-win32.git
cd edk2-BaseTools-win32/
git checkout 0e088c19ab31fccd1d2f55d9e4fe0314b57c0097
cd ..
mv edk2-BaseTools-win32 edk2/BaseTools/Bin

cd edk2-platforms

# copy AudioSsdtUpdate application
#cp -r ../../AudioSsdtUpdate Vlv2TbltDevicePkg/Application/AudioSsdtUpdate
# Symlink to code
cd Vlv2TbltDevicePkg/Application
ln -s  ../../../../AudioSsdtUpdate/ AudioSsdtUpdate
cd ../../../
mkdir silicon

# get binary objects
curl -k -O https://firmware.intel.com/sites/default/files/minnowboard_max-1.00-binary.objects.zip
unzip minnowboard_max-1.00-binary.objects.zip
mv MinnowBoard_MAX-1.00-Binary.Objects/* silicon # move all objects to current directory

# get OpenSSL, patch it and compile it in workspace
cd edk2/CryptoPkg/Library/OpensslLib
git clone -b OpenSSL_1_1_0e https://github.com/openssl/openssl openssl
cd ../../../../

# make required scripts executable
chmod +x edk2/edksetup.sh
chmod -R 777 edk2/BaseTools/
chmod +x edk2-platforms/Vlv2TbltDevicePkg/bld_vlv.sh edk2-platforms/Vlv2TbltDevicePkg/Build_IFWI.sh edk2-platforms/Vlv2TbltDevicePkg/GenBiosId

# last step before compilation, fix GCC issues and add AudioSsdtUpdate
cd edk2-platforms
patch -p1 < ../../MinnowFirmware.patch

echo "MinnowFirmware now setup"
cd ../..
