
 
#define MAX_PICKER_SELECT 20

#import "CTMasterViewController.h"
#import "MyPlayListViewController.h"
#import "YXM_MasterTableViewCell.h"
#import "LayoutYXMViewController.h"
#import "Config.h"



@interface CTMasterViewController () <UINavigationControllerDelegate, CTAssetsPickerControllerDelegate,UploadResultDelegate>

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end



@implementation CTMasterViewController
@synthesize delegate;
@synthesize sAssetType = _sAssetType;
@synthesize iAssetMaxSelect = _iAssetMaxSelect;
- (void)viewDidAppear:(BOOL)animated
{
//    [self.tableView setFrame:CGRectMake(10, 10, 1, 1)];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)uploadWriteData:(NSInteger)writeDataLength{
    _sendFileCountSize += writeDataLength;
    float progressValue = _sendFileCountSize*1.00f / _uploadFileTotalSize*1.00f;
    [myMRProgressView setProgress:progressValue animated:YES];

    [myMRProgressView setTitleLabelText:[NSString stringWithFormat:@"%@ %0.0lf％",[Config DPLocalizedString:@"adedit_publishprojecting"],progressValue*100]];
}
-(void)uploadResultInfo:(NSString *)sInfo{

    if (back) {
        back=NO;
        if (!isConnect) {
            [self startSocket];
        }
        [self commandResetServerWithType:0x17 andContent:nil andContentLength:0];
    }
    DLog(@"sInfo = %@",sInfo);
}
-(void)commandResetServerWithType:(Byte)commandType andContent:(Byte[])contentBytes andContentLength:(NSInteger)contentLength
{
    int byteLength = 6;
    Byte outdate[byteLength];
    memset(outdate, 0x00, byteLength);
    outdate[0]=0x7D;
    outdate[1]=commandType;//命令类型
    outdate[2]=0x00; /*命令执行与状态检查2：获取服务器端的数据*/
    outdate[byteLength-3]=(Byte)byteLength;
    outdate[byteLength-2]=(Byte)(byteLength>>8);
    //计算校验码
    int sumByte = 0;
    for (int j=0; j<(byteLength-1); j++) {
        sumByte += outdate[j];
    }
    //校验码计算（包头到校验码前所有字段求和取反+1）
    outdate[(byteLength-1)]=~(sumByte)+1;
    long tag = outdate[1];
    DLog(@"恢复默认列表 = %d",(int)commandType);
    NSData *udpPacketData = [[NSData alloc] initWithBytes:outdate length:byteLength];
    DLog(@"udpPacketData=======%@",udpPacketData);
    [_sendPlayerSocket writeData:udpPacketData withTimeout:-1 tag:tag];
}
-(void)startSocket{
    if (!_sendPlayerSocket) {
        _sendPlayerSocket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    DLog(@"ipAddressString = %@",ipAddressString);
    if (ipAddressString) {
        DLog(@"ipaddress = %@",ipAddressString);
        if (!isConnect) {
            isConnect = [_sendPlayerSocket connectToHost:ipAddressString onPort:PORT_OF_TRANSCATION_PLAY error:nil];
            [_sendPlayerSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
            if (!isConnect) {
                DLog(@"连接失败");
            }else{
                DLog(@"连接成功");
            }
        }
    }else{
        isConnect = NO;
        DLog(@"ipaddress is null");
    }

    //初始化数据仓库
    if (!_currentDataArray) {
        _currentDataArray = [[NSMutableArray alloc]init];
    }


    //发送索引
    _currentDataAreaIndex = 0;
}
- (void)clearAssets:(id)sender
{
    if (self.assets)
    {
        [self.assets removeAllObjects];
        [self.tableView reloadData];
        
    }
}

- (void)pickAssets:(id)sender
{
    if (!self.assets)
    {
        self.assets = [[NSMutableArray alloc] init];
    }

    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    if ([self.sAssetType isEqualToString:ASSET_TYPE_PHOTO]) {
        picker.assetsFilter         = [ALAssetsFilter allPhotos];
    }
    if ([self.sAssetType isEqualToString:ASSET_TYPE_VIDEO]) {
        picker.assetsFilter         = [ALAssetsFilter allVideos];
    }
    picker.delegate             = self;

    
    // iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:picker];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    }
    else
    {
        [self presentViewController:picker animated:YES completion:nil];
    }

}
#pragma mark - Popover Controller Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}

#pragma mark - Table View

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assets.count;
}
-(void)ftpuser{
    if (!_ftpMgr) {
        //连接ftp服务器
        _ftpMgr = [[YXM_FTPManager alloc]init];
        _ftpMgr.delegate = self;
    }
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* sZipPath =[NSString stringWithFormat:@"%@/warty-final-ubuntu.png",DocumentsPath];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSDictionary * dict = [fileMgr attributesOfItemAtPath:sZipPath error:nil];
    //方法一:
    NSLog(@"size = %lld",[dict fileSize]);

    
   
    
    
    NSString *sUploadUrl = [[NSString alloc]initWithFormat:@"ftp://%@:21",ipAddressString];
    [_ftpMgr startUploadFileWithAccountqq:@"ftpuser" andPassword:@"ftpuser" andUrl:sUploadUrl andFilePath:sZipPath];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *sIdentifier = @"YXM_MasterTableViewCell";
        YXM_MasterTableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
        if (!myCell) {
            myCell = [[YXM_MasterTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sIdentifier];
        }

        ALAsset *myALAsset = [self.assets objectAtIndex:indexPath.row];
        [myCell setMyALAsset:myALAsset];
        return myCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    NSString *materialType = [asset valueForProperty:ALAssetPropertyType];
    if ([materialType isEqualToString:@"ALAssetTypeVideo"]) {
        [self.delegate selectPhotoToLayerWithALAsset:asset cellIndexPath:indexPath];
    }else{
        MaterialObject *oneMaterialObject = [MaterialObject revertALAssetToMaterialObject:asset];
        if (oneMaterialObject) {
            DLog(@"素材对象,选择待选素材加入播放列表中 = %@",oneMaterialObject);
            [self.delegate selectPhotoToLayerWithMaterialObj:oneMaterialObject cellIndexPath:indexPath];
        }
    }
}


#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{

    ALAsset *myALAsset = [assets objectAtIndex:0];
    NSString * nsALAssetPropertyType = [myALAsset valueForProperty:ALAssetPropertyType];
  //    选中图片 后
    if(back){
        
        [self ftpuser];
        
    }else{
        
        
        
        DLog(@"项目类型 === %@",nsALAssetPropertyType);
        if ([nsALAssetPropertyType isEqualToString:@"ALAssetTypePhoto"]&&DEVICE_IS_IPAD) {
            
            [self.delegate selectPhotoToLayerWithALAsset:myALAsset cellIndexPath:nil];

//            [self.assets removeAllObjects];
//            [self.assets addObjectsFromArray:assets];
//            [self.tableView reloadData];
            
            return;
        }

        
        
        
        [self.delegate selectPhotoToLayerWithALAsset:myALAsset cellIndexPath:nil];
        if (self.popover != nil)
            [self.popover dismissPopoverAnimated:YES];
        else
            [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];

        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[self indexPathOfNewlyAddedAssets:assets]
                              withRowAnimation:UITableViewRowAnimationBottom];

        [self.assets addObjectsFromArray:assets];
        [self.tableView endUpdates];
    }

}

