//
//  LBXScanView.swift
//  swiftScan
//
//  Created by xialibing on 15/12/8.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit

class LBXScanView: UIView
{
    //扫码区域各种参数
    var viewStyle:LBXScanViewStyle = LBXScanViewStyle()
    
     //扫码区域
    var scanRetangleRect:CGRect = CGRectZero
    
    //线条扫码动画封装
    var scanLineAnimation:LBXScanLineAnimation?
    
    //网格扫码动画封装
    var scanNetAnimation:LBXScanNetAnimation?
    
    //线条在中间位置，不移动
    var scanLineStill:UIImageView?
    
    //启动相机时 菊花等待
    var activityView:UIActivityIndicatorView?
    
    //启动相机中的提示文字
    var labelReadying:UILabel?
    
    //记录动画状态
    var isAnimationing:Bool = false
    
    /**
    初始化扫描界面
    - parameter frame:  界面大小，一般为视频显示区域
    - parameter vstyle: 界面效果参数
    
    - returns: instancetype
    */
    init(frame:CGRect, vstyle:LBXScanViewStyle )
    {
        viewStyle = vstyle
        
        switch (viewStyle.anmiationStyle)
        {
        case LBXScanViewAnimationStyle.LineMove:
            scanLineAnimation = LBXScanLineAnimation()
            break
        case LBXScanViewAnimationStyle.NetGrid:
            scanNetAnimation = LBXScanNetAnimation()
            break
        case LBXScanViewAnimationStyle.LineStill:
            scanLineStill = UIImageView()
            scanLineStill?.image = viewStyle.animationImage
            break
            
            
        default:
            break
        }
        
        var frameTmp = frame;
        frameTmp.origin = CGPointZero
        
        super.init(frame: frameTmp)
        
        backgroundColor = UIColor.clearColor()
    }
    
    override init(frame: CGRect) {
        
        var frameTmp = frame;
        frameTmp.origin = CGPointZero
        
        super.init(frame: frameTmp)
        
        backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        self.init()
       
    }
    
    deinit
    {
        if (scanLineAnimation != nil)
        {
            scanLineAnimation!.stopStepAnimating()
        }
        if (scanNetAnimation != nil)
        {
            scanNetAnimation!.stopStepAnimating()
        }
        
        
        print("LBXScanView deinit")
    }
    
    
    /**
    *  开始扫描动画
    */
    func startScanAnimation()
    {
        if isAnimationing
        {
            return
        }
        
        isAnimationing = true
        
        let cropRect:CGRect = getScanRectForAnimation()
        
        switch viewStyle.anmiationStyle
        {
        case LBXScanViewAnimationStyle.LineMove:
            
            print(NSStringFromCGRect(cropRect))
            
            scanLineAnimation!.startAnimatingWithRect(cropRect, parentView: self, image:viewStyle.animationImage )
            break
        case LBXScanViewAnimationStyle.NetGrid:
            
            scanNetAnimation!.startAnimatingWithRect(cropRect, parentView: self, image:viewStyle.animationImage )
            break
        case LBXScanViewAnimationStyle.LineStill:
            
            let stillRect = CGRectMake(cropRect.origin.x+20,
                cropRect.origin.y + cropRect.size.height/2,
                cropRect.size.width-40,
                2);
            self.scanLineStill?.frame = stillRect
            
            self.addSubview(scanLineStill!)
            self.scanLineStill?.hidden = false
            
            break
            
        default: break
            
        }
    }
    
