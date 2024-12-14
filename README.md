# Create nftables rules at /etc/nftables.conf to implement killswitch
# Change <WIREGUARD_PORT> and <WIREGUARD_SERVER_IP>

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
      udp dport <WIREGUARD_PORT> daddr <WIREGUARD_SERVER_IP> accept  
   }  
}

# Enable and start nftables service
sudo systemctl enable nftables  
sudo systemctl start nftables

# Check nft rulesets
sudo nft list ruleset

# Create systemd serviced to start at boot
# Wireguard config file must be called wg0 and located in /etc/wireguard
sudo systemctl enable wg-quick@wg0.service  
sudo systemctl start wg-quick@wg0.service
sudo systemctl status wg-quick@wg0.service

# Ensure wg0 is bought up only after network is available
sudo systemctl edit wg-quick@wg0.service

[Unit]  
After=network-online.target NetworkManager-wait-online.service  
Wants=network-online.target  
  
[Service]  
Type=oneshot  
RemainAfterExit=yes

sudo systemctl daemon-reload  
sudo systemctl restart wg-quick@wg0.service

# To troubleshoot
journalctl -u wg-quick@wg0.service
