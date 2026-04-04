// IRemoteInterface.aidl
package com.fastfly.app.service;

import com.fastfly.app.service.ICallbackInterface;
import com.fastfly.app.service.IEventInterface;
import com.fastfly.app.service.IResultInterface;
import com.fastfly.app.service.models.VpnOptions;
import com.fastfly.app.service.models.NotificationParams;

interface IRemoteInterface {
    void invokeAction(in String data, in ICallbackInterface callback);
    void updateNotificationParams(in NotificationParams params);
    void startService(in VpnOptions options, in long runTime, in IResultInterface result);
    void stopService(in IResultInterface result);
    void setEventListener(in IEventInterface event);
    void setCrashlytics(in boolean enable);
    long getRunTime();
}