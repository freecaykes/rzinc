## Build

1. Compile to binary

```shell
zig build-exe main.zig -o rzinc
```

2. Installing the build as a service

``` shell
sudo install -m 755 <path-to-binary> /usr/local/bin/
```

## Running the Service using systemd
Using the 

```shel
# Reload systemd to recognize new service
sudo systemctl daemon-reload

# Start the service
sudo systemctl start rzinc

# Enable service to start on boot
sudo systemctl enable rzinc

# Check service status
sudo systemctl status rzinc

# Stop the service
sudo systemctl stop rzinc
```