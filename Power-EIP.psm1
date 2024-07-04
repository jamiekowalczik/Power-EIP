Function Connect-EIP {
  <#
    .SYNOPSIS
    Establishes a connection to an EfficientIP SOLIDServer and saves the connection information
	to a global variable to be used by subsequent Rest commands.

    .DESCRIPTION
    Attempt to esablish a connection to an EfficientIP SOLIDServer and if the connection succeeds
	then it is saved to a global variable to be used for subsequent Rest commands.
	
    .EXAMPLE
    PS C:\>  Connect-EIP -Hostname eip.local -Username ausername -DNSName smart.local -View external -Password apassword

  #>
  
  [CmdLetBinding(DefaultParameterSetName="Hostname")]
  
  Param(
    [Parameter(Mandatory=$false)][Bool]$SkipCertificateCheck = $false,
    [Parameter(Mandatory=$true)][String]$Hostname,
    [Parameter(Mandatory=$true)][String]$Username,
    [Parameter(Mandatory=$false)][String]$Password,
    [Parameter(Mandatory=$true)][String]$DNSName,
    [Parameter(Mandatory=$true)][String]$View,
    [Parameter(Mandatory=$false)][Bool]$Troubleshoot = $false
  )
  
  begin {}
  
  process {
    If($Password -eq ""){
      $Password = Read-Host 'Password' -MaskInput
    }
    $Endpoint = "dns_rr_count"
    $URI = "/rest/$($Endpoint)"
    $URL = "https://$($Hostname)$($URI)"
    $basicAuthValue = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Username, $Password)))
    $Headers = @{
          "Authorization"="Basic $basicAuthValue"
          "Content-Type"="application/json"
          "Accept"="application/json"
          "charset"="utf-8"
    }

    Try {
      $SplatVars += @{Method = "GET"}
      $SplatVars += @{Headers = $Headers}
      $SplatVars += @{Uri = $URL}
      If($SkipCertificateCheck){ $SplatVars += @{SkipCertificateCheck = $true} }

      $requests = Invoke-WebRequest @SplatVars

      If($Troubleshoot){ $requests }
      
    } catch {
      if($_.Exception.Response.StatusCode -eq "Unauthorized") {
        Write-Host -ForegroundColor Red "`nThe EfficientIP SOLIDServer connection failed - Unauthorized`n"
        Break
      } else {
        Write-Error "Error connecting to EfficientIP SOLIDServer"
        Write-Error "`n($_.Exception.Message)`n"
        Break
      }
    }
    
    $global:efficientIPConnection = new-object PSObject -Property @{
        'Headers' = $Headers
        'EIPApiHostname' = $Hostname
        'EIPApiUsername' = $Username
        'EIPApiPassword' = $Password
        'EIPApiTroubleshoot' = $Troubleshoot
        'EIPApiDNSName' = $DNSName
        'EIPApiDNSView' = $View
    }
    If($Troubleshoot){ $global:efficientIPConnection }
  }
  
  end {}
  
}

Function Send-EfficientIPRequest {
   Param(
      [Parameter(Mandatory=$true, HelpMessage="Endpoint")][String]$Endpoint,
      [Parameter(Mandatory=$false, HelpMessage="Method")][String]$Method = "Get",
      [Parameter(Mandatory=$true, HelpMessage="Parameters")][String]$Parameters
   )

   begin {}

   process {

      $URI = "/rest/$($Endpoint)?$($Parameters)"
      $URL = "https://$($global:efficientIPConnection.EIPApiHostname)$($URI)"
      
      If ($global:efficientIPConnection.EIPApiTroubleshoot) {
         Write-Host "URL: $($URL)"
         Write-Host "Method: $($Method)"
      }

      $SplatVars += @{Method = $Method}
      $SplatVars += @{Headers = $global:efficientIPConnection.Headers}
      $SplatVars += @{Uri = $URL}
      If($SkipCertificateCheck){ $SplatVars += @{SkipCertificateCheck = $true} }

      Try {
         $requests = Invoke-WebRequest @SplatVars
         Return $requests
      } catch {
         if($_.Exception.Response.StatusCode -eq "Unauthorized") {
            Write-Host -ForegroundColor Red "`nThe EfficientIP connection failed - Unauthorized`n"
         } else {
            Write-Error "Error connecting to EfficientIP"
            Write-Error "`n($_)`n"
         }
      }
   }
   
   end {}
}

