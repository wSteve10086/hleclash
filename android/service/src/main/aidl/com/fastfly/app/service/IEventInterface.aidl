// IEventInterface.aidl
package com.fastfly.app.service;

import com.fastfly.app.service.IAckInterface;

interface IEventInterface {
    oneway void onEvent(in String id, in byte[] data,in boolean isSuccess, in IAckInterface ack);
}