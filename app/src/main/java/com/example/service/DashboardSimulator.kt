package com.example.service

import com.example.data.DashboardData
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlin.math.sin

class DashboardSimulator {

    private val _simulatedData = MutableStateFlow(DashboardData.sample())
    val simulatedData: StateFlow<DashboardData> = _simulatedData.asStateFlow()

    private var simJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.Default)

    private var isSimulating = false
    private var timeSeconds = 0.0

    // Simulation states
    private var speed = 135.0
    private var rpm = 6500.0
    private var gear = 6
    private var temp = 82.0
    private var fuel = 68.0
    private var volt = 12.8
    private var trip = 235.6
    private var odo = 12035.0
    private var left = false
    private var right = true
    private var highbeam = true
    private var neutral = false
    private var abs = true
    private var oil = false
    private var engine = false
    private var mode = "RACE"

    fun startSimulation() {
        if (isSimulating) return
        isSimulating = true
        simJob?.cancel()
        simJob = scope.launch {
            var blinkCounter = 0
            while (isSimulating) {
                timeSeconds += 0.1
                blinkCounter++

                // Dynamic RPM wave revving (e.g., 3000 to 11000 RPM)
                val rpmTarget = 4000.0 + 3500.0 * (1.0 + sin(timeSeconds * 0.8))
                rpm += (rpmTarget - rpm) * 0.2

                // Calculate speed based on RPM and Gear
                val gearRatio = when (gear) {
                    1 -> 15.0
                    2 -> 22.0
                    3 -> 28.0
                    4 -> 34.0
                    5 -> 40.0
                    6 -> 46.0
                    else -> 0.0
                }
                val speedTarget = (rpm / 1000.0) * gearRatio
                speed += (speedTarget - speed) * 0.15

                // Gear auto-shift logic for realistic demo
                if (rpm > 9500 && gear < 6) {
                    gear++
                    rpm -= 2500
                } else if (rpm < 3500 && gear > 1) {
                    gear--
                    rpm += 2000
                }
                neutral = (gear == 0)

                // Voltage slight jitter
                volt = 12.6 + sin(timeSeconds * 2.0) * 0.3

                // Temperature slight variation
                temp = 80.0 + sin(timeSeconds * 0.1) * 5.0

                // Distance accumulation
                val kmPerSec = (speed / 3600.0) * 0.1
                trip += kmPerSec
                odo += kmPerSec

                // Turn signal blink simulation (toggles every 5 ticks = 500ms)
                if (blinkCounter % 5 == 0) {
                    if (right && !left) {
                        // right signal blinking state managed in UI or toggled
                    }
                }

                _simulatedData.value = DashboardData(
                    speed = speed.toInt().coerceIn(0, 299),
                    rpm = rpm.toInt().coerceIn(0, 13000),
                    gear = gear,
                    temp = (temp * 10).toInt() / 10.0,
                    fuel = (fuel * 10).toInt() / 10.0,
                    volt = (volt * 10).toInt() / 10.0,
                    trip = (trip * 10).toInt() / 10.0,
                    odo = (odo * 10).toInt() / 10.0,
                    left = left,
                    right = right,
                    highbeam = highbeam,
                    neutral = neutral,
                    abs = abs,
                    oil = oil,
                    engine = engine,
                    mode = mode
                )

                delay(100) // 10 FPS updates
            }
        }
    }

    fun stopSimulation() {
        isSimulating = false
        simJob?.cancel()
        simJob = null
    }

    fun updateManualData(newData: DashboardData) {
        _simulatedData.value = newData
        speed = newData.speed.toDouble()
        rpm = newData.rpm.toDouble()
        gear = newData.gear
        temp = newData.temp
        fuel = newData.fuel
        volt = newData.volt
        trip = newData.trip
        odo = newData.odo
        left = newData.left
        right = newData.right
        highbeam = newData.highbeam
        neutral = newData.neutral
        abs = newData.abs
        oil = newData.oil
        engine = newData.engine
        mode = newData.mode
    }
}
