#!/bin/sh

#要build的target名
project_path=$(cd `dirname $0`; pwd)
project_name="${project_path##*/}"
TARGET_NAME=${project_name}
echo "\033[31m target name = ${TARGET_NAME} \033[0m"
# sdk 编译过程的输出文件路径
WRK_DIR=./build

if [[ $1 ]]
then
TARGET_NAME=$1
fi
currunt_dir=$(pwd)
UNIVERSAL_OUTPUT_FOLDER="${currunt_dir}/Products"

echo "\033[31m current path = ${currunt_dir} \033[0m"

#创建输出目录，并删除之前的framework文件
mkdir -p "${UNIVERSAL_OUTPUT_FOLDER}"

# bundle

BUNDLE_NAME=${TARGET_NAME} #"Resource"
BUNDLE_FILENAME=${BUNDLE_NAME}".bundle"

# 真机 bundle 输出文件路径
BUNDLE_DEVICE_DIR=${WRK_DIR}/Release/${BUNDLE_NAME}.bundle

echo "BUNDLE_DEVICE_DIR: ${BUNDLE_DEVICE_DIR}"

# 编译资源文件bundle
xcodebuild -configuration "Release" -target "${BUNDLE_NAME}" -sdk macosx build -UseModernBuildSystem=NO
 
# 最终 资源文件 输出的文件路径
BUNDLE_INSTALL_DIR=${UNIVERSAL_OUTPUT_FOLDER}/${BUNDLE_FILENAME}
echo "BUNDLE_INSTALL_DIR: ${BUNDLE_INSTALL_DIR}"
# 清理之前生成的 sdk
if [ -d "${BUNDLE_INSTALL_DIR}" ]
then
rm -rf "${BUNDLE_INSTALL_DIR}"
fi
# 移动一个 budle 到 资源文件输出路径中
cp -LR "${BUNDLE_DEVICE_DIR}" "${BUNDLE_INSTALL_DIR}"

#打开合并后的文件夹
echo "\033[31m open framework folder ... \033[0m"
open "${UNIVERSAL_OUTPUT_FOLDER}"