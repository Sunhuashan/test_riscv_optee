nc -z 127.0.0.1 54320 || /usr/bin/gnome-terminal -x ./soc_term.py 54320 &
nc -z 127.0.0.1 54321 || /usr/bin/gnome-terminal -x ./soc_term.py 54321 &
while ! nc -z 127.0.0.1 54320 || ! nc -z 127.0.0.1 54321; do sleep 1; done
./qemu/build/qemu-system-riscv64 -d guest_errors -D guest_log.txt \
    -M virt,pflash0=pflash0,aia=aplic-imsic,acpi=off,hmat=on,rpmi=on \
    -dtb ./qemu-virt-new.dtb \
    -m 4G,slots=2,maxmem=8G -object memory-backend-ram,size=2G,id=m0 -object memory-backend-ram,size=2G,id=m1 \
    -numa node,nodeid=0,memdev=m0 -numa node,nodeid=1,memdev=m1 -smp 2,sockets=2,maxcpus=2 \
    -bios ./fw_dynamic.elf \
    -device loader,file=tee-pager_v2.bin,addr=0xF0C00000 \
    -blockdev node-name=pflash0,driver=file,read-only=on,filename=./u-boot.bin \
    -serial tcp:localhost:54320 -serial tcp:localhost:54321 \
    -drive file=fat:rw:~/src/fat,id=hd0 -device virtio-blk-device,drive=hd0 \
    -nographic -device virtio-net-pci,netdev=usernet -netdev user,id=usernet,hostfwd=tcp::9990-:22
