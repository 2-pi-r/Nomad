#ygkakteh !/usr/bin/bash

cpu_num=16

while getopts ":c:" opt; do
	case $opt in
	c)
		echo "Running vm using ${OPTARG}"
		cpu_num=${OPTARG}
		;;
	:)
		echo "Error: option ${OPTARG} requires an argument"
		;;
	?)
		echo "Invalid option: ${OPTARG}"
		;;
	esac
done

shift $((OPTIND - 1))

echo "Remaining args are: <${@}>"

max_cpu_id=$(($cpu_num - 1))

memory_size=32G

disk=/home/eslab/nomad_vm/focal-server-cloudimg-amd64.img
net_script=/home/eslab/Nomad/src/vm_scripts/ifup.sh
# qemu_dir=/home/lingfeng/Documents/qemu-8.0.5/build

numa_cmd=""

if [ $cpu_num -lt 12 ]; then
	numa_cmd="numactl -N 0"
	echo ${numa_cmd}
fi

qemu-system-x86_64 \
	-cpu host \
	-gdb tcp::12346 \
	-smp ${cpu_num} \
	-object memory-backend-ram,size=${memory_size},id=m0 \
	-numa node,nodeid=0,memdev=m0,cpus=0-${max_cpu_id} \
	-machine accel=kvm,nvdimm=on \
	-m ${memory_size} \
	-device virtio-scsi-pci,id=scsi0 \
	-drive file=${disk},if=none,format=qcow2,discard=unmap,cache=writeback,id=base \
	-device scsi-hd,drive=base,bootindex=0,bus=scsi0.0 \
	-netdev user,id=vm0 -device virtio-net-pci,netdev=vm0 \
	-nographic