- (NSArray *)indexPathOfNewlyAddedAssets:(NSArray *)assets
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (int i = self.assets.count; i < self.assets.count + assets.count ; i++)
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    
    return indexPaths;
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    //获取资源图片的详细资源信息
    NSString * nsALAssetPropertyType = [asset valueForProperty:ALAssetPropertyType];
    DLog(@"===%@",nsALAssetPropertyType);
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    NSURL* url = [representation url];
    NSString* filename = [representation filename];
    DLog(@"获取filename:%@",filename);
    NSArray *pathSeparatedArray = [[NSString stringWithFormat:@"%@",filename] componentsSeparatedByString:@"."];
    NSString *sExtString;
//    NSString *myFilePath;
    if ([pathSeparatedArray count]==2) {
        pname = [pathSeparatedArray objectAtIndex:0];
        sExtString=[pathSeparatedArray objectAtIndex:1];
    }
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];

//    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    if( 1 == 0 ){
//    if ([nsALAssetPropertyType isEqualToString:@"ALAssetTypeVideo"]) {
//        if (sExtString==nil) {
//            sExtString = @"mov";
//        }
//        myFilePath = [NSString stringWithFormat:@"%@/%@.%@",DocumentsPath,pname,sExtString];
//
//        NSString * pathString = [[NSString alloc]initWithString:myFilePath];
//        DLog(@"%@",pathString);
//
//        NSUInteger size = [representation size];
//        const int bufferSize = 65636;
//
//        FILE *f = fopen([myFilePath cStringUsingEncoding:1], "wb+");
//        if (f==NULL) {
//            return nil;
//        }
//        Byte *buffer =(Byte*)malloc(bufferSize);
//        int read =0, offset = 0;
//        NSError *error;
//        if (size != 0) {
//            do {
//                read = [representation getBytes:buffer
//                          fromOffset:offset
//                              length:bufferSize
//                               error:&error];
//                fwrite(buffer, sizeof(char), read, f);
//                offset += read;
//            } while (read != 0);
//        }
//        fclose(f);
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSDictionary * dict = [fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@.%@",DocumentsPath,pname,sExtString] error:nil];
//        //方法一:
//        NSLog(@"size = %lld",[dict fileSize]);
//        NSArray *arr=[[NSArray alloc]init];
//        arr=[fileManager subpathsOfDirectoryAtPath:DocumentsPath error:nil];
//        DLog(@"%@",arr);
//    }
//    }
    if ([nsALAssetPropertyType isEqualToString:@"ALAssetTypePhoto"]){
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
        ALAssetRepresentation* representation = [asset defaultRepresentation];

        CGImageRef imgref = [representation fullScreenImage];
        UIImage *image = [UIImage imageWithCGImage:imgref scale:representation.scale orientation:(UIImageOrientation)representation.orientation];
        DLog(@"%f   %f",image.size.height,image.size.width);
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil)
        {
            data = UIImagePNGRepresentation(image);
        }
        else
        {
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        UIImage *img=[UIImage imageWithData:data];
        DLog(@"%f   %f",img.size.height,img.size.width);
        //图片保存的路径
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        //文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.jpg
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/warty-final-ubuntu.png"] contents:data attributes:nil];
        NSDictionary * dict = [fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/warty-final-ubuntu.png",DocumentsPath] error:nil];
        //方法一:
        NSLog(@"size = %lld",[dict fileSize]);
    }failureBlock:^(NSError *error) {
        NSLog(@"error=%@",error);
    }
     ];
    }
    if (picker.selectedAssets.count >= _iAssetMaxSelect)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:[NSString stringWithFormat:@"Please select not more than %d assets",_iAssetMaxSelect]
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < _iAssetMaxSelect && asset.defaultRepresentation != nil);
}


@end
