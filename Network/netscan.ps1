Clear-Host
if (!($args[0])) { return "Usage: netscan `"Ip:min-max`" "; }


# Recuperation de l'adresse IP donnees en argument
# Puis split de chaque octets dans un tableau

$line = $args[0]
$line = $line -split "\."
$network = $line[0] + '.' + $line[1] + '.' + $line[2]
$interval = $line[3] -split "-"

$sub_line = " ----------------------- ----------------------- ----------------------"
echo "`t   IP`t`t`tHOSTNAME`t`t VENDOR"
echo $sub_line
# -----------------------------------------------------------

# Suppression de tous les Jobs en instance

$jobs = (Get-Job)
$jobs = $jobs | findstr "Job"
if ($jobs) {
    $jobs = $jobs[1..($jobs.Length - 1)]
}
foreach ($job in $jobs) {
    $job = $job | findstr "Job"
    if ($job) {
        $job = $job -split " "
        $i = 0
        while ($i -lt $job.Length) {
            if ($job[$i] | findstr "Job") {
                $id = $job[$i].Substring(3, ($job[$i].Length - 3))
                break
            }
            $i++
        }
        Remove-Job -Id $id
    }
}
#------------------------------------------------------------------


[int]$max = $interval[1]

[int]$i = $interval[0]
while (($i -lt $max) -or ($jobs)) {
    $jobs = (Get-Job)
    if (($jobs.Length -lt 10) -and ($i -lt $max)) {
        Start-Job -ArgumentList $i, $network, $sub_line -ScriptBlock {
            $ip = $args[0]
            $network = $args[1]
            $sub_line = $args[2]

            $ping = (ping -n 1 "$network.$ip" -l 1)

            if (($ping | findstr "temps")) {
                $ping = ping -a -n 1 "$network.$ip" -l 1
                $ping = $ping -split " "
                Write-Host -NoNewLine ("|  $network.$ip")
                if ($ip -lt 99) { Write-Host -NoNewLine ("`t") }
                Write-Host -NoNewline ("`t| ")
                if (!$ping[5].CompareTo("sur")) {
                    $hostname = $ping[6].Substring(0, [Math]::Min(10, $ping[6].Length))
                    Write-Host -NoNewLine $hostname + "`t"
                    if (($hostname.Length) -lt 13) { Write-Host -NoNewline "`t" }
                    Write-host -NoNewline "|`t"
                } else {
                    Write-Host -NoNewline "........`t`t|`t"
                  }
                $arp = (arp -a | findstr "$network.$ip").Replace(" ", "~")
                $arp = ($arp | findstr "$network.$ip~")
                if ($arp) {
                    $arp = $arp.Replace("-", ":")
                    $arp = $arp -split "~"
                    
                    $mac = $arp | findstr ":"
                    $mac = $mac -split ":"
                    $mac = $mac[0] + $mac[1] + $mac[2]
                    $vendor = (Get-Content '.\Code\Powershell\Reseaux\Vendor\ma-l.csv' | findstr /i "$mac")
                    $vendor += "`n"
                    $vendor += (Get-Content '.\Code\Powershell\Reseaux\Vendor\ma-m.csv' | findstr /i "$mac")
                    $vendor += "`n"
                    $vendor += (Get-Content '.\Code\Powershell\Reseaux\Vendor\ma-s.csv' | findstr /i "$mac")
                    $vendor = $vendor -split ","
                    $vendor = $vendor[2]
                    if ($vendor.Length -gt 10) {
                        $vendor = $vendor.Substring(0, [Math]::Min(10, $vendor.Length))
                    }
                    if ($vendor) {
                        Write-Host -NoNewLine "$vendor`t"
                        if ($vendor.Length -lt 9) { Write-Host -NoNewLine "`t" }
                        Write-Host -NoNewLine "|`n"
                    }
                    else { Write-Host -NoNewLine ".........`t|`n" }
                } else { Write-Output ".........`t|"}
                  Write-Output $sub_line
            }
        } > $null
        $i++
    } else { Start-sleep -Milliseconds 5 }
    foreach ($job in $jobs) {
        $job = $job | findstr "Completed"
        if ($job) {
            $job = $job -split " "
            $cnt = 0
            while ($cnt -lt $job.Length) {
                if ($job[$cnt] | findstr "Job") {
                    $id = $job[$cnt].Substring(3, ($job[$cnt].Length - 3))
                    break
                }
                $cnt++
            }
            Receive-Job -Id $id 2>$null
            Remove-Job -Id $id 2>$null
        }
    }
}



#-----------------------------------------------------
#       
<#
    $tab = Get-Job
    $status = $tab[1]
    $status = $status | findstr "Completed"
    $status = $status -split "   "
    $status[0]
#>



#-------------------------------------------------------

<#
$job_list = (Get-Job | findstr "Job")
$job_id = $job_list[1] -split " "
$job_id = $job_id[0]
$job_list
$job_id

if (!$job_list[0].CompareTo("Id")) {
    echo "Vrai"
} else { echo "Faux" }
#>

<#
for ($i = 881; $i -lt 920; $i++) {
    remove-job -id $i
}
#>
 
 # Commande autorisation script #
 # ----------------------------------
 # set-executionPolicy unrestricted



 