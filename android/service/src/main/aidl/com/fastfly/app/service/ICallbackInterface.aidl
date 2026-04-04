// ICallbackInterface.aidl
package com.fastfly.app.service;

import com.fastfly.app.service.IAckInterface;

interface ICallbackInterface {
    oneway void onResult(in byte[] data,in boolean isSuccess, in IAckInterface ack);
}