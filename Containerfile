# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /build_files
COPY features /features
COPY system_files /system_files

# Base Image
FROM ghcr.io/ublue-os/kinoite-main:latest

### 1. DISTRIBUTE SYSTEM FILES
# Merges all 'system_files' directories across all features directly into the OS root
COPY --from=ctx /system_files/ /
#COPY --from=ctx /features/*/system_files/ /


### 2. MODIFICATIONS & BUILD LOOP
# Discovers all build scripts, strips the path to sort strictly by filename numbers,
# and executes them in perfect sequential order (05, 10, 15, 16, 21, 30, etc.)
RUN --mount=type=bind,from=ctx,source=/features,target=/tmp/features \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    find /tmp/features/ -type f -path "*/build_files/*.sh" | awk -F/ '{print $NF, $0}' | sort -n | cut -d' ' -f2- | while read -r script; do \
        echo "🚀 Running feature script: $(basename "$script")"; \
        bash "$script" || exit 1; \
    done


### 3. GLOBAL ENVIRONMENT & PERMISSIONS ENFORCEMENTS
# Set timezone to Copenhagen
RUN ln -sf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime && \
    echo "Europe/Copenhagen" > /etc/timezone

# Uniformly enforce executable permissions on all target shell and python scripts
RUN chmod 755 /usr/libexec/*.sh /usr/libexec/*.py 2>/dev/null || true


### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

# Compile dconf configurations
RUN dconf update

    
### 4. LINTING
# Verify final bootc image and contents are correct
RUN bootc container lint