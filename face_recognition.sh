#!/bin/bash
set -x

Density=${1:-1}
interval=${2:-1}
Extra_hw_frames=${3:-1}
Dnireq=${4:-1}
Cnireq=${5:-1}

input_file=/root/intel_models/iss_stream/face-demographics-walking_2min.mp4
detect_file=/root/intel_models/dldt_models_2019R3/ISS_FP16_models_1.1/face_recognition/face-detection-adas-0001.xml
classify_file=/root/intel_models/dldt_models_2019R3/ISS_FP16_models_1.1/face_recognition/face-reidentification-retail-0095.xml
proc_file=/root/intel_models/FFmpeg-patch/samples/model_proc/face-reidentification-retail-0095.json
#proc_file=/root/intel_models/FFmpeg-patch/samples/model_proc16/face-reidentification-retail-0095.json
id_file=/root/intel_models/FFmpeg-patch/samples/shell/reidentification/gallery/gallery.json


rm -rf output
mkdir output

for((i=1;i<=${Density};i++)); do
    ## -f iemetadata
    ffmpeg -profiling_all -flags unaligned \
           -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device /dev/dri/renderD128 \
           -extra_hw_frames ${Extra_hw_frames} \
           -threads 1 \
           -i ${input_file} -vf "detect=model=${detect_file}:interval=${interval}:device=HDDL:nireq=${Dnireq},classify=model=${classify_file}:model_proc=${proc_file}:device=HDDL:nireq=${Cnireq}:interval=${interval},identify=gallery=${id_file}" \
           -an -y output/out${i}.json &

done
wait
