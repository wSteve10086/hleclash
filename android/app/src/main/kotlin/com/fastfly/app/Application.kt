package com.fastfly.app

import android.app.Application
import android.content.Context
import com.fastfly.app.common.GlobalState

class Application : Application() {

    override fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        GlobalState.init(this)
    }
}
