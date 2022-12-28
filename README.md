# cloud-init
cloud-init is a software package that automates the initialization of cloud instances during system boot. 
You can configure cloud-init to perform a variety of tasks.

# what is Qemu 

Qemu is a cross-platform emulator capable of running performant virtual machines. Qemu is used at the core of a broad range of production operating system deployments and open source software projects (including libvirt, LXD, and vagrant) and is capable of running Windows, Linux, and Unix guest operating systems. While Qemu is flexibile and feature-rich, we are using it because of the broad support it has due to its broad adoption and ability to run on *nix-derived operating systems.

# qemu-img command
qemu-img allows you to create, convert and modify images offline. It can handle all image formats supported by QEMU.

Warning: Never use qemu-img to modify images in use by a running virtual machine or any other process; this may destroy the image. Also, be aware that querying an image that is being modified by another process may encounter inconsistent state.



