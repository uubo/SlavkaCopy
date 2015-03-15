//
//  SerialPortSample.h
//  VkMessage
//
//  Created by Влад Агиевич on 15.03.15.
//  Copyright (c) 2015 Uubo. All rights reserved.
//

#ifndef __VkMessage__SerialPortSample__
#define __VkMessage__SerialPortSample__

int openSerialPort(const char *bsdPath);
void closeSerialPort(int fileDescriptor);

#endif /* defined(__VkMessage__SerialPortSample__) */
