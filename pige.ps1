# BUG majeur à fixer :P 
# si le dernier pick a deja été pick,  ca loop à l'infinie. 
# changer l'algorithme

[CmdletBinding()]


param (
    [string]$pairHistoryFolder,
    [string]$itemsFile,
    [string]$outputFilePath,
    [bool]$stats = $false,
    [bool]$SendEmail = $false

)

$DebugPreference = 'Continue'
#$DebugPreference = "SilentlyContinue"

#    [string]$emailServer = "your.smtp.server",
#    [string]$emailFrom = "your@email.com"

# Function to send an email
function Send-Email {
    param (
        [string]$to,
        [string]$subject,
        [string]$body,
        [PSCredential]$credential
    )

    $smtpParams = @{
        SmtpServer  = $emailServer
        From        = $emailFrom
        To          = $to
        Subject     = $subject
        Body        = $body
        Credential  = $credential
        Port        = 587  # Update the port as needed
        UseSsl      = $true
    }

    Send-MailMessage @smtpParams
}

if ($outputFilePath) {
    $outputFileName = "pige-$((Get-Date).ToString('yyyyMMdd-HHmmss')).csv"
    $outputFilePath = $outputFilePath + $outputFileName
}

# Check if the specified output file exists
if (Test-Path $outputFileName) {
    Write-Host "Error: Output file '$outputFileName' already exists. Please specify a different file path."
    return
}

# Initialize a list of items (in this case, human names)
$items = @()

if (-not $itemsFile){
    Write-host "Erreur. Fichier source non fournie."
    return 1
}else{
    # Load items from the file and split based on commas
    $items = Get-Content $itemsFile -Raw -ErrorAction Stop
    $items = $items -split ',' | ForEach-Object { $_.Trim() }
}

# Initialize an array for tracking pair history
$pairHistory = @()

# Validate pairHistoryFolder parameter
if ($pairHistoryFolder) {
    
    # Define the folder to store individual pair history files
    if (-not (Test-Path $pairHistoryFolder -PathType Container)) {
        New-Item -Path $pairHistoryFolder -ItemType Directory
    }

    # Load existing pair history from files in the specified folder
    if (Test-Path $pairHistoryFolder -PathType Container) {
        $pairHistoryFiles = Get-ChildItem -Path $pairHistoryFolder -Filter '*.csv'

        $historyPairs = ""

        foreach ($file in $pairHistoryFiles) {
            $historyContent = Get-Content $file.FullName -Raw
            Write-debug "Getting content of $file"
            $historyPairs = $historyContent -split '\r?\n' | Where-Object { $_ -ne '' }
            foreach ($pair in $historyPairs) {
                Write-debug $pair
            }

            # Add each pair to the $pairHistory array
            foreach ($pair in $historyPairs) {
                $pairHistory += $pair
            }
        }
        
    }     
}

# Convert $items to an ArrayList
$items = [System.Collections.ArrayList]$items

# Create pairs of items without repeating any item or previous pairs
$pairsFinal = New-Object System.Collections.ArrayList 

function draw {

    param (
        [array] $pairHistory,
        [System.Collections.ArrayList] $items,
        [System.Collections.ArrayList] $pairsFinal
    )

    Do {
        Write-debug "DRAW BEGINS **************************"
        Do {
            $randomIndex1 = Get-Random -Minimum 0 -Maximum $items.Count
            $randomIndex2 = Get-Random -Minimum 0 -Maximum $items.Count
        } while ($randomIndex1 -eq $randomIndex2)
        Write-Debug "RANDOM INDEX 1: $randomIndex1"
        Write-Debug "RANDOM INDEX 2: $randomIndex2"


        $item1 = $items[$randomIndex1]
        $item2 = $items[$randomIndex2]
        Write-Debug "Item1 $item1"
        Write-Debug "Item2 $item2"
        $thePair = $item1 + "," + $item2
    
        $item1 = $items[$randomIndex1]
        $item2 = $items[$randomIndex2]
        
        $thePair = $item1 + "," + $item2
        Write-Debug "THE PAIR: $thePair"
        $thePairSingleElement = $thePair  -split ',' | Where-Object { $_ -ne '' }
        $pairReverse = $thePairSingleElement[1] + "," + $thePairSingleElement[0]
        if (($pairHistory  -notcontains $pairReverse) -or ($pairHistory -notcontains $thePair) ){
            write-debug "The pair does not exist yet"
        }else{
            Write-debug "The pair exists"
        }

        #write-host "(pairHistory  -contains pairReverse) = " ($pairHistory  -contains $pairReverse)
        #write-host "(pairHistory -contains thePair)" ($pairHistory -contains $thePair)

    } while (($pairHistory  -contains $pairReverse) -or ($pairHistory -contains $thePair) )

    $item1 = $item1 + ""
    $item2 = $item2 + ""
    $thePair = $thePair + ""
    
    $pairsFinal.Add($thePair) > $null
    Write-Debug "RANDOM INDEX 2: $pairs"
    Write-Debug "ITEMS Fin: $items"
    #############################################
    $items.Remove($item1) 
    $items.Remove($item2) 
    #$items.RemoveAt($randomIndex1) 
    #$items.RemoveAt($randomIndex2) 
    #############################################
    Write-debug "DRAW Ends **************************"
}


Do {
    draw -pairHistory $pairHistory -items $items -pairsFinal $pairsFinal 
} while ($items.Count -ge 2)
    
if ($outputFilePath){
    $pairsFinal | Out-File $outputFilePath
    Write-Host "Pairs exported to $outputFilePath."    
}

# SEND EMAIL SECTION 
if ($SendEmail -eq $true){
    # Prompt the user for email credentials
    #$emailCredential = Get-Credential -Message "Enter your email credentials"
    #FONCTION À AJOUTER
    # Output the pairs and send emails
    #for ($i = 0 ; $i -lt  $pairs.Count; $i+=2){    
    #$Write-Host "PAIR $($i/2+1): $($pairs[$i]) - $($pairs[$i+1])"
    #if ($outputFilePath) {
        #    $($pairs[$i]) + "," +  $($pairs[$i+1]) | Out-File -FilePath $outputFilePath -Append
            #$pair | Out-File -FilePath $outputFilePath -Append

            
        #} else {
        #    Write-Host "$($pairs[$i]), $($pairs[$i+1])"
        #}
        
    #    # Sending emails to the owners of each item
    #    Send-Email -to "owner@$item1.com" -subject "Pairing Notification" -body "You are paired with $item2." -credential $emailCredential
    #    Send-Email -to "owner@$item2.com" -subject "Pairing Notification" -body "You are paired with $item1." -credential $emailCredential
}
#################################

# Display statistics section
if ($stats -eq $true){
    Write-host "Final pair $pairsFinal"
    Write-Host "Total Pairs Generated: $($pairsFinal.Count)"
    Write-Host "Unique Items Paired: $($pairsFinal.Count)"
}
#################################