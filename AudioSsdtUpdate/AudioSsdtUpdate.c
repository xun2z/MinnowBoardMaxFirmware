/** @file
  Update SSDT table to ACPI table.

  Copyright (c) 2013 - 2015, Intel Corporation. All rights reserved.<BR>

  This program and the accompanying materials 
  are licensed and made available under the terms and conditions of the BSD License 
  which accompanies this distribution.  The full text of the license may be found at 
  http://opensource.org/licenses/bsd-license.php

  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS, 
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include "AudioSsdtUpdate.h"

FV_INPUT_DATA mInputData = {0};

/**
  Read file data from given file name.

  @param[in]  FileName    Pointer the readed given file name.
  @param[out] Buffer      The buffer which read the given file name's data.
  @param[out] BufferSize  The buffer size which read the given file name's data.

  @retval EFI_SUCCESS     The file data is successfully readed.
  @retval EFI_ERROR       The file data is unsuccessfully readed.

**/
STATIC
EFI_STATUS
ReadFileData (
  IN  CHAR16   *FileName,
  OUT UINT8    **Buffer,
  OUT UINT32   *BufferSize
  )
{
  EFI_STATUS             Status;
  SHELL_FILE_HANDLE      FileHandle;
  UINT64                 Size;
  VOID                   *NewBuffer;
  UINTN                  ReadSize;

  FileHandle = NULL;
  NewBuffer = NULL;
  Size = 0;

  Status = ShellOpenFileByName (FileName, &FileHandle, EFI_FILE_MODE_READ, 0);
  if (EFI_ERROR (Status)) {
    goto Done;
  }

  Status = FileHandleIsDirectory (FileHandle);
  if (!EFI_ERROR (Status)) {
    Status = EFI_NOT_FOUND;
    goto Done;
  }

  Status = FileHandleGetSize (FileHandle, &Size);
  if (EFI_ERROR (Status)) {
    goto Done;
  }

  NewBuffer = AllocatePool ((UINTN) Size);

  ReadSize = (UINTN) Size;
  Status = FileHandleRead (FileHandle, &ReadSize, NewBuffer);
  if (EFI_ERROR (Status)) {
    goto Done;
  } else if (ReadSize != (UINTN) Size) {
    Status = EFI_INVALID_PARAMETER;
    goto Done;
  }

Done:
  if (FileHandle != NULL) {
    ShellCloseFile (&FileHandle);
  }

  if (EFI_ERROR (Status)) {
    if (NewBuffer != NULL) {
      FreePool (NewBuffer);
    }
  } else {
    *Buffer = NewBuffer;
    *BufferSize = (UINT32) Size;
  }

  return Status;
}

/**
  Initialize and publish device in ACPI table.

  @param[in] Table          The pointer to the ACPI table which will be published. 
  @param[in] TableSize      The size of ACPI table which will be published.

  @retval   EFI_SUCCESS     The ACPI table is published successfully.
  @retval   Others          The ACPI table is not published.

**/
EFI_STATUS
PublishAcpiTable (
  IN UINT8       *Table,
  IN UINT32      TableSize
  )
{
  EFI_STATUS                     Status;
  EFI_ACPI_TABLE_PROTOCOL        *AcpiTable;
  UINTN                          TableKey;

  //
  // Basic check ::TODO: Add check here!!!!!!!!!!!!!!!!!
  //
  //ASSERT (Table->OemTableId == SIGNATURE_64 ('E', 'v', 'e', 'r', 'T', 'a', 'b', 'l'));

  //
  // Publish the  ACPI table
  //
  Status = gBS->LocateProtocol (&gEfiAcpiTableProtocolGuid, NULL, (VOID **) &AcpiTable);
  DEBUG((EFI_D_INFO, " Publish ACPI Table-3\n"));
  ASSERT_EFI_ERROR (Status);

  TableKey = 0;
  Status = AcpiTable->InstallAcpiTable (
                        AcpiTable,
                        (EFI_ACPI_DESCRIPTION_HEADER*) Table,
                        TableSize,
                        &TableKey
                        );
  DEBUG((EFI_D_INFO, " Publish ACPI Table-4\n"));
  ASSERT_EFI_ERROR (Status);

  return Status;
}

