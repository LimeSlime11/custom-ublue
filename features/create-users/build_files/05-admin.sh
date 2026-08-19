#!/bin/bash

set -ouex pipefail

# ----------------------------
# Admin user (maintenance)
# ----------------------------
useradd -u 1001 -m -s /bin/bash -G wheel -c "Super User" admin
echo "admin:admin" | chpasswd

# Give explicit passwordless sudo access for development convenience
cat > /etc/sudoers.d/admin <<EOF
admin ALL=(ALL) NOPASSWD: ALL
EOF

chmod 0440 /etc/sudoers.d/admin