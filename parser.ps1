<# Script to add linebreaks to delimited text data. Assumes first value for each row is numeric. #>

<# Necessary info about data. #>
$numColumns = 12
$digitsInColumn1 = 7
$delimiter = "^"
$columnToMerge = 7

<# Filenames. #>
$dataFile = ".\data.txt"
$outFile = ".\out.txt"

<# Get contents of unformatted text file, then trim to get rid of trailing spaces. #>
$rawData = [IO.File]::ReadAllText($dataFile)
$rawData = $rawData.Trim()

<# StringBuilder object to hold strings. More efficient than string concatenation. #>
$contentString = [System.Text.StringBuilder]""
$contentString.Append($rawData) | Out-Null
$formattedString = [System.Text.StringBuilder]""

<# Set regex pattern.
Each row starts with a number that has $digitsInColumn1 digits, so we can assume that 
a row ends right before a number with $digitsInColumn1 digits appears in the substring. 
We can use that pattern to find a regex match and get the index of the row's end. #>
$regexColNum = $numColumns - 1 # Can't do math within a regex pattern
$regexPattern = "([^$delimiter]*\$delimiter){$regexColNum}[^\d{$digitsInColumn1}]*"

<# Loop through string, deleting matches from original after adding to formatted version. #>
while ($contentString -match $regexPattern) {
    $formattedString.AppendLine($Matches[0]) | Out-Null # $Matches is a hash table generated from -matches
    <# Delete matched string from original. #>
    $contentString.Remove(0, $Matches[0].Length) | Out-Null
}

# Remove trailing newline.
$formattedString.Remove($formattedString.Length - 2, 2) | Out-Null

# Remove nth column from header by removing delimiter and combining with (n-1)th column's title.
$regexColNum = $columnToMerge - 1
$regexPattern = "([^$delimiter]*\$delimiter){$regexColNum}"
$formattedString -match $regexPattern | Out-Null
$formattedString.Remove($Matches[0].Length - 1, 1) | Out-Null

<# Create file for formatted text. Delete old file first if it already exists. #>
if (Test-Path($outFile)) {
    Remove-Item $outFile | Out-Null
}
New-Item $outFile | Out-Null # Piping to Out-Null hides output that would normally be written to shell.

<# Add formatted string to new file. #>
Add-Content $outFile $formattedString.ToString()