/**
  Init device 
  
  @retval EFI_SUCCESS     Init Devices successfully
  @retval Others          Some error occurs 

**/
EFI_STATUS
InitDevice (
  )
{
  //
  // Add device Init here if needed
  //
  return EFI_SUCCESS;
}

/**
  UEFI application entry point which has an interface similar to a
  standard C main function.

  The ShellCEntryLib library instance wrappers the actual UEFI application
  entry point and calls this ShellAppMain function.

  @param[in] Argc        The number of items in Argv.
  @param[in] Argv        Array of pointers to strings.

  @retval
**/
INTN
EFIAPI
 ShellAppMain (
  IN UINTN Argc,
  IN CHAR16 **Argv
  )
{
  EFI_STATUS                     Status;
  UINT8                          *FileBuffer;
  UINT32                         TableSize;
  UINT32                         Tmp_Gpio62_Val; /* SSP_2_CLK */
  UINT32                         Tmp_Gpio63_Val; /* SSP_2_FS  */
  UINT32                         Tmp_Gpio64_Val; /* SSP_2_RXD */
  UINT32                         Tmp_Gpio65_Val; /* SSP_2_TDX */
  UINT32                         Tmp_Gpio99_Val; /* PLT_CLK3  */
  UINT32 IoBase;

  
  TableSize         = 0;
  FileBuffer        = NULL;

  //
  // Necessary device Initialization
  //
  Status = InitDevice();
  if (EFI_ERROR (Status)) {
    return EFI_DEVICE_ERROR;
  }

  StrCpy (mInputData.FileName, Argv[1]);
  Status = ReadFileData (mInputData.FileName, &FileBuffer, &TableSize);
  
  //
  // Update and publish ACPI table
  //
  Status = PublishAcpiTable (FileBuffer, TableSize);
  ASSERT_EFI_ERROR (Status);
  
    
  IoBase = IO_BASE_ADDRESS;

  //
  // Programming GPIOC_062 (SSP_2_CLK) to Native to enable audio
  //
  Tmp_Gpio62_Val = MmioRead32(IoBase + 0x00D0);
  Tmp_Gpio62_Val = Tmp_Gpio62_Val | BIT0;
  MmioWrite32(IoBase + 0x00D0, Tmp_Gpio62_Val);
 
  //
  // Programming GPIOC_063 (SSP_2_FS) to Native to enable audio
  //
  Tmp_Gpio63_Val = MmioRead32(IoBase + 0x00C0);
  Tmp_Gpio63_Val = Tmp_Gpio63_Val | BIT0;
  MmioWrite32(IoBase + 0x00C0, Tmp_Gpio63_Val);

  //
  // Programming GPIOC_064 (SSP_2_RXD) to Native to enable audio
  //
  Tmp_Gpio64_Val = MmioRead32(IoBase + 0x00F0);
  Tmp_Gpio64_Val = Tmp_Gpio64_Val | BIT0;
  MmioWrite32(IoBase + 0x00F0, Tmp_Gpio64_Val);

  //
  // Programming GPIOC_065 (SSP_2_TXD) to Native to enable audio
  //
  Tmp_Gpio65_Val = MmioRead32(IoBase + 0x00E0);
  Tmp_Gpio65_Val = Tmp_Gpio65_Val | BIT0;
  MmioWrite32(IoBase + 0x00E0, Tmp_Gpio65_Val);

  //
  // Programming GPIOC_099 (PLT_CLK3) to Native to enable audio
  //
  Tmp_Gpio99_Val = MmioRead32(IoBase + 0x0068);
  Tmp_Gpio99_Val = Tmp_Gpio99_Val | BIT0;
  MmioWrite32(IoBase + 0x0068, Tmp_Gpio99_Val);

  return Status;
  }

