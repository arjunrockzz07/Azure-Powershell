# Benjamin Morgan benjamin.s.morgan@outlook.com 
<# Ref: { Mircosoft docs links
    Get-AzVMImageOffer:         https://docs.microsoft.com/en-us/powershell/module/az.compute/get-azvmimageoffer?view=azps-5.5.0
    Get-AzVMImageSku:           https://docs.microsoft.com/en-us/powershell/module/az.compute/get-azvmimagesku?view=azps-5.5.0
    Get-AzImage:                https://docs.microsoft.com/en-us/powershell/module/az.compute/get-azvmimage?view=azps-5.5.0:       
    Azure Linux Publishers:     https://gmusumeci.medium.com/how-to-find-azure-linux-vm-images-for-terraform-or-packer-deployments-24e8e0ac68a     
} #>
<# Required Functions Links: {
    None:                       In order for this function to work, another function will need to pass $LocationObject.DisplayName
} #>
<# Functions Description: {
    SetVMOS:                     Function to get a valid image for new VM
} #>
<# Variables: {      
    :GetAzureVMImage            Outer loop for managing function
    :GetAzureImagePublisher     Inner loop for getting the image publisher
    :GetAzureLinuxPublisher     Inner loop for getting the linux publisher
    :SelectAzurePub             Inner loop for selecting the linux publisher
    :GetAzureImageOffer         Inner loop for getting the image offerings
    :SelectAzureImageOffer      Inner loop for selecting the image offer
    :GetAzureImageSku           Inner loop for getting the image skus
    :SelectAzureImageSku        Inner loop for selecting the image sku
    :GetAzureImageVersion       Inner loop for getting the image version
    :SelectAzureImageVerType    Inner loop for selecting either latest or custom image version
    :SelectAzureImageVersion    Inner loop for selecting the image version
    $LocationObject:            Location object
    $ImageTypeObject:           Object determining if image will be windows or linux            
    $ImagePublisherList:        List of linux publishers
    $ImagePublisherNumber:      $var used in list
    $ImagePublisherArray        Array used for selecting the publisher
    $ImagePublisherInput:       $Var that loads items into array
    $PublisherSelect:           Operator input for the publisher selection
    $VMPublisherObject:         Publisher name object  
    $ImageOfferList:            List of all offers
    $ImageOfferNumber:          $var used in list
    $ImageOfferArray:           Array used for selecting the offer
    $ImageOfferInput:           $Var that loads items into array
    $OfferSelect:               Operator input for the offer selection
    $VMOfferObject:             Offer name object
    $ImageSkuList:              List of all skus
    $ImageSkuNumber:            $var used in list
    $ImageSkuArray:             Array used for selecting the sku
    $ImageSkuInput:             $Var that loads items into array
    $SkuSelect:                 Operator input for the sku selection
    $VMSkuObject:               The sku name object
    $ImageVersionOption:        Operator input for selecting either the current version or other
    $ImageVersionList:          List of all versions 
    $ImageVersionNumber:        $var used in list 
    $ImageVersionArray:         Array used to select the version
    $ImageVersionInput:         $Var used to load items into array
    $VersionSelect:             Operator input for the version selection
    $VMVersionObject:           Version name object
    $VMImageObject:             Object used to select the image for VM creation
} #>
<# Process Flow {
    function
        Call SetVMOS > Get $VMImageObject
        End SetVMOS
            Return Function > Send $VMImageObject
}#>
function SetAzVMOS {                                                                        # Function to get a image for a new VM
    Begin {                                                                                 # Begin function
        :GetAzureVMImage while ($true) {                                                    # Outer loop for managing function
            :GetAzureImagePublisher while ($true) {                                         # Inner loop for setting the publisher
                if (!$ImageTypeObject) {                                                    # If $ImageTypeObject is $null
                    Write-Host "[0] Exit"                                                   # Write message to screen
                    Write-Host "[1] Windows"                                                # Write message to screen
                    Write-Host "[2] Linux"                                                  # Write message to screen
                    $ImageTypeObject = Read-Host '[0], [1], or [2]'                         # Operator input for the image type
                }                                                                           # End if (!$ImageTypeObject)
                if ($ImageTypeObject -eq '0') {                                             # If $ImageTypeObject equals 0
                    Break GetAzureVMImage                                                   # Breaks :GetAzureVMImage
                }                                                                           # End if ($ImageTypeObject -eq '0') 
                elseif ($ImageTypeObject -eq '1') {                                         # Else if $ImageTypeObject equals 1
                    $VMPublisherObject = 'MicrosoftWindowsServer'                           # Sets the Windows publisher
                    Break GetAzureImagePublisher                                            # Breaks :GetAzureImagePublisher
                }                                                                           # End elseif ($ImageTypeObject -eq '1')
                elseif ($ImageTypeObject -eq '2') {                                         # Else if $ImageTypeObject equals 2
                    :GetAzureLinuxPublisher while ($true) {                                 # Outer loop to manage function
                        [System.Collections.ArrayList]$ImagePublisherArray = @()            # Creates the valid Pub array
                        $ImagePublisherList = @('Ubuntu','RedHat','CentOS','SUSE','Debian', `
                            'Oracle','CoreOS')                                              # Creates a list of items to load into $ImagePublisherArray Array
                        $ImagePublisherNumber = 1                                           # Sets the base number for the valid Pub array
                        foreach ($_ in $ImagePublisherList) {                               # For each item in $ImagePublisherList
                            $ImagePublisherInput = [PSCustomObject]@{'Name' = $_;'Number' `
                                = $ImagePublisherNumber}                                    # Creates the item to loaded into array
                            $ImagePublisherArray.Add($ImagePublisherInput) | Out-Null       # Loads item into array, out-null removes write to screen
                            $ImagePublisherNumber = $ImagePublisherNumber + 1               # Increments $ImagePublisherNumber up 1
                        }                                                                   # End foreach ($_ in $ImagePublisherList)
                        Write-Host '0 Exit'                                                 # Write message to screen
                        foreach ($_ in $ImagePublisherArray) {                              # For each item in $ImagePublisherArray
                            Write-Host $_.Number $_.Name                                    # Write message to screen
                        }                                                                   # End foreach ($_ in $ImagePublisherArray)
                        :SelectAzurePub while ($true) {                                     # Inner loop for selecting the publisher
                            $PublisherSelect = Read-Host "Publisher number"                 # Operator selection of the publisher
                            if ($PublisherSelect -eq '0') {                                 # If $Pubselect -eq 0
                                Break GetAzureVMImage                                       # Breaks :GetAzureVMImage
                            }                                                               # End ($PublisherSelect -eq '0')
                            $VMPublisherObject = $ImagePublisherArray | Where-Object `
                                {$_.Number -eq $PublisherSelect}                            # $VMPublisherObject equals $ImagePublisherArray where $ImagePublisherArray.Number is equal to $PublisherSelect
                            If ($VMPublisherObject) {                                       # If $VMPublisherObject has a value
                                Break SelectAzurePub                                        # Breaks :SelectAzurePub
                            }                                                               # End If ($VMPublisherObject)
                            else {                                                          # If $VMPublisherObject does not have a value
                                Write-Host "That was not a valid option"                    # Write message to screen
                            }                                                               # End else (# End If ($VMPublisherObject))
                        }                                                                   # End :SelectAzurePub while ($true)
                        if ($VMPublisherObject.Name -eq 'Ubuntu') {                         # If $VMPublisherObject equals this value
                            $VMPublisherObject = 'Canonical'                                # Reassigns the value of $VMPublisherObject
                        }                                                                   # End ($VMPublisherObject.Name -eq 'Ubuntu')
                        elseif ($VMPublisherObject.Name -eq 'RedHat') {                     # If $VMPublisherObject equals this value
                            $VMPublisherObject = 'RedHat'                                   # Reassigns the value of $VMPublisherObject
                        }                                                                   # End elseif ($VMPublisherObject.Name -eq 'RedHat')
                        elseif ($VMPublisherObject.Name -eq 'CentOS') {                     # If $VMPublisherObject equals this value
                            $VMPublisherObject = 'OpenLogic'                                # Reassigns the value of $VMPublisherObject
                        }                                                                   # End elseif ($VMPublisherObject.Name -eq 'CentOS')
                        elseif ($VMPublisherObject.Name -eq 'SUSE') {                       # If $VMPublisherObject equals this value
                            $VMPublisherObject = 'SUSE'                                     # Reassigns the value of $VMPublisherObject
                        }                                                                   # End elseif ($VMPublisherObject.Name -eq 'SuSE')
                        elseif ($VMPublisherObject.Name -eq 'Debian') {                     # If $VMPublisherObject equals this value
                            $VMPublisherObject = 'credativ'                                 # Reassigns the value of $VMPublisherObject
                        }                                                                   # End elseif ($VMPublisherObject.Name -eq 'Debian')
                        elseif ($VMPublisherObject.Name -eq 'Oracle') {                     # If $VMPublisherObject equals this value
                            $VMPublisherObject = 'Oracle-Linux'                             # Reassigns the value of $VMPublisherObject
                        }                                                                   # End elseif ($VMPublisherObject.Name -eq 'Oracle')
                        elseif ($VMPublisherObject.Name -eq 'CoreOS') {                     # If $VMPublisherObject equals this value
                            $VMPublisherObject = 'CoreOS'                                   # Reassigns the value of $VMPublisherObject
                        }                                                                   # End elseif ($VMPublisherObject.Name -eq 'CoreOS')
                        Break GetAzureImagePublisher                                        # Breaks :GetAzureImagePublisher
                    }                                                                       # End GetAzureVMImage
                }                                                                           # End elseif ($ImageTypeObject -eq '2')
                else {                                                                      # All other inputs
                    Write-Host "That was not a valid option"                                # Write message to screen
                }                                                                           # End else (if ($ImageTypeObject -eq '0'))
            }                                                                               # End :GetAzureImagePublisher while ($true)
            :GetAzureImageOffer while ($true) {
                $ImageOfferList = Get-AzVMImageOffer -Location $LocationObject.Location `
                    -PublisherName $VMPublisherObject                                       # Generates the image offer list
                $ImageOfferNumber = 1                                                       # Sets $ImageOfferNumber to 1
                [System.Collections.ArrayList]$ImageOfferArray = @()                        # Creates the valid Pub array
                foreach ($Offer in $ImageOfferList) {                                       # For each $Offer in $ImageOfferList
                    $ImageOfferInput = [PSCustomObject]@{'Name' = $Offer.Offer; `
                        'Number' = $ImageOfferNumber}                                       # Creates the item to loaded into array
                    $ImageOfferArray.Add($ImageOfferInput) | Out-Null                       # Loads item into array, out-null removes write to screen
                    $ImageOfferNumber = $ImageOfferNumber + 1                               # Increments $ImageofferNumber by 1
                }                                                                           # End foreach ($Offer in $ImageOfferList)
                Write-Host "0 Exit"                                                         # Write message to screen
                foreach ($_ in $ImageOfferArray) {                                          # For each $_ in $ImageOfferArray
                    Write-Host $_.Number $_.Name                                            # Writes offer number and name to screen
                }                                                                           # End foreach ($_ in $ImageOfferArray)
                :SelectAzureImageOffer while ($true) {                                      # Inner loop to select the image offer
                    $OfferSelect = Read-Host "Enter the offer number"                       # Operator input for the offer selection
                    if ($OfferSelect -eq '0') {                                             # If $OfferSelect equals 0
                        Break GetAzureVMImage                                               # Breaks :GetAzureVMImage
                    }                                                                       # End if ($OfferSelect -eq '0')
                    $VMOfferObject = $ImageOfferArray | Where-Object `
                        {$_.Number -eq $OfferSelect}                                        # $VMOfferObject is equal to $ImageOfferArray where $ImageOfferArray.Number equals $OfferSelect
                    if ($VMOfferObject) {                                                   # If $VMOfferObject has a value
                        Break GetAzureImageOffer                                            # Breaks :SelectAzureImage
                    }                                                                       # End if ($VMOfferObject)
                    else {                                                                  # If $VMOfferObject does not have a value
                        Write-Host "That was not a valid option"                            # Write message to screen
                    }                                                                       # End else (if ($VMOfferObject))
                }                                                                           # End :SelectAzureImage while ($true)
            }                                                                               # End :GetAzureImageOffer while ($true)
            :GetAzureImageSku while ($true) {                                               #
                $VMOfferObject = Get-AzVMImageOffer -Location $LocationObject.Location `
                    -PublisherName $VMPublisherObject | Where-Object {$_.Offer `
                    -eq $VMOfferObject.Name}                                                # Pulls the full $VMOfferObject
                $ImageSkuList = Get-AzVMImageSku -Offer $VMOfferObject.Offer `
                    -Location $LocationObject.DisplayName -PublisherName $VMPublisherObject # Generates the $ImageSkuList
                $ImageSkuNumber = 1                                                         # Sets $ImageSkuNumber to 1
                [System.Collections.ArrayList]$ImageSkuArray = @()                          # Creates the $ImageSkuArray     
                foreach ($Skus in $ImageSkuList) {                                          # For each Sku in $ImageSkuList
                    $ImageSkuInput = [PSCustomObject]@{'Name' = $Skus.Skus; `
                        'Number' = $ImageSkuNumber}                                         # Creates the item to loaded into array
                    $ImageSkuArray.Add($ImageSkuInput) | Out-Null                           # Loads item into array, out-null removes write to screen
                    $ImageSkuNumber = $ImageSkuNumber + 1                                   # Increments $ImageSkuNumber by 1
                }                                                                           # End foreach ($Offer in $ImageOfferList)
                Write-Host "0 Exit"                                                         # Write message to screen
                foreach ($_ in $ImageSkuArray) {                                            # For each $_ in $ImageSkuArray
                    Write-Host $_.Number $_.Name                                            # Writes $ImageSkuArray.number and $ImageSkuArray.Name to screen
                }                                                                           # End foreach ($_ in $ImageOfferArray)
                :SelectAzureImageSku while ($true) {                                        # Inner loop for selecting the image sku
                    $SkuSelect = Read-Host "Enter the sku number"                           # Operator input for selecting the image sku
                    if ($SkuSelect -eq '0') {                                               # If $SkuSelect equals 0
                        Break GetAzureVMImage                                               # Breaks :GetAzureVMImage
                    }                                                                       # End if ($OfferSelect -eq '0') 
                    $VMSkuObject = $ImageSkuArray | Where-Object {$_.Number -eq $SkuSelect} # $VMSkuObject equals $ImageSkuArray where $ImageSkuArray.Number equals $SkuSelect
                    $VMSkuObject = Get-AzVMImageSku -Offer $VMOfferObject.Offer `
                        -Location $LocationObject.DisplayName -PublisherName `
                        $VMPublisherObject | Where-Object {$_.Skus -eq $VMSkuObject.Name}   #                                       
                    if ($VMSkuObject) {                                                     # If $VMSkuObject has a value
                        Break GetAzureImageSku                                              # Break SelectAzureImageSku
                    }                                                                       # End if ($VMOfferObject)
                    else {                                                                  # If $VMSkuObject does not have a value
                        Write-Host "That was not a valid option"                            # Write message to screen
                    }                                                                       # End else (if ($VMOfferObject))
                }                                                                           # End :SelectAzureImage while ($true)
            }                                                                               # End :GetAzureImageSku while ($true)
            :GetAzureImageVersion while ($true) {                                           # Pulls the full $VMOfferObject
                :SelectAzureImageVerType while ($true) {                                    # Inner loop for chosing current or previous version of sku
                    Write-Host '[0] Exit'                                                   # Write message to screen
                    Write-Host '[1] Use current version'                                    # Write message to screen
                    Write-Host '[2] Select version'                                         # Write message to screen
                    $ImageVersionOption = Read-Host '[0], [1], or [2]'                      # Operator input for version selection type
                    if ($ImageVersionOption -eq '0') {                                      # If $ImageVersionOption equals 0
                        Break GetAzureVMImage                                               # Breaks :GetAzureVMImage
                    }                                                                       # End if ($ImageVersionOption -eq '0')            
                    elseif ($ImageVersionOption -eq '1' -or $ImageVersionOption -eq '2') {  # If $ImageVersionOption equals 1 or 2
                        Break SelectAzureImageVerType                                       # Breaks :SelectAzureImageVerType
                    }                                                                       # End elseif ($ImageVersionOption -eq '1' -or $ImageVersionOption -eq '2')
                    else {                                                                  # If $ImageVersionOption is not equal to 0, 1, or 2
                        Write-Host "That was not a valid option"                            # Write message to screen
                    }                                                                       # End else (if ($ImageVersionOption -eq '0'))
                }                                                                           # End :SelectAzureImageVerType while ($true)
                if ($ImageVersionOption -eq '1') {                                          # If $ImageVersionOption equals 1
                    $VMImageObject = $VMSkuObject                                           # VMImageObject is equal to $VMSkuObject
                    Return $VMImageObject                                                   # Returns $VMImageObject to calling function
                }                                                                           # End if ($ImageVersionOption -eq '1')
                else {                                                                      # If $ImageVersionOption is not '1' (can only be '2')
                    $ImageVersionList =  Get-AzVMImage -Location `
                        $LocationObject.Location -PublisherName $VMPublisherObject `
                        -Offer $VMOfferObject.Offer -Skus $VMSkuObject.Skus                 # Gets image version list and assigns to $var
                    $ImageVersionNumber = 1                                                 # Sets $ImageSkuNumber to 1
                    [System.Collections.ArrayList]$ImageVersionArray = @()                  # Creates the $ImageSkuArray     
                    foreach ($_ in $ImageVersionList) {                                     # For each Sku in $ImageSkuList
                        $ImageVersionInput = [PSCustomObject]@{'Name' = $_.Version; `
                            'Number' = $ImageVersionNumber}                                 # Creates the item to loaded into array
                        $ImageVersionArray.Add($ImageVersionInput) | Out-Null               # Loads item into array, out-null removes write to screen
                        $ImageVersionNumber = $ImageVersionNumber + 1                       # Increments $ImageSkuNumber by 1
                    }                                                                       # End foreach ($Offer in $ImageOfferList)
                    Write-Host "0 Exit"                                                     # Write message to screen
                    foreach ($_ in $ImageVersionArray) {                                    # For each $_ in $ImageSkuArray
                        Write-Host $_.Number $_.Name                                        # Writes $ImageSkuArray.number and $ImageSkuArray.Name to screen
                    }                                                                       # End foreach ($_ in $ImageVersionArray)
                    :SelectAzureImageVersion while ($true) {                                # Inner loop for selecting the image sku
                        $VersionSelect = Read-Host "Enter the Version number"               # Operator input for selecting the image sku
                        if ($VersionSelect -eq '0') {                                       # If $SkuSelect equals 0
                            Break GetAzureVMImage                                           # Breaks :GetAzureVMImage
                        }                                                                   # End if ($OfferSelect -eq '0')                                           
                        $VMVersionObject = $ImageVersionArray | `
                            Where-Object {$_.Number -eq $VersionSelect}                     # $VMSkuObject equals $ImageSkuArray where $ImageSkuArray.Number equals $SkuSelect
                        if ($VMVersionObject) {                                             # If $VMSkuObject has a value
                            $VMImageObject = Get-AzVMImage -Location `
                            $LocationObject.Location -PublisherName $VMPublisherObject `
                            -Offer $VMOfferObject.Offer -Skus $VMSkuObject.Skus -Version `
                            $VMVersionObject.Name                                           # If #VMVersionObject has a value, pull the full object and assign to $var
                            Break GetAzureImageVersion                                      # Break SelectAzureImageSku
                        }                                                                   # End if ($VMOfferObject)
                        else {                                                              # If $VMSkuObject does not have a value
                            Write-Host "That was not a valid option"                        # Write message to screen
                        }                                                                   # End else (if ($VMOfferObject))
                    }                                                                       # End :SelectAzureImageVersion while ($true)
                }                                                                           # End else(if ($ImageVersionOption -eq '1'))
            }                                                                               # End :GetAzureImageVersion while ($true)
            Return $VMImageObject                                                           # Returns #VMImageObject
        }                                                                                   # End :GetAZVMImage while ($true)
        Return                                                                              # Returns to calling function with null
    }                                                                                       # End Begin
}                                                                                           # End function SetAzVMOS