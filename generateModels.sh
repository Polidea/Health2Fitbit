#!/bin/sh
modelPath=./Health2Fitbit/Model
mogenerator --v2 --template-var modules=false --model $modelPath/Health2Fitbit.xcdatamodel/ --machine-dir $modelPath/Entities/MachineGenerated/ --human-dir $modelPath/Entities
