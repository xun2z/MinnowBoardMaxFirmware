/** @file
  The definition block in ACPI table for RT5682 device under I2C6 Controller

Copyright (c) 2015, Intel Corporation. All rights reserved.<BR>
  This program and the accompanying materials 
  are licensed and made available under the terms and conditions of the BSD License 
  which accompanies this distribution.  The full text of the license may be found at 
  http://opensource.org/licenses/bsd-license.php

  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS, 
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
**/

DefinitionBlock (
  "RT5682.aml",
  "SSDT",
   2,
  "INTEL ",
  "5682Tabl",
  0x1000
  )
{
  External(LPE0)
  External(LPE1)
  External(LPE2)
  External(\_SB.I2C6, DeviceObj)

  Scope (\_SB.I2C6) {
            Device (RTKX)
            {
                Name (_ADR, Zero)  // _ADR: Address
                Name (_HID, "10EC5682" /* Realtek I2S Audio Codec */)  // _HID: Hardware ID
                Name (_CID, "10EC5682" /* Realtek I2S Audio Codec */)  // _CID: Compatible ID
                Name (_DDN, "RTEK Codec Controller ")  // _DDN: DOS Device Name
                Name (_UID, One)  // _UID: Unique ID
                Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
                {
                    Name (SBUF, ResourceTemplate ()
                    {
                        I2cSerialBus (0x001A, ControllerInitiated, 0x00061A80,
                            AddressingMode7Bit, "\\_SB.I2C6",
                            0x00, ResourceConsumer, ,
                            )
                        GpioInt (Edge, ActiveHigh, ExclusiveAndWake, PullNone, 0x0000,
                            "\\_SB.GPO2", 0x00, ResourceConsumer, ,
                            )
                            {   // Pin list
                                0x0000 //Pin 21 of JP1 (GPIO_S5_00)
                            }
                    })
                    Return (SBUF) /* \_SB_.I2C6.RTKX._CRS.SBUF */
                }

                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                        Return (0x0F)
                }

                Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
                {
                }
         }
  }

  Scope (_SB)
   {
        Device (LPEX) // plb: renamed here and inside block
        {
            Name (_ADR, Zero)  // _ADR: Address
            Name (_HID, "80860F28")  // _HID: Hardware ID
            Name (_CID, "80860F28")  // _CID: Compatible ID
            Name (_DDN, "Intel(R) Low Power Audio Controller - 80860F28")  // _DDN: DOS Device Name
            Name (_SUB, "80867270")  // _SUB: Subsystem ID
            Name (_UID, One)  // _UID: Unique ID
            Name (_DEP, Package (0x01)  // _DEP: Dependencies
            {
                ^I2C6.RTKX
            })
            Name (_PR0, Package (0x01)  // _PR0: Power Resources for D0
            {
                PLPE
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
            }

            Name (RBUF, ResourceTemplate ()
            {
                Memory32Fixed (ReadWrite,
                    0xFE400000,         // Address Base
                    0x00200000,         // Address Length
                    _Y03)
                Memory32Fixed (ReadWrite,
                    0xFE830000,         // Address Base
                    0x00001000,         // Address Length
                    _Y04)
                Memory32Fixed (ReadWrite,
                    0x55AA55AA,         // Address Base
                    0x00100000,         // Address Length
                    _Y05)
                Interrupt (ResourceConsumer, Level, ActiveLow, Exclusive, ,, )
                {
                    0x00000018,
                }
                Interrupt (ResourceConsumer, Level, ActiveLow, Exclusive, ,, )
                {
                    0x00000019,
                }
                Interrupt (ResourceConsumer, Level, ActiveLow, Exclusive, ,, )
                {
                    0x0000001A,
                }
                Interrupt (ResourceConsumer, Level, ActiveLow, Exclusive, ,, )
                {
                    0x0000001B,
                }
                Interrupt (ResourceConsumer, Level, ActiveLow, Exclusive, ,, )
                {
                    0x0000001C,
                }
                Interrupt (ResourceConsumer, Level, ActiveLow, Exclusive, ,, )
                {
                    0x0000001D,
                }
                GpioInt (Edge, ActiveHigh, ExclusiveAndWake, PullNone, 0x0000,
                    "\\_SB.GPO2", 0x00, ResourceConsumer, ,
                    )
                    {   // Pin list
                        0x001C
                    }
            })
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateDWordField (RBUF, \_SB.LPEX._Y03._BAS, B0BA)  // _BAS: Base Address
                Store (LPE0, B0BA)
                CreateDWordField (RBUF, \_SB.LPEX._Y04._BAS, B1BA)  // _BAS: Base Address
                Store (LPE1, B1BA)
                CreateDWordField (RBUF, \_SB.LPEX._Y05._BAS, B2BA)  // _BAS: Base Address
                Store (LPE2, B2BA)
                Return (RBUF)
            }

            OperationRegion (KEYS, SystemMemory, LPE1, 0x0100)
            Field (KEYS, DWordAcc, NoLock, WriteAsZeros)
            {
                Offset (0x84), 
                PSAT,   32
            }

            PowerResource (PLPE, 0x00, 0x0000)
            {
                Method (_STA, 0, NotSerialized)  // _STA: Status
                {
                    Return (One)
                }

                Method (_ON, 0, NotSerialized)  // _ON_: Power On
                {
                    And (PSAT, 0xFFFFFFFC, PSAT)
                    Or (PSAT, Zero, PSAT)
                }

                Method (_OFF, 0, NotSerialized)  // _OFF: Power Off
                {
                    Or (PSAT, 0x03, PSAT)
                    Or (PSAT, Zero, PSAT)
                }
            }
        }
    }
}
