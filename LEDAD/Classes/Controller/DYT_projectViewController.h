//
//  DYT_projectViewController.h
//  LEDAD
//
//  Created by laidiya on 15/9/10.
//  Copyright (c) 2015年 yxm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocketReceivePlayerBroadcastIp.h"
#import "AsyncUdpSocketReceivePlayerBroadcastIp.h"
#import "AsyncUdpSocketReceiveUpgradeTranscationBroadcastIp.h"

#import "CTMasterViewController.h"
#import "Config.h"
#import "Common.h"

#import "MyProjectListViewController.h"
#import "XMLDictionary.h"
#import "LayoutYXMViewController.h"
#import "DYT_FTPmodel.h"
#import "AGAlertViewWithProgressbar.h"
@protocol projectview <NSObject>

-(void)showmovview:(NSMutableArray *)array;
-(void)showwifl;
-(void)showProgram;
-(void)showsj;
-(void)showpicview:(ALAsset *)asset;
-(void)shownearfutureview:(NSArray *)array andname:(NSArray *)name;
-(void)showuploadprojectview;
-(void)showAstepUpload:(NSMutableArray *)array;
-(void)showLED;
@end

@interface DYT_projectViewController : UIViewController<MyProjectListSelectDelegate,SelectPhotoDelegate,UploadResultDelegate>
{

    
         BOOL isgaiming;
    
//       ftp管理对象
        YXM_FTPManager *_ftpMgr;
        //上传的文件的长度
        long long _sendFileCountSize;
    
    UILabel *headlabel;
    //项目列表
    MyProjectListViewController *_myProjectCtrl;
    //总素材列表,也就是带使用的元器件的列表
    
    CTMasterViewController *myMasterCtrl;
    
    
    //    是否在播放
    BOOL isPlay;
    //当前项目所需要发送到服务端的文件列表
    NSMutableArray *_waitForUploadFilesArray;
    //当前播放的项目对象
    ProjectListObject *currentPlayProObject;
    //当前播放项目的文件名字
    NSString *_currentPlayProjectFilename;
    
    //当前播放项目名字
    NSString *_currentPlayProjectName;
    //当前选中的项目的索引
    NSIndexPath *_currentPlayProjIndex;
    //当前项目所在路径
    NSString *_currentProjectPathRoot;
    
    //音乐的路径
    NSString *_musicFilePath;
    //音乐的音量
    NSString *_musicVolume;
    
    //项目素材字典,按照区域编号去索引区域内的素材列表
    NSMutableDictionary *_projectMaterialDictionary;
    
    
    
    UIButton *buttonaddproject;
    UIButton *buttonaddgoup;
    
    
    BOOL showtableview;
    BOOL showscreentableview;
    DYT_FTPmodel *ftpmodel;

}
-(void)selfreloadview;

-(void)setloadview;
@property(nonatomic,strong)id<projectview>mydelegate;
@property (nonatomic,strong) AGAlertViewWithProgressbar *alertViewWithProgressbar;

@end
