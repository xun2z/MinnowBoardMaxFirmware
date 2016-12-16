AudioSsdtUpdate.efi and associated .aml files are avaible as
pre-compiled binaries under X64/

The code for the application and .asl files is under AudioSsdtUpdate.

To add support for a new codec, just copy/paste an existing .asl file
and modify the device name and HID, as well as information related to the
I2C address and GPIO lines for interrupts. The new .asl file needs to
be listed as well in AudioSsdtUpdate.inf to be included and compiled as
a .aml binary.

To regenerate the binaries after code updates or addition of new files:

1. ./MinnowFirmwareSetup.sh to fetch all the required code and patches
(this step is only needed once)
2. ./build.sh tp recompile the EFI applcication and AML files

This script was tested on Fedora 24 with Gcc 6.2.1 using the firmware version 0.93 (instructions at https://firmware.intel.com/projects/minnowboard-max )

Several patches to the default firmware tree were required to compile, see
MinnowFirmware.patch (which also add the AudioSsftUpdate.inf reference
for the compilation)

To use these binaries, place them in the relevant EFI directory on your
platform and run
AudioSsdtUpdate.efi rt56xx.aml (pick the relevant file for your codec)
or add this command in a startup.nsh before booting to grub

To enable the audio DSP on MinnowMax, go to the BIOS menu in
System Setup -> SouthCluster Configuration -> Audio Configuration

'LPE Audio Support' should be changed from Disabled to LPE Audio ACPI mode

'LPE Audio Reported by DSDT' should be changed to disabled (to remove
the default DSDT settings and enable the SSDT override)