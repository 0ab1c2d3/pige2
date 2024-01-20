param (
    [string]$pairHistoryFolder,
    [string]$itemsFile,
    [string]$outputFilePath

)

$DebugPreference = 'Continue'


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

# Prompt the user for email credentials
#$emailCredential = Get-Credential -Message "Enter your email credentials"

# Initialize a list of items (in this case, human names)
# Load items from the file

#$items = @("Alice", "Bob", "Charlie", "David", "Eve", "Frank", "Grace", "Hannah", "Ivy", "Jack", "Katie", "Liam", "Mary", "Noah", "Olivia", "Peter", "Quinn", "Rachel", "Sam", "Tom", "Ursula", "Victor", "Wendy", "Xander", "Yvonne", "Zane")
$items = @()

if (-not $itemsFile){
    Write-host "Erreur. Fichier source non fournie."
    return 1
}else{
    # Load items from the file and split based on commas
    $items = Get-Content $itemsFile -Raw -ErrorAction Stop
    $items = $items -split ',' | ForEach-Object { $_.Trim() }
}

# Function to detect duplicates in a list
function Test-Duplicates {
    param (
        [array]$list
    )

    $duplicates = $list | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Group[0] }

    if ($duplicates.Count -gt 0) {
        Write-Error "Duplicate items found: $($duplicates -join ', ')"
        return $true
    } else {
        return $false
    }
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
            Write-host "FILE $file"
            $historyContent = Get-Content $file.FullName -Raw
            Write-Host "GETTING CONTENT OF  $file " $historyContent
            $historyPairs = $historyContent -split '\r?\n' | Where-Object { $_ -ne '' }
            foreach ($pair in $historyPairs) {
                Write-host "La PIGE = " $pair
            }


            # Add each pair to the $pairHistory array
            foreach ($pair in $historyPairs) {
                $pairHistory += $pair
                #Write-Host "Adding $pair to historyPairs"
            }
        }
        
    }     
}

#Write-host "LA PAIR HISTORY $historyPairs"
#foreach ($pair in $pairHistory) {
    #Write-Host "LA PAIR $pair"
#}

# Identify new items and remove items that no longer exist
#$newItems = $items | Where-Object { "$_notin$pairHistory" -eq $null }
#$removedItems = $pairHistory | Where-Object { "$_notin$items" -eq $null }

# Remove removed items from the pair history
#$pairHistory = $pairHistory | Where-Object { "$_notin$removedItems" -eq $null }

# Convert $items to an ArrayList
$items = [System.Collections.ArrayList]$items

# Create pairs of items without repeating any item or previous pairs

$pairsFinal = New-Object System.Collections.ArrayList 
   
    Do {
        
        Do {
            $randomIndex1 = Get-Random -Minimum 0 -Maximum $items.Count
            $randomIndex2 = Get-Random -Minimum 0 -Maximum $items.Count
        }
   
    while ($randomIndex1 -eq $randomIndex2 )
    Write-Debug "RANDOM INDEX 1: $randomIndex1"
    Write-Debug "RANDOM INDEX 2: $randomIndex2"

    $item1 = $items[$randomIndex1]
    $item2 = $items[$randomIndex2]

    Write-Debug "Item1 $item1"
    Write-Debug "Item2 $item2"
    $thePair = $item1 + "," + $item2
       
    Write-Debug "THE PAIR: $thePair"
    Write-Debug $thePair.GetType()
    $thePairSingleElement = $thePair  -split ',' | Where-Object { $_ -ne '' }
    
    
    if ($thePairSingleElement -contains $thePair){
        WRITE-HOST "$item1 et $item2 ont deja ete pige."
    }else{
        WRITE-HOST "$item1 et $item2 n'ont pas deja ete pige. AJOUT a l'historique"
    }

    $item1 = $item1 + ""
    $item2 = $item2 + ""
    $thePair = $thePair + ""
    

    $pairsFinal.Add($thePair)
    
    $items.RemoveAt($randomIndex1) 
    $items.RemoveAt($randomIndex2) 
    
    Write-Debug "RANDOM INDEX 2: $pairs"
    Write-Debug "ITEMS Fin: $items"

    } while ($items.Count -ge 2)
    
if ($outputFilePath){
    $pairsFinal | Out-File $outputFilePath
    Write-Host "Pairs exported to $outputFilePath."    
}

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



# Save the updated pair history to the input files in the folder
#foreach ($file in $pairHistoryFiles) {
#    $historyContent = $pairHistory | Where-Object { $_ -like "$($file.BaseName)*" }
#    $historyContent | Set-Content $file.FullName
#}

# Display statistics
#Write-Host "Total Pairs Generated: $($pairs.Count)"
#Write-Host "Unique Items Paired: $($items.Count)"
#Write-Host "Average Pairs per Item: $($pairs.Count / $items.Count)"