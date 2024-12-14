#!/usr/sbin/nft -f  
  
flush ruleset  
  
table inet filter {  
   chain input {  
      type filter hook input priority 0; policy drop;  
       
      # Allow loopback  
      iifname "lo" accept  
       
      # Allow established connections  
      ct state established,related accept  
       
      # Allow WireGuard interface  
      iifname "wg0" accept  
       
      # Allow DHCP  
      udp dport { 67, 68 } accept  
   }  
  
   chain forward {  
      type filter hook forward priority 0; policy drop;  
   }  
  
   chain output {  
      type filter hook output priority 0; policy drop;  
       
      # Allow loopback  
      oifname "lo" accept  
       
      # Allow established  
      ct state established,related accept  
       
      # Allow WireGuard interface  
      oifname "wg0" accept  
       
      # Allow DNS  
      udp dport 53 accept  
      tcp dport 53 accept  
       
      # Allow WireGuard connection  
      udp dport <WIREGUARD_PORT> ip daddr <WIREGUARD_SERVER_IP> accept  
   }  
}

