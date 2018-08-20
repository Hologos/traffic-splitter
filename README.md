# Traffic splitter

traffic-splitter alters the routing table and enables you to route some traffic via a defined network interface.

# Usage

```
# route some traffic via interface en0, the rest via interface en2
sudo traffic-splitter -d en2 -t en0
```

# Disclaimer

This version of the script works only for macOS (formely OS X) and was tested only for IPv4 (support for IPv6 is planned).
