# Photo Organizer
Photo Organizer包含适用于Windows/macOS/Linux的脚本与针对macOS的桌面端程序，旨在帮助分类照片文件夹中的照片。
## Photo Organizer Bash与Photo Organizer PowerShell
如果使用的是Windows操作系统，请使用PO Powershell，反之，则使用PO Bash
### 功能
#### 按拍摄日期整理
根据拍摄日期创建文件夹，并将照片移动到相应的日期文件夹中。
#### 按文件格式整理
根据文件格式（JPG、ARW 等）将照片移动到不同的文件夹中。
### 如何使用
#### PO Bash
1. 将 `photo_organizer.sh` 文件复制到包含您照片的文件夹中。
2. 在终端中导航到该文件夹。
```
cd 路径
```
3. 运行以下命令：
```
./photo_organizer.sh
```
4. 根据提示选择整理方式（输入1或2），并按照指示操作即可。
#### PO PowerShell
1. 将 `photo_organizer.sh` 文件复制到包含您照片的文件夹中。
2. 运行PowerShell脚本
3. 根据提示选择整理方式（输入1或2），并按照指示操作即可。
### 注意事项
- 确保放置该脚本的文件夹中包含要整理的照片。
- 脚本仅支持处理以下常见的照片格式：JPG、ARW、NEF、ORF、RW2、RAF 和 DNG，如果需要处理其他格式的文件或指定不同的目录，请参考脚本中的参数化部分，并相应修改。
- 请注意，针对PO Bash的用户，您可能需要给予执行权限
```
cd 路径
chmod +x photo_organizer.sh
```
### 系统要求
- Windows Server 2008、Windows 7及更高的操作系统
- Mac OS X Tiger 10.4及更高的操作系统
- Linux
- 其他任何支持Bash的操作系统
### 故障排除
1.	找不到照片文件/No photo files found：
确保您运行脚本的文件夹中包含您要整理的照片文件。如果文件夹中确实有照片文件，但脚本仍然无法找到，请检查文件名是否正确或文件权限是否设置正确。
2.	创建目录失败/Error: Failed to create directory：
这可能是由于文件系统权限问题导致的。请确保您对目录具有写入权限。您还可以尝试手动创建目录以查看是否存在其他问题。
3.	移动文件失败/Error: Failed to move file：
这可能是由于文件系统权限问题或文件被其他进程占用导致的。请确保您对目标文件夹具有写入权限，并且文件没有被其他程序锁定。您可以尝试手动移动文件以排除问题。
4.	输入无效选项/Invalid option. Please select again：
这是因为用户输入了无效的选项。请按照脚本提供的选项进行选择，并确保输入的选项是 1、2 或 3。检查输入是否有误并重新输入正确的选项。
5.	未安装必要的工具/command not found：
这可能是由于您的系统缺少所需的工具或环境变量配置不正确所致。请确保您的系统上安装了 Bash 或其他所需的 Unix 工具，或者尝试在另一台系统上运行脚本。
### 已知问题
我们发现撤回操作可能无法完全执行
### 以后的开发计划
#### 代码优化
优化“撤销上一次操作”

## Photo Organizer Desktop
我们正在开发适用于macOS的Photo Organizer桌面应用程序，以支持在macOS中以图形化的方式高效整理照片
<img width="1012" alt="Photo Organizer V1 7 0" src="https://github.com/user-attachments/assets/26bdc106-35dd-4b85-af6e-bb662a29b37f">
### 功能
#### 按拍摄日期整理
根据拍摄日期创建文件夹，并将照片移动到相应的日期文件夹中。
#### 按文件格式整理
根据文件格式（JPG、ARW 等）将照片移动到不同的文件夹中。
#### 按元数据整理（开发中）
根据照片元数据中的相机、镜头或位置信息将照片移动到不同的文件夹中。
#### 接力
允许在不同的设备上继续工作
### 系统要求
- macOS Ventura 13.5及更高的操作系统
### 以后的开发计划
#### 用户界面
构建一个成熟且易于操作的UI✅，使程序支持深色模式✅，尽快翻译到English✅与Français
#### 操作
支持照片预览✅、查看元数据、对比，勾选特定的照片以进行手动筛选；允许设置默认目录
#### 功能
添加帮助文档、关于✅、设置✅
