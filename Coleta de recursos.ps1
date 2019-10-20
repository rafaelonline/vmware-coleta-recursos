Connect-VIServer -server vcenter.seudominio.com

Clear-Host

#Nomeando as variaveis e comandos
########
$tabela = foreach($cluster in Get-Cluster){
$vms = $cluster | get-vm
$esx = $cluster | get-vmhost
$ds = Get-Datastore -VMHost $esx | Where-object {$_.Type -eq "VMFS"}
$datacenter=(Get-Datacenter -Cluster $cluster).Name
$N_hosts=($esx | Measure-Object -Line -Property Name).Lines
$P_Memory=($esx | Measure-Object -Property MemoryTotalGB -Sum).Sum
$U_Memory=($esx | Measure-Object -Property MemoryUsageGB -Sum).Sum
$A_Memory=($esx | Measure-Object -InputObject {$_.MemoryTotalGB - $_.MemoryUsageGB} -Sum).Sum
$VM_Memory=($vms | Measure-Object -Property MemoryGB -Sum).Sum
$U_CPU=($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum
$A_CPU=($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum
$P_CPU=($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum
$P_vCPU=($esx | Measure-Object -Property NumCpu -Sum).Sum
$VM_vCPU=($vms | Measure-Object -Property NumCpu -Sum).Sum
$P_disk=($ds | Where-object {$_.Type -eq "VMFS"} | Measure-Object -Property CapacityGB -Sum).Sum
$A_disk=($ds | Measure-Object -InputObject {$_.CapacityGB - $_.FreeSpaceGB} -Sum).Sum
$F_disk=($ds | Measure-Object -Property FreeSpaceGB -Sum).Sum
#
#Gerando tabela
########
$cluster | Select-Object @{N="Vcenter";E={$cluster.Uid.Split(':@')[1]}},
			@{N="Datacenter";E={$datacenter}},
			@{N="Cluster";E={$cluster.Name}},
			@{N="Number Hosts";E={$N_hosts}},
			@{N="Total Physical Memory (GB)";E={$P_Memory}},
			@{N="Usege Memory (GB)";E={$U_Memory}},
			@{N="Available Memroy (GB)";E={$A_Memory}},
			@{N="Total Memory Configured VMs";E={$VM_Memory}},
			@{N="Configured CPU (Mhz)";E={$U_CPU}},
			@{N="Available CPU (Mhz)";E={$A_CPU}},
			@{N="Total CPU (Mhz)";E={$P_CPU}},
			@{N="Total vCPU";E={$P_vCPU}},
			@{N="Total vCPU Configured VMs";E={$VM_vCPU}},
			@{N="Total Disk Space (GB)";E={$P_disk}},
			@{N="Configured Disk Space (GB)";E={$A_disk}},
			@{N="Available Disk Space (GB)";E={$F_disk}}
}
#
foreach($cluster in Get-Cluster) {
$vms = $cluster | get-vm
$esx = $cluster | get-vmhost
$ds = Get-Datastore -VMHost $esx | Where-object {$_.Type -eq "VMFS"}
$datacenter=(Get-Datacenter -Cluster $cluster).Name
$N_hosts=($esx | Measure-Object -Line -Property Name).Lines
$P_Memory=($esx | Measure-Object -Property MemoryTotalGB -Sum).Sum
$U_Memory=($esx | Measure-Object -Property MemoryUsageGB -Sum).Sum
$A_Memory=($esx | Measure-Object -InputObject {$_.MemoryTotalGB - $_.MemoryUsageGB} -Sum).Sum
$VM_Memory=($vms | Measure-Object -Property MemoryGB -Sum).Sum
$U_CPU=($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum
$A_CPU=($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum
$P_CPU=($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum
$P_vCPU=($esx | Measure-Object -Property NumCpu -Sum).Sum
$VM_vCPU=($vms | Measure-Object -Property NumCpu -Sum).Sum
$P_disk=($ds | Where-Object {$_.Type -eq "VMFS"} | Measure-Object -Property CapacityGB -Sum).Sum
$A_disk=($ds | Measure-Object -InputObject {$_.CapacityGB - $_.FreeSpaceGB} -Sum).Sum
$F_disk=($ds | Measure-Object -Property FreeSpaceGB -Sum).Sum
$D_host=($P_Memory - $VM_Memory)/256
#
#$cluster | Select-Object @{N=$cluster.Name;E={$D_host}}
}
#Exportando dados para CSV
########
$path = "c:\temp"		
if (!(Test-Path -Path $path)) {New-Item -Path $path -ItemType Directory | Out-Null}
$tabela | Export-Csv -Path $path\vmware_dados.csv -Delimiter ";"
