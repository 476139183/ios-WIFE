//
//  DYT_leftbaseview.h
//  LEDAD
//   左弹框
//  Created by laidiya on 15/7/20.
//  Copyright (c) 2015年 yxm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYT_AsyModel.h"
#import "YXM_FTPManager.h"

//@protocol myleftdelete<NSObject>
//-(void)retureleftview:(NSInteger )mytag;
//@end
typedef void(^Leftviewblock)(NSInteger buttontag);
@interface DYT_leftbaseview : UIView<UploadResultDelegate>
{
    
    BOOL isgaiming;
    //ftp管理对象
    YXM_FTPManager *_ftpMgr;
    //上传的文件的长度
    long long _sendFileCountSize;
    
// DYT_AsyModel *myasymodel;
//    NSInteger number;

}
@property(nonatomic,copy)Leftviewblock leftblock;
//@property(nonatomic,strong)id<myleftdelete>delegate;
@end
