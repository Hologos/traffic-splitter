# Traffic splitter

traffic-splitter alters the routing table and enables you to route some traffic via a defined network interface.

## Dependencies

First, make sure you have all those things installed (at least the system ones):

- `python3`: to be able to parse yaml config files

## Installation

This script requires PyYAML to be installed. You can install it with:

```
pip3 install PyYAML
```

## Usage

```
# route some traffic via interface en0, the rest via interface en2
sudo traffic-splitter -r -c config.test.yml -t en0 -d en2
```

![](documentation/traffic-splitter.showoff.gif)

## Disclaimer

This version of the script works only for macOS (formely OS X) and was tested only for IPv4 (support for IPv6 is planned).
