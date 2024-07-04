## Power-EIP
Powershell module for EfficientIP SOLDIDServer
## Powershell module to provide CRUD functionality for EfficientIP SOLIDServer DNS
### Import Module and Connect to EfficientIP SOLIDServer
```
PS > Import-Module Power-EIP
PS > Connect-EIP -Hostname eip.local -Username ausername -DNSName smart.local -View external
```
### Create
```
PS > New-EIPDNSRecord -DNSRRRecordName "validate-testserver2-domain-net.exampledomain.net" -DNSRRRecordValue "a new value" -DNSRRRecordType TXT

ret_oid
-------
101010

PS >
```
### Read
```
PS > Get-EIPDNSRecordInfo -DNSRRRecordName "validate-testserver2-domain-net.exampledomain.net"

errno                                       : 0
rr_all_value                                : a new value
dnszone_sort_zone                           : exampledomain.net
dnszone_is_rpz                              : 0
dnszone_type                                : master
rr_full_name                                : validate-testserver2-domain-net.exampledomain.net
rr_full_name_utf                            : validate-testserver2-domain-net.exampledomain.net
rr_name_ip_addr                             :
rr_name_ip4_addr                            :
rr_value_ip_addr                            :
rr_value_ip4_addr                           :
rr_glue                                     : validate-testserver2-domain-net
rr_type                                     : TXT
ttl                                         : 3600
delayed_time                                : 0
rr_class_name                               :
value1                                      : a new value
value2                                      :
value3                                      :
value4                                      :
value5                                      :
value6                                      :
value7                                      :
dnszone_id                                  : 101
rr_id                                       : 101010
dns_id                                      : 2
dnszone_name_utf                            : exampledomain.net
dnszone_name                                : exampledomain.net
dns_name                                    : smart.local
dns_type                                    : vdns
dns_cloud                                   : 0
vdns_parent_id                              : 0
dnsview_name                                : external
dnsview_class_name                          :
dnsview_id                                  : 5
dnszone_site_name                           : #
dnszone_is_reverse                          : 0
dnszone_masters                             :
vdns_parent_name                            : #
dnszone_forwarders                          :
dns_class_name                              :
dnszone_class_name                          :
dns_version                                 :
dns_comment                                 :
delayed_create_time                         : 0
delayed_delete_time                         : 0
multistatus                                 :
rr_auth_gsstsig                             : 0
rr_last_update_time                         :
rr_last_update_days                         :
rr_name_id                                  : 11010
rr_value_id                                 : 11401
rr_type_id                                  : 4
rr_glue_id                                  : 1010
dnsview_class_parameters                    : ipam_replication=0&dnsptr=0
dnsview_class_parameters_properties         : ipam_replication=inherited,propagate&dnsptr=inherited,propagate
dnsview_class_parameters_inheritance_source : ipam_replication=real_dns,2&dnsptr=real_dns,2
rr_class_parameters                         :
rr_class_parameters_properties              :
rr_class_parameters_inheritance_source      :

PS >
```
### Update
```
PS > Update-EIPDNSRecord -DNSRRRecordName "validate-testserver2-domain-net.exampledomain.net" -DNSRRRecordValue "updated-example-value"

ret_oid
-------
101010

PS > 
```
### Delete
```
PS > Remove-EIPDNSRecord -DNSRRRecordName "validate-testserver2-domain-net.exampledomain.net"

ret_oid
-------
101010

PS >
```
### Commands
```
PS > Get-Command -Module Power-EIP

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Connect-EIP                                        1.0.0.0    Power-EIP
Function        Get-EIPDNSRecordID                                 1.0.0.0    Power-EIP
Function        Get-EIPDNSRecordInfo                               1.0.0.0    Power-EIP
Function        New-EIPDNSRecord                                   1.0.0.0    Power-EIP
Function        Remove-EIPDNSRecord                                1.0.0.0    Power-EIP
Function        Send-EfficientIPRequest                            1.0.0.0    Power-EIP
Function        Update-EIPDNSRecord                                1.0.0.0    Power-EIP
```
