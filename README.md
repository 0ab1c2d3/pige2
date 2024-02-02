# PowerShell Script: pige.ps1

## Description
Perform a random selection of duo. Duo are splut by line and items are split by comma. 

## Usage

### License
This project is licensed under the [License Name] - see the LICENSE.md file for details.

### Contributing
If you would like to contribute to the project, please follow the Contributor Covenant.

### Issues
If you encounter any issues or have suggestions for improvements, please open an issue on the Issues page.

### Parameters

- `itemsFile` (mandatory): The file where the participants are stored, *** Seperate the item by a comma ','
- `outputFilePath` (mandatory): The draw output folder
- `pairHistoryFolder` (optional): Folder for the draw history
- `stats` (optional): Get the stats from the draw
- `SendEmail` (optional): DISABLE - Function to send draw to participants

### Example

```powershell
.\pige.ps1 -itemsFile (path) -outputFilePath  (path) -pairHistoryFolder (path)