    /**
     *  开始扫描动画
     */
    func stopScanAnimation()
    {
        isAnimationing = false
        
        switch viewStyle.anmiationStyle
        {
        case LBXScanViewAnimationStyle.LineMove:
            
            scanLineAnimation?.stopStepAnimating()
            break
        case LBXScanViewAnimationStyle.NetGrid:
            
            scanNetAnimation?.stopStepAnimating()
            break
        case LBXScanViewAnimationStyle.LineStill:
             self.scanLineStill?.hidden = true
            
            break
            
        default: break
            
        }
    }

    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
        drawScanRect()
    }
    
    //MARK:----- 绘制扫码效果-----
    func drawScanRect()
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        var sizeRetangle = CGSizeMake(self.frame.size.width - XRetangleLeft*2.0, self.frame.size.width - XRetangleLeft*2.0)
        if viewStyle.whRatio != 1.0
        {
            let w = sizeRetangle.width;
            var h:CGFloat = w / viewStyle.whRatio
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSizeMake(w,h)
        }
        
        //扫码区域Y轴最小坐标
        let YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        let YMaxRetangle = YMinRetangle + sizeRetangle.height
        let XRetangleRight = self.frame.size.width - XRetangleLeft
        
        
        print("frame:%@",NSStringFromCGRect(self.frame))
        
        let context:CGContext? = UIGraphicsGetCurrentContext()
        
        
        //非扫码区域半透明
            //设置非识别区域颜色
            CGContextSetRGBFillColor(context, viewStyle.red_notRecoginitonArea, viewStyle.green_notRecoginitonArea,
                viewStyle.blue_notRecoginitonArea, viewStyle.alpa_notRecoginitonArea)
            //填充矩形
            //扫码区域上面填充
            var rect = CGRectMake(0, 0, self.frame.size.width, YMinRetangle)
            CGContextFillRect(context, rect)
            
            
            //扫码区域左边填充
            rect = CGRectMake(0, YMinRetangle, XRetangleLeft,sizeRetangle.height)
            CGContextFillRect(context, rect)
            
            //扫码区域右边填充
            rect = CGRectMake(XRetangleRight, YMinRetangle, XRetangleLeft,sizeRetangle.height)
            CGContextFillRect(context, rect)
            
            //扫码区域下面填充
            rect = CGRectMake(0, YMaxRetangle, self.frame.size.width,self.frame.size.height - YMaxRetangle)
            CGContextFillRect(context, rect)
            //执行绘画
            CGContextStrokePath(context)
        
        
        if viewStyle.isNeedShowRetangle
        {
            //中间画矩形(正方形)
            CGContextSetStrokeColorWithColor(context, viewStyle.colorRetangleLine.CGColor)
            CGContextSetLineWidth(context, 1);
            
            CGContextAddRect(context, CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height))
            
            //CGContextMoveToPoint(context, XRetangleLeft, YMinRetangle);
            //CGContextAddLineToPoint(context, XRetangleLeft+sizeRetangle.width, YMinRetangle);
            
            CGContextStrokePath(context)
            
        }
        scanRetangleRect = CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height)
        
        
        //画矩形框4格外围相框角
        
        //相框角的宽度和高度
        let wAngle = viewStyle.photoframeAngleW;
        let hAngle = viewStyle.photoframeAngleH;
        
        //4个角的 线的宽度
        let linewidthAngle = viewStyle.photoframeLineW;// 经验参数：6和4
        
        //画扫码矩形以及周边半透明黑色坐标参数
        var diffAngle = linewidthAngle/3;
        //diffAngle = linewidthAngle / 2; //框外面4个角，与框有缝隙
        //diffAngle = linewidthAngle/2;  //框4个角 在线上加4个角效果
        //diffAngle = 0;//与矩形框重合
        
        switch viewStyle.photoframeAngleStyle
        {
        case LBXScanViewPhotoframeAngleStyle.Outer:
                diffAngle = linewidthAngle/3//框外面4个角，与框紧密联系在一起
           
        case LBXScanViewPhotoframeAngleStyle.On:
                diffAngle = 0
            
        case LBXScanViewPhotoframeAngleStyle.Inner:
                diffAngle = -viewStyle.photoframeLineW/2
        }
        
        CGContextSetStrokeColorWithColor(context, viewStyle.colorAngle.CGColor);
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        
        // Draw them with a 2.0 stroke width so they are a bit more visible.
        CGContextSetLineWidth(context, linewidthAngle);
        
        
        //
        let leftX = XRetangleLeft - diffAngle
        let topY = YMinRetangle - diffAngle
        let rightX = XRetangleRight + diffAngle
        let bottomY = YMaxRetangle + diffAngle
        
        //左上角水平线
        CGContextMoveToPoint(context, leftX-linewidthAngle/2, topY)
        CGContextAddLineToPoint(context, leftX + wAngle, topY)
        
        //左上角垂直线
        CGContextMoveToPoint(context, leftX, topY-linewidthAngle/2)
        CGContextAddLineToPoint(context, leftX, topY+hAngle)
        
        
        //左下角水平线
        CGContextMoveToPoint(context, leftX-linewidthAngle/2, bottomY)
        CGContextAddLineToPoint(context, leftX + wAngle, bottomY)
        
        //左下角垂直线
        CGContextMoveToPoint(context, leftX, bottomY+linewidthAngle/2)
        CGContextAddLineToPoint(context, leftX, bottomY - hAngle)
        
        
        //右上角水平线
        CGContextMoveToPoint(context, rightX+linewidthAngle/2, topY)
        CGContextAddLineToPoint(context, rightX - wAngle, topY)
        
        //右上角垂直线
        CGContextMoveToPoint(context, rightX, topY-linewidthAngle/2)
        CGContextAddLineToPoint(context, rightX, topY + hAngle)
        
        
        //右下角水平线
        CGContextMoveToPoint(context, rightX+linewidthAngle/2, bottomY)
        CGContextAddLineToPoint(context, rightX - wAngle, bottomY)
        
        //右下角垂直线
        CGContextMoveToPoint(context, rightX, bottomY+linewidthAngle/2)
        CGContextAddLineToPoint(context, rightX, bottomY - hAngle)
        
        CGContextStrokePath(context)
    }
    
    func getScanRectForAnimation() -> CGRect
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        var sizeRetangle = CGSizeMake(self.frame.size.width - XRetangleLeft*2, self.frame.size.width - XRetangleLeft*2)
        
        if viewStyle.whRatio != 1
        {
            let w = sizeRetangle.width
            var h = w / viewStyle.whRatio
            
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSizeMake(w, h)
        }
        
        //扫码区域Y轴最小坐标
        let YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        //扫码区域坐标
        let cropRect =  CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height)
        
        return cropRect;
    }

    //根据矩形区域，获取识别区域
    static func getScanRectWithPreView(preView:UIView, style:LBXScanViewStyle) -> CGRect
    {
        let XRetangleLeft = style.xScanRetangleOffset;
        var sizeRetangle = CGSizeMake(preView.frame.size.width - XRetangleLeft*2, preView.frame.size.width - XRetangleLeft*2)
        
        if style.whRatio != 1
        {
            let w = sizeRetangle.width
            var h = w / style.whRatio
            
            let hInt:Int = Int(h)
            h = CGFloat(hInt)
            
            sizeRetangle = CGSizeMake(w, h)
        }
        
        //扫码区域Y轴最小坐标
        let YMinRetangle = preView.frame.size.height / 2.0 - sizeRetangle.height/2.0 - style.centerUpOffset
        //扫码区域坐标
        let cropRect =  CGRectMake(XRetangleLeft, YMinRetangle, sizeRetangle.width, sizeRetangle.height)
        
        
        //计算兴趣区域
        var rectOfInterest:CGRect
        
        //ref:http://www.cocoachina.com/ios/20141225/10763.html
        let size = preView.bounds.size;
        let p1 = size.height/size.width;
        
        let p2:CGFloat = 1920.0/1080.0 //使用了1080p的图像输出
        if p1 < p2 {
            let fixHeight = size.width * 1920.0 / 1080.0;
            let fixPadding = (fixHeight - size.height)/2;
            rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                cropRect.origin.x/size.width,
                cropRect.size.height/fixHeight,
                cropRect.size.width/size.width)
            
            
        } else {
            let fixWidth = size.height * 1080.0 / 1920.0;
            let fixPadding = (fixWidth - size.width)/2;
            rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                (cropRect.origin.x + fixPadding)/fixWidth,
                cropRect.size.height/size.height,
                cropRect.size.width/fixWidth)
        }
        return rectOfInterest
    }
    
    func getRetangeSize()->CGSize
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        
        var sizeRetangle = CGSizeMake(self.frame.size.width - XRetangleLeft*2, self.frame.size.width - XRetangleLeft*2)
        
        let w = sizeRetangle.width;
        var h = w / viewStyle.whRatio;
        
        
        let hInt:Int = Int(h)
        h = CGFloat(hInt)
        
        sizeRetangle = CGSizeMake(w, h)
        
        return sizeRetangle
    }
    
    func deviceStartReadying(readyStr:String)
    {
        let XRetangleLeft = viewStyle.xScanRetangleOffset
        
        let sizeRetangle = getRetangeSize()
        
        //扫码区域Y轴最小坐标
        let YMinRetangle = self.frame.size.height / 2.0 - sizeRetangle.height/2.0 - viewStyle.centerUpOffset
        
        //设备启动状态提示
        if (activityView == nil)
        {
            self.activityView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 30, 30))
            
            activityView?.center = CGPointMake(XRetangleLeft +  sizeRetangle.width/2 - 50, YMinRetangle + sizeRetangle.height/2)
            activityView?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            
            addSubview(activityView!)
            
            
            let labelReadyRect = CGRectMake(activityView!.frame.origin.x + activityView!.frame.size.width + 10, activityView!.frame.origin.y, 100, 30);
            //print("%@",NSStringFromCGRect(labelReadyRect))
            self.labelReadying = UILabel(frame: labelReadyRect)
            labelReadying?.text = readyStr
            labelReadying?.backgroundColor = UIColor.clearColor()
            labelReadying?.textColor = UIColor.whiteColor()
            labelReadying?.font = UIFont.systemFontOfSize(18.0)
            addSubview(labelReadying!)
        }
        
         addSubview(labelReadying!)
         activityView?.startAnimating()
        
    }
    
    func deviceStopReadying()
    {
        if activityView != nil
        {
            activityView?.stopAnimating()
            activityView?.removeFromSuperview()
            labelReadying?.removeFromSuperview()
            
            activityView = nil
            labelReadying = nil
            
        }
    }

}
