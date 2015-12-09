//
//  testSwiftContent.swift
//  swiftScan
//
//  Created by csc on 15/12/1.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import UIKit


func testGlobalFunc()
{
    print("global func，prove swift not pure object-class language")
}

func addTwoInts(a: Int, _ b: Int) -> Int {
    return a + b
}

struct Size {
    var width = 0.0, height = 0.0
}

class testSwiftContent: NSObject {

    let constvar = 111;
    
    var tvarrr:UInt32;
    
    //必须初始化,或者在init里面初始化
    var tvar = 300;
    var welcomeMessage: String="123";
    
    //? 符号 可选的  optioanl String
    var welcomeMessage2:String?;
    
    //问号暗示包含的值是可选类型，也就是说可能包含Int值也可能不包含值
    var optionalInttt:UInt32?
    
    //函数变量
    var mathFunction: (Int, Int) -> Int = addTwoInts;
    
    //结构体的逐一成员构造器
    let twoByTwo = Size(width: 2.0, height: 2.0)
    
    //init 没有 func 字样
    override init() {
        
        
        self.tvarrr = 0;
        
        //初始化必须在 super.init之前调用
        //当前类的成员必须在当前初始化完后，然后调用父类init
        tvarrr = 10;
        
        self.tvarrr = 20;
        
        
        super.init();        
        
    }
    
    
//    func addTwoInts(para1:Int,_ para2:Int)->Int
//    {
//        return para1+para2;
//    }
    
   
    
    
    
    func test(inout ttt:Int)
    {
        ttt = 199;
    }
    func test2(var ttt:Int)
    {
        ttt = 199;
    }
    
    func test3(ttt:Int)
    {
        //compile error
        //ttt = 199;
    }
    
    
    func test()
    {
        let tvar = 30;
        
        test2(tvar)
        
        var array:NSArray?
        array = ["1","2"];
        print(array, terminator: "\n")
        print(array)
        
        
        var uint:UInt32 = 100;
        uint = 200;
        print(uint);
        
        
        var uint25 = 300;
        uint25 = 105;
        print(uint25);
        
        let iiii = 300;
        print(iiii);
        
        var b:Bool = true;
        b = false;
        print(b);
        
        let twoThousand: UInt16 = 2_000
        let one: UInt8 = 1
        let twoThousandAndOne = twoThousand + UInt16(one)
        print(twoThousandAndOne);
        
        let possibleNumber = "123"
        let convertedNumber = Int(possibleNumber)
        // convertedNumber 被推测为类型 "Int?"， 或者类型 "optional Int"
        if convertedNumber != nil {
            print("convertedNumber contains some integer value.")
        }
        // 输出 "convertedNumber contains some integer value."
        
        if convertedNumber != nil {
            print("convertedNumber has an integer value of \(convertedNumber!).")
        }
        // 输出 "convertedNumber has an integer value of 123."
        
        
        let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
        var names2 =  names.sort();
    }

    
}



class ClassA {
    let numA: Int
    init(num: Int) {
        numA = num
    }
    
    convenience init(bigNum: Bool) {
        self.init(num: bigNum ? 10000 : 1)
    }
}

class ClassB: ClassA {
    let numB: Int
    
    //override designated init method
    override init(num: Int) {
        numB = num + 1
        super.init(num: num)
    }
}
