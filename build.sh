cd Firmware/edk2-platforms/Vlv2TbltDevicePkg/

echo "START COMPILATION"

./Build_IFWI.sh MNW2 Release
#./Build_IFWI.sh MNW2 Debug
#cp Stitch/*.bin ../../

cp ../Build/Vlv2TbltDevicePkg/RELEASE_GCC48/X64/Vlv2TbltDevicePkg/Application/AudioSsdtUpdate/AudioSsdtUpdate/OUTPUT/*.efi ../../../X64
cp ../Build/Vlv2TbltDevicePkg/RELEASE_GCC48/X64/Vlv2TbltDevicePkg/Application/AudioSsdtUpdate/AudioSsdtUpdate/OUTPUT/*.aml ../../../X64

cd ../../../X64
echo "the images are now under `pwd`"
ls -l *.efi *.aml
