#!/bin/bash

set -ouex pipefail

# ----------------------------
# Kiosk user (public session)
# ----------------------------
useradd -u 1000 -m -s /bin/bash -c "Bruger" guest

# Passwordless login (required for auto-login setups)
passwd -d guest