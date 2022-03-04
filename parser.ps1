<# Length of column names shouldn't change, so length of header can be hardcoded.
Source data does not have delimiter between end of header and first datum, so 
knowing the header length ahead of time is convenient. #>
$headerLength = 45
$numColumns = 8

<# Filenames. #>
$dataFile = ".\data.txt"
$outFile = ".\out.csv"

<# Get contents of unformatted text file, then trim to get rid of trailing spaces. #>
$contentString = [IO.File]::ReadAllText($dataFile)
$contentString = $contentString.Trim()

<# Variable to hold output string. #>
$formattedString = ""

<# Get header.  Length of column names shouldn't change, so length can be a constant. #>
$header = $contentString.Substring(0, $headerLength)
$formattedString += $header  + "`r`n"

<# Remove header from $contentString. #>
$contentString = $contentString.Substring($headerLength)

<# Process the data with a loop. #>
while ($contentString.Length -gt 0)
{
    <# Get first line except for last datum. #>
    for ($i = 0; $i -lt $numColumns - 1; $i++)
    {
        <# Don't pass '^' to output file if it's the last datum in the line. #>
        $firstUpCharIndex = $contentString.IndexOf('^')
        $datum = $contentString.Substring(0, $firstUpCharIndex + 1)
        $formattedString += $datum
        $contentString = $contentString.Substring($datum.Length, $contentString.Length - $datum.Length)
    }
    <# Get last datum in row and handle last row. #>
    $firstUpCharIndex = $contentString.IndexOf('^')
    if ($firstUpCharIndex -ne -1) 
    {
        $datum = $contentString.Substring(0, $firstUpCharIndex)
        $formattedString += $datum + "`r`n"
        $contentString = $contentString.Substring($datum.Length + 1, $contentString.Length - $datum.Length - 1)
    }
    else 
    {
        $formattedString += $contentString 
        $contentString = ""
    }
}

<# Create file for formatted text. Delete old file first if it already exists. #>
if (Test-Path($outFile))
{
    Remove-Item $outFile | Out-Null ### Out-Null hides output.
}
New-Item $outFile | Out-Null

<# Add formatted string to new file. #>
Add-Content $outFile $formattedString
