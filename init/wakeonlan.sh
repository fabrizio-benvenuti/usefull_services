#!/bin/bash

# Loop until Wake-on-LAN is enabled on configuration "g"
while ! ethtool enp2s0 | grep -q "Wake-on: g"; do
  echo "Setting Wake-on-LAN on enp2s0 to 'g' configuration..."
  sudo ethtool -s enp2s0 wol g
  echo "Wake-on-LAN has been enabled on enp2s0."
  sleep 1 # Optional: Add a delay between each check
done

echo "Wake-on-LAN is already enabled on enp2s0 with configuration 'g'."