Function Get-EIPDNSRecordID {
   Param(
      [Parameter(Mandatory=$true, HelpMessage="DNS RR Record Name")][String]$DNSRRRecordName
   )
   $Endpoint = "dns_rr_list"
   $Parameters = "WHERE=(rr_full_name='$($DNSRRRecordName)'+OR+value1='$($DNSRRRecordName)')+AND+(dns_name='$($global:efficientIPConnection.EIPApiDNSName)'+AND+dnsview_name='$($global:efficientIPConnection.EIPApiDNSView)')"
   
   $Response = Send-EfficientIPRequest -Parameters $Parameters -Endpoint $Endpoint
   Return ($Response.Content | ConvertFrom-JSON).rr_id
}

Function Get-EIPDNSRecordInfo {
   Param(
      [Parameter(Mandatory=$false, HelpMessage="DNS RR Record ID")][String]$DNSRRRecordID,
      [Parameter(Mandatory=$false, HelpMessage="DNS RR Record Name")][String]$DNSRRRecordName
   )

   If($DNSRRRecordID -eq '') {
      $DNSRRRecordIDs = Get-EIPDNSRecordID -DNSRRRecordName $DNSRRRecordName
   }Else{
      $DNSRRRecordIDs = $DNSRRRecordID
   }
   
   $Endpoint = "dns_rr_info"

   $Response += $DNSRRRecordIDs | % { Send-EfficientIPRequest -Parameters "rr_id=$($_)" -Endpoint $Endpoint }
   Return $Response.Content | ConvertFrom-JSON
}

Function New-EIPDNSRecord {
   Param(
      [Parameter(Mandatory=$false, HelpMessage="DNS RR Record Name")][String]$DNSRRRecordName,
      [Parameter(Mandatory=$false, HelpMessage="DNS RR Record Value")][String]$DNSRRRecordValue,
      [Parameter(Mandatory=$false, HelpMessage="DNS RR Record Type")][String]$DNSRRRecordType
   )

   $Endpoint = "dns_rr_add"
   $Parameters = "dnsview_name=$($global:efficientIPConnection.EIPApiDNSView)&rr_name=$DNSRRRecordName&rr_type=$DNSRRRecordType&value1=$($DNSRRRecordValue)&add_flag=new_only&check_value=yes&dns_name=$($global:efficientIPConnection.EIPApiDNSName)"

   $Response = Send-EfficientIPRequest -Parameters $Parameters -Endpoint $Endpoint -Method POST
   Return $Response.Content | ConvertFrom-JSON
}

Function Update-EIPDNSRecord {
   Param(
      [Parameter(Mandatory=$false, HelpMessage="DNS RR Record ID")][String]$DNSRRRecordID,
      [Parameter(Mandatory=$false, HelpMessage="DNS RR Record Name")][String]$DNSRRRecordName,
      [Parameter(Mandatory=$false, HelpMessage="DNS RR Record Value")][String]$DNSRRRecordValue
   )

   If($DNSRRRecordID -eq '') {
      $DNSRRRecord = Get-EIPDNSRecordID -DNSRRRecordName $DNSRRRecordName
      If($DNSRRRecord.count -eq 0){
         Write-Host "No records exist, exiting..."
         Break
      }ElseIf($DNSRRRecord.count -gt 1){
         Write-Host "More than one record returned, exiting..."
         Break
      }
      $DNSRRRecordID = $DNSRRRecord
   }

   $Endpoint = "dns_rr_add"
   $Parameters = "rr_id=$($DNSRRRecordID)&value1=$($DNSRRRecordValue)&add_flag=edit_only"

   $Response = Send-EfficientIPRequest -Parameters $Parameters -Endpoint $Endpoint -Method PUT
   Return $Response.Content | ConvertFrom-JSON
}

Function Remove-EIPDNSRecord {
   Param(
      [Parameter(Mandatory=$false, HelpMessage="DNS RR Record ID")][String]$DNSRRRecordID,
      [Parameter(Mandatory=$false, HelpMessage="DNS RR Record Name")][String]$DNSRRRecordName
   )

   If($DNSRRRecordID -eq '') {
      $DNSRRRecord = Get-EIPDNSRecordID -DNSRRRecordName $DNSRRRecordName
      If($DNSRRRecord.count -eq 0){
         Write-Host "No records exist, exiting..."
         Break
      }ElseIf($DNSRRRecord.count -gt 1){
         Write-Host "More than one record returned, exiting..."
         Break
      }
      $DNSRRRecordID = $DNSRRRecord
   }

   $Endpoint = "dns_rr_delete"
   $Parameters = "rr_id=$($DNSRRRecordID)"

   $Response = Send-EfficientIPRequest -Parameters $Parameters -Endpoint $Endpoint -Method DELETE
   Return $Response.Content | ConvertFrom-JSON
}
