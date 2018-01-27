# Jason Watson
# 11/8/2017
# updated 1/27/18
# Added to Github
# Reference: https://stackoverflow.com/questions/28118896/set-aduser-based-on-email-in-csv-file?rq=1

# 1. Import AD module
Import-Module ActiveDirectory

# 2. Import CSV of users
#  We need a csv file that has two columns: Username and Email


try { $importedfile = Import-CSV "C:\import.csv"
}
catch {
    Write-Host "File imported failed!" -ForegroundColor Yellow
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage -BackgroundColor White
}


# 3. For each user, create an email address variable and update the emailAddress and add a proxyAddresses entry
ForEach ($line in $importedfile) {
  $email = $line.EmailAddress
  $username = $line.Username
  Write-Host "Updating $username with $email..." -ForegroundColor Gray
  
  try {
    Get-AdUser -Filter {name -eq $username} | Set-AdUser -EmailAddress $email -Add @{proxyAddresses = ("SMTP:$email")}
  
  }
  catch {
  
    Write-Host "User update $username with email $email failed" -ForegroundColor Red
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage
  }
  
  # 3.1 See if the email field is blank!!
  $blankcheck = Get-ADUser -Filter {name -eq $username} -Properties EmailAddress | Select-Object EmailAddress

  # 3.1.1 If this if statement is true, proceed and print a success message.
  if($blankcheck) {

    Write-Host "User $username with email $email updated." -ForegroundColor Green
  }
  # 3.1.2 If the if statement is false, the Email property is blank. Print an error message.
  else { 
    Write-Host "An error occurred updating $username with email $email..." -ForegroundColor Red
  }
}
