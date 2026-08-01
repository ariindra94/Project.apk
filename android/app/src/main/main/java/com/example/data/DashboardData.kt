package com.example.data

import org.json.JSONObject

data class DashboardData(
    val speed: Int = 135,
    val rpm: Int = 6500,
    val gear: Int = 6,
    val temp: Double = 82.0,
    val fuel: Double = 68.0,
    val volt: Double = 12.8,
    val trip: Double = 235.6,
    val odo: Double = 12035.0,
    val left: Boolean = false,
    val right: Boolean = true,
    val highbeam: Boolean = true,
    val neutral: Boolean = false,
    val abs: Boolean = true,
    val oil: Boolean = false,
    val engine: Boolean = false,
    val mode: String = "RACE"
) {
    companion object {
        fun fromJson(jsonStr: String): DashboardData? {
            return try {
                val json = JSONObject(jsonStr)
                DashboardData(
                    speed = json.optInt("speed", 0),
                    rpm = json.optInt("rpm", 0),
                    gear = json.optInt("gear", 0),
                    temp = json.optDouble("temp", 0.0),
                    fuel = json.optDouble("fuel", 0.0),
                    volt = json.optDouble("volt", 12.0),
                    trip = json.optDouble("trip", 0.0),
                    odo = json.optDouble("odo", 0.0),
                    left = json.optBoolean("left", false),
                    right = json.optBoolean("right", false),
                    highbeam = json.optBoolean("highbeam", false),
                    neutral = json.optBoolean("neutral", false),
                    abs = json.optBoolean("abs", false),
                    oil = json.optBoolean("oil", false),
                    engine = json.optBoolean("engine", false),
                    mode = json.optString("mode", "RACE")
                )
            } catch (e: Exception) {
                null
            }
        }

        fun sample(): DashboardData = DashboardData(
            speed = 135,
            rpm = 6500,
            gear = 6,
            temp = 82.0,
            fuel = 68.0,
            volt = 12.8,
            trip = 235.6,
            odo = 12035.0,
            left = false,
            right = true,
            highbeam = true,
            neutral = false,
            abs = true,
            oil = false,
            engine = false,
            mode = "RACE"
        )
    }
}
