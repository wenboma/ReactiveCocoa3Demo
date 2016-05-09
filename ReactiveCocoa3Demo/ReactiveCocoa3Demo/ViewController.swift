//
//  ViewController.swift
//  ReactiveCocoa3Demo
//
//  Created by 马文铂 on 16/4/26.
//  Copyright © 2016年 UK. All rights reserved.
//

import UIKit


enum TestError: Int {
    case Default = 0
    case Error1 = 1
    case Error2 = 2
}

extension TestError: ErrorType {
    
}

class ViewController: UIViewController {
    
    let testScheduler: TestScheduler! = TestScheduler()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Signal"
        
//        self.testFunc1()
//        self.testFunc2()
//        self.testFucn3()
//        self.testFunc4()
        self.testFucn5()
    }
    
    func testFunc2(){
        let signal: Signal<String, NoError> =  self.creatSingle()
        
        signal.observeNext { (str) in
            print(str)
        }
        signal.observe{event in
            switch event{
            case let .Next(str):
                print(str)
            default: break
            }
            
        }
        self.testScheduler.run()
       
    }
    
    func testFunc1() {
        let numbers = [ 1, 2, 5 ]
        
        let signal: Signal<Int, NoError> = Signal { observer in
            self.testScheduler.schedule {
                for number in numbers {
                    observer.sendNext(number)
                }
                observer.sendCompleted()
            }
            return nil
        }
        
        var fromSignal: [Int] = []
        var completed = false
        
        signal.observe { event in
            switch event {
            case let .Next(number):
                fromSignal.append(number)
            case .Completed:
                completed = true
            default:
                break
            }
        }
        
        self.testScheduler.run()
        
        
        print(fromSignal)
    }
    
    
    func testFucn3(){
        let disposable = SimpleDisposable()
        
        let signal: Signal<AnyObject, TestError> = Signal { observer in
            self.testScheduler.schedule {
                observer.sendFailed(TestError.Default)
            }
            return disposable
        }
        
        
        
        signal.observeFailed { (err) in
            print(err)
        }
        
        testScheduler.run()
    
    }
   
    func testFunc4(){
        var handlerCalledTimes = 0
        let signalProducer = SignalProducer<String, NSError>() { observer, disposable in
            handlerCalledTimes += 1
            
            return
        }
        
        signalProducer.start()
        signalProducer.start()
        
        print(handlerCalledTimes)
    
    }
    
    func testFucn5(){
    
        var disposable: Disposable!
        
        let producer = SignalProducer<Int, NoError> { observer, innerDisposable in
            disposable = innerDisposable
            
//            innerDisposable.addDisposable {
                // This is necessary to keep the observer long enough to
                // even test the memory management.
                observer.sendNext(78)
//            }
        }
        
        weak var objectRetainedByObserver: NSObject?
        producer.startWithSignal { signal, _ in
            let object = NSObject()
            objectRetainedByObserver = object

            signal.observeNext({ (next) in
                print("next = \(next)")
            })
        }
        
        print(objectRetainedByObserver)
        
//        disposable.dispose()
        print(objectRetainedByObserver)
    }
    
    func creatSingle() -> Signal<String , NoError>{
        return Signal{
            sink in
            
            self.testScheduler.schedule({
                var count = 0
               sink.sendNext(String(count))
            })
        
            return nil
        }
        
        
    }
    

}

