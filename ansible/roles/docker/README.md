Docker role

This role installs Docker Engine on Debian/RedHat based systems and adds the deploy user to the docker group.

Usage
- Include `- role: docker` in your playbook for hosts that should run containers.

Notes
- For Debian/Ubuntu the role adds the official Docker apt repository. Ensure `ansible_lsb` facts are available (package `lsb-release`).
- You may need to run the playbook twice the first time on Debian/Ubuntu to pick up the new repo before installing docker packages.
