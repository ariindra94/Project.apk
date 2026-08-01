package com.example.ui.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.example.data.DashboardData
import com.example.service.DashboardSimulator
import com.example.service.UsbSerialManager
import com.example.ui.components.CenterGaugePanel
import com.example.ui.components.ControlsAndSettingsModal
import com.example.ui.components.LeftIndicatorPanel
import com.example.ui.components.RightGaugePanel
import com.example.ui.components.TopHeaderBar
import com.example.ui.theme.DashBackground
import com.example.ui.theme.DashSurface
import com.example.ui.theme.DashSurfaceBorder

@Composable
fun DashboardScreen() {
    val context = LocalContext.current

    // USB Serial & Simulator Instances
    val usbManager = remember { UsbSerialManager(context) }
    val simulator = remember { DashboardSimulator() }

    val usbStatus by usbManager.connectionState.collectAsState()
    val usbData by usbManager.parsedData.collectAsState()
    val rawLog by usbManager.rawLog.collectAsState()

    val simData by simulator.simulatedData.collectAsState()

    var isSimulating by remember { mutableStateOf(true) }
    var showSettingsModal by remember { mutableStateOf(false) }

    // Start simulation by default on launch
    LaunchedEffect(Unit) {
        usbManager.scanAndConnect()
        simulator.startSimulation()
    }

    DisposableEffect(Unit) {
        onDispose {
            usbManager.unregister()
            simulator.stopSimulation()
        }
    }

    // Determine active display data (Use USB data if available, else simulated data)
    val activeData: DashboardData = if (!isSimulating && usbData != null) {
        usbData!!
    } else {
        simData
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(DashBackground)
    ) {
        // Main Dashboard Glass Border Frame
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(4.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(DashBackground)
                .border(1.dp, DashSurfaceBorder, RoundedCornerShape(16.dp))
        ) {
            Column(modifier = Modifier.fillMaxSize()) {
                // 1. TOP HEADER BAR
                TopHeaderBar(
                    data = activeData,
                    usbStatus = usbStatus,
                    onOpenSettings = { showSettingsModal = true }
                )

                // 2. THREE-PANEL LANDSCAPE MAIN BODY
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                ) {
                    // LEFT PANEL (Tell-Tale Indicators)
                    Box(
                        modifier = Modifier
                            .weight(0.28f)
                            .fillMaxHeight()
                            .clip(RoundedCornerShape(16.dp))
                            .background(DashSurface)
                            .border(1.dp, DashSurfaceBorder, RoundedCornerShape(16.dp))
                    ) {
                        LeftIndicatorPanel(data = activeData)
                    }

                    // CENTER PANEL (RPM Arc, Speedometer, Gear, Riding Mode)
                    Box(
                        modifier = Modifier
                            .weight(0.44f)
                            .fillMaxHeight()
                            .padding(horizontal = 4.dp)
                    ) {
                        CenterGaugePanel(
                            data = activeData,
                            onSelectMode = { newMode ->
                                simulator.updateManualData(activeData.copy(mode = newMode))
                            }
                        )
                    }

                    // RIGHT PANEL (Right Turn, Segmented Fuel Gauge, Trip)
                    Box(
                        modifier = Modifier
                            .weight(0.28f)
                            .fillMaxHeight()
                            .clip(RoundedCornerShape(16.dp))
                            .background(DashSurface)
                            .border(1.dp, DashSurfaceBorder, RoundedCornerShape(16.dp))
                    ) {
                        RightGaugePanel(data = activeData)
                    }
                }

                // 3. BOTTOM DECORATIVE NAVIGATION INDICATOR PILL
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 4.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Box(
                        modifier = Modifier
                            .height(4.dp)
                            .width(96.dp)
                            .clip(CircleShape)
                            .background(Color.White.copy(alpha = 0.2f))
                    )
                }
            }
        }

        // CONTROLS & SETTINGS DIALOG
        if (showSettingsModal) {
            ControlsAndSettingsModal(
                usbStatus = usbStatus,
                rawLog = rawLog,
                currentData = activeData,
                isSimulating = isSimulating,
                onScanUsb = { usbManager.scanAndConnect() },
                onToggleSimulation = { enable ->
                    isSimulating = enable
                    if (enable) {
                        simulator.startSimulation()
                    } else {
                        simulator.stopSimulation()
                    }
                },
                onUpdateManualData = { updated ->
                    simulator.updateManualData(updated)
                },
                onDismiss = { showSettingsModal = false }
            )
        }
    }
}

