cd Firmware/edk2-platforms/Vlv2TbltDevicePkg/

# remember to link your gcc/g++ back
GCC_BAK=`ls -l /usr/bin/gcc | head -1 | awk -F \  '{print $11}'`
GPP_BAK=`ls -l /usr/bin/g++ | head -1 | awk -F \  '{print $11}'`

sudo ln -sf /usr/bin/gcc-4.8 /usr/bin/gcc
sudo ln -sf /usr/bin/g++-4.8 /usr/bin/g++

echo "START COMPILATION"

./Build_IFWI.sh MNW2 Release
#./Build_IFWI.sh MNW2 Debug
#cp Stitch/*.bin ../../

cp ../Build/Vlv2TbltDevicePkg/RELEASE_GCC48/X64/Vlv2TbltDevicePkg/Application/AudioSsdtUpdate/AudioSsdtUpdate/OUTPUT/*.efi ../../../X64
cp ../Build/Vlv2TbltDevicePkg/RELEASE_GCC48/X64/Vlv2TbltDevicePkg/Application/AudioSsdtUpdate/AudioSsdtUpdate/OUTPUT/*.aml ../../../X64

cd ../../../X64
echo "the images are now under `pwd`"
ls -l *.efi *.aml

# link back
sudo ln -sf $GCC_BAK /usr/bin/gcc
sudo ln -sf $GPP_BAK /usr/bin/g++
