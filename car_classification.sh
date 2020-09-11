#!/bin/bash
set -x

Density=${1:-1}
interval=${2:-1}
Extra_hw_frame=${3:-1}
Dnireq=${4:-1}
Cnireq=${5:-1}


rm -rf output
mkdir output

input_file=/root/intel_models/iss_stream/car-detection_1920_1080_2min.mp4
detect_file=/root/intel_models/dldt_models_2019R3/ISS_FP16_models_1.1/car_classification/vehicle-detection-adas-0002.xml
classify_file=/root/intel_models/dldt_models_2019R3/ISS_FP16_models_1.1/car_classification/vehicle-attributes-recognition-barrier-0039.xml
proc_file=/root/intel_models/FFmpeg-patch/samples/model_proc/vehicle-attributes-recognition-barrier-0039.json
#proc_file=/root/intel_models/FFmpeg-patch/samples/model_proc16/vehicle-attributes-recognition-barrier-0039.json

for((i=1;i<=${Density};i++)); do
    ## -f iemetadata
    ffmpeg -profiling_all -flags unaligned \
           -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device /dev/dri/renderD128 \
           -extra_hw_frames ${Extra_hw_frame} -threads 1 \
           -i ${input_file} \
           -vf "detect=model=${detect_file}:interval=${interval}:device=HDDL:nireq=${Dnireq},classify=model=${classify_file}:model_proc=${proc_file}:device=HDDL:nireq=${Cnireq}:interval=${interval}" \
           -an -y output/out${i}.json &

done
wait
