#!/bin/bash
set -x

density=${1:-1}
interval=${2:-1}
Extra_hw_frames=${3:-13}
Nireq=${4:-6}

input_file=/root/intel_models/iss_stream/person-bicycle-car-detection_1920_1080_2min.mp4
model_file=/root/intel_models/dldt_models_2019R3/ISS_FP16_models_1.1/object_detection/mobilenet-ssd.xml
proc_file=/root/intel_models/FFmpeg-patch/samples/model_proc/mobilenet-ssd.json
#proc_file=/root/intel_models/FFmpeg-patch/samples/model_proc16/mobilenet-ssd.json

rm -rf output
mkdir output

for((i=1;i<=${density};i++)); do

    ## -f iemetadata
    ffmpeg -profiling_all -flags unaligned \
           -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device /dev/dri/renderD128 \
           -extra_hw_frames ${Extra_hw_frames} -threads 1 \
           -i ${input_file} \
           -vf "detect=model=${model_file}:model_proc=${proc_file}:device=HDDL:nireq=${Nireq}:interval=${interval}" \
           -an \
           -y output/out${i}.json &

done
wait
