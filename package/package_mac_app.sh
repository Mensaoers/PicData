#配置变量
target_dir="package/build_app"
target_plist="package/ExportOptions_app.plist"

target_name="PicData"
xcarchiveName="${target_name}.xcarchive"
app_name="${target_name}.app"

#当前目录
currunt_dir=$(pwd)
echo -e "\033[31m 当前目录：${currunt_dir} \033[0m"

rm -rf ${currunt_dir}/${target_dir}/${app_name}
rm -rf ${currunt_dir}/${target_dir}/${xcarchiveName}

#打包
parent_dir=$(dirname $(pwd))
echo -e "\033[31m 父目录：${parent_dir} \033[0m"
xcodebuild archive -workspace ${currunt_dir}/${target_name}/${target_name}.xcworkspace -scheme ${target_name} -configuration Release -destination "platform=macOS,arch=x86_64,variant=Mac Catalyst" -archivePath ${currunt_dir}/${target_dir}/${target_name}.xcarchive 

if test $? -eq 0
     then

        xcodebuild -exportArchive -archivePath ${currunt_dir}/${target_dir}/${target_name}.xcarchive -exportPath ${target_dir} -exportOptionsPlist ${target_plist}

        appPath=${currunt_dir}/${target_dir}/${target_name}.app
        echo -e "\033[31m app path : ${appPath}\033[0m"

        open ${currunt_dir}/${target_dir}
    else
        echo -e "\033[31m 打包失败 \033[0m"
        exit -1
     fi

