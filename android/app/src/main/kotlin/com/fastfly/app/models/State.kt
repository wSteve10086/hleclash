package com.fastfly.app.models


data class AppState(
    val crashlytics: Boolean = true,
    val currentProfileName: String = "Fastfly",
    val stopText: String = "Stop",
    val onlyStatisticsProxy: Boolean = false,
)
