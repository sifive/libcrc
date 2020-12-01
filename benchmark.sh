#!/bin/bash

TOOLCHAIN=/scratch/evanl/tools/toolchain/riscv64-unknown-elf-gcc-10.2.0-2020.12.0-preview2-rvb-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc
BASE_FLAG="-Os -ffunction-sections -fdata-sections -msave-restore -Wl,--gc-section"

function build_bench {

orig_arch_opt=$1
outputdir=$2

for a_build in orig zbs zba_zbb_zbs;
do
    arch_opt=$orig_arch_opt
    if [ "$a_build" == "orig" ];then
        arch_str=""
    else
        arch_str="_${a_build}"
    fi
  
    arch_opt=`echo $arch_opt |sed "s/\(rv[0-9][0-9][a-z]*\) \(.*\)/\1${arch_str} \2/g"`

    build_dir="$outputdir/${a_build}"
    log_dir="$build_dir/log"
    mkdir -p $build_dir

    OPT_FLAGS="$BASE_FLAG $arch_opt"
    make clean && make all CC=$TOOLCHAIN XCFLAGS="$OPT_FLAGS" |& tee $log_dir
    cp -r ./lib ${build_dir}
    size -t ${build_dir}/lib/libcrc.a &> ${build_dir}/size.txt

done
}

outputbase="./bench_output"
rm -rf $outputdir
mkdir -p $outputdir
build_bench "-march=rv32gc -mabi=ilp32d" "$outputbase/bench_output_32gc"
build_bench "-march=rv64gc -mabi=lp64d" "$outputbase/bench_output_64gc"
build_bench "-march=rv32imac -mabi=ilp32" "$outputbase/bench_output_32imac"
build_bench "-march=rv64imac -mabi=lp64" "$outputbase/bench_output_32imac"
