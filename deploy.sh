#!/bin/bash
echo "================================================================"
echo "请确保ipa已在当前目录下"
echo "注意⚠️: 一次只能部署一种环境，请不要放多个ipa到当前目录下"
echo "================================================================"
# release_version=`/usr/libexec/PlistBuddy -c 'Print :items:0:metadata:bundle-version' ./manifest.plist`
# debug_version=`/usr/libexec/PlistBuddy -c 'Print :items:0:metadata:bundle-version' ./manifest_test.plist`

read -p "部署Release环境（y/n）:      " env
if [[ -n "$env" ]]; then
	 if [[ "$env"="y" ]]; then
	 	echo "******************************"
	 	echo "已选择Release环境"
	 	echo "******************************"
	 else
	 	echo "******************************"
	 	echo "已选择Debug环境"
	 	echo "******************************"
	 fi
else
	echo "******************************"
	echo "默认为Release环境"
	echo "******************************"
	env="y"
fi

read -p "版本号(版本号为必填项): " version
if [[ -n "$version" ]]; then
	echo "${version}"
else
 	echo "版本号不可为空!!!"
 	exit 1
fi

read -p "应用的BundleId(不填写则默认不修改): " bundleId
if [[ -n "$bundleId" ]]; then
	echo "${bundleId}"
else
  	if [[ "$env" = "y" ]]; then
  	  bundleId=`/usr/libexec/PlistBuddy -c 'Print :items:0:metadata:bundle-identifier' ./manifest.plist`
  	else
  	  bundleId=`/usr/libexec/PlistBuddy -c 'Print :items:0:metadata:bundle-identifier' ./manifest_test.plist`
 	fi
fi

read -p "部署版本描述信息: " commit_message
if [[ -n "$commit_message" ]]; then
	echo "$commit_message"
else
	commit_message="🚀update~"
fi
 
 
if [[ "$env" = "y" ]]; then
  /usr/libexec/PlistBuddy -c 'Set :items:0:metadata:bundle-version "$version"' ./manifest.plist
  /usr/libexec/PlistBuddy -c 'Set :items:0:metadata:bundle-identifier string "$bundleId"' ./manifest.plist
  sudo cp -f ./*ipa  /Library/WebServer/Documents/app/ipa/release/app.ipa
else
  /usr/libexec/PlistBuddy -c 'Set :items:0:metadata:bundle-version "$version"' ./manifest_test.plist
  /usr/libexec/PlistBuddy -c 'Set :items:0:metadata:bundle-identifier string "$bundleId"' ./manifest_test.plist
  sudo cp -f ./*ipa  /Library/WebServer/Documents/app/ipa/debug/app.ipa
fi

echo "🎉🎉🎉 部署成功！！！"

rm -rf *.ipa #移除记录 

echo "🚀🚀🚀提交代码"

git add .
git commit -am  "$commit_message"
git push origin master 
