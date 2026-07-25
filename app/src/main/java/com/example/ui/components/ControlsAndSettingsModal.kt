package com.example.ui.components

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material.icons.filled.Usb
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.TabRowDefaults
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import com.example.data.DashboardData
import com.example.ui.theme.DashBackground
import com.example.ui.theme.DashSurface
import com.example.ui.theme.DashSurfaceBorder
import com.example.ui.theme.GearBlue
import com.example.ui.theme.NeonCyan
import com.example.ui.theme.NeonGreen
import com.example.ui.theme.NeonRed
import com.example.ui.theme.TextGray
import com.example.ui.theme.TextWhite

@Composable
fun ControlsAndSettingsModal(
    usbStatus: String,
    rawLog: List<String>,
    currentData: DashboardData,
    isSimulating: Boolean,
    onScanUsb: () -> Unit,
    onToggleSimulation: (Boolean) -> Unit,
    onUpdateManualData: (DashboardData) -> Unit,
    onDismiss: () -> Unit
) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val context = LocalContext.current

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(
            usePlatformDefaultWidth = false,
            dismissOnClickOutside = true
        )
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth(0.92f)
                .fillMaxHeight(0.9f)
                .clip(RoundedCornerShape(16.dp))
                .background(DashBackground)
                .border(1.5.dp, DashSurfaceBorder, RoundedCornerShape(16.dp))
                .padding(16.dp)
        ) {
            Column(modifier = Modifier.fillMaxSize()) {
                // HEADER ROW
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.Usb,
                            contentDescription = "USB Settings",
                            tint = NeonCyan,
                            modifier = Modifier.padding(end = 8.dp)
                        )
                        Text(
                            text = "ESP32 USB OTG & Simulation Panel",
                            color = TextWhite,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    IconButton(onClick = onDismiss) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Close",
                            tint = TextGray
                        )
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                // TABS
                val tabs = listOf("USB Serial", "Manual Control", "ESP32 Code")
                TabRow(
                    selectedTabIndex = selectedTab,
                    containerColor = DashSurface,
                    contentColor = NeonCyan,
                    indicator = { tabPositions ->
                        TabRowDefaults.Indicator(
                            Modifier.tabIndicatorOffset(tabPositions[selectedTab]),
                            color = NeonCyan
                        )
                    }
                ) {
                    tabs.forEachIndexed { index, title ->
                        Tab(
                            selected = selectedTab == index,
                            onClick = { selectedTab = index },
                            text = {
                                Text(
                                    text = title,
                                    fontSize = 13.sp,
                                    fontWeight = if (selectedTab == index) FontWeight.Bold else FontWeight.Normal,
                                    color = if (selectedTab == index) NeonCyan else TextGray
                                )
                            }
                        )
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                // TAB CONTENT
                Box(modifier = Modifier.weight(1f)) {
                    when (selectedTab) {
                        0 -> UsbSerialTab(
                            usbStatus = usbStatus,
                            rawLog = rawLog,
                            isSimulating = isSimulating,
                            onScanUsb = onScanUsb,
                            onToggleSimulation = onToggleSimulation
                        )
                        1 -> ManualControlTab(
                            data = currentData,
                            onUpdateData = onUpdateManualData
                        )
                        2 -> Esp32CodeTab(context = context)
                    }
                }
            }
        }
    }
}

@Composable
private fun UsbSerialTab(
    usbStatus: String,
    rawLog: List<String>,
    isSimulating: Boolean,
    onScanUsb: () -> Unit,
    onToggleSimulation: (Boolean) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
    ) {
        // USB Connection Status Card
        Card(
            colors = CardDefaults.cardColors(containerColor = DashSurface),
            border = CardDefaults.outlinedCardBorder().copy(brush = androidx.compose.ui.graphics.SolidColor(DashSurfaceBorder)),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "Status Koneksi USB OTG Serial",
                    color = TextGray,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.height(4.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = usbStatus,
                        color = if (usbStatus.contains("Terhubung")) NeonGreen else NeonRed,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold
                    )

                    Button(
                        onClick = onScanUsb,
                        colors = ButtonDefaults.buttonColors(containerColor = GearBlue)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Refresh,
                            contentDescription = "Scan",
                            modifier = Modifier.padding(end = 4.dp)
                        )
                        Text("Scan USB OTG")
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Simulation Mode Toggle Card
        Card(
            colors = CardDefaults.cardColors(containerColor = DashSurface),
            border = CardDefaults.outlinedCardBorder().copy(brush = androidx.compose.ui.graphics.SolidColor(DashSurfaceBorder)),
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Mode Simulasi / Demo Physics",
                        color = TextWhite,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Jalankan animasi dashboard jika ESP32 belum terhubung",
                        color = TextGray,
                        fontSize = 11.sp
                    )
                }

                Switch(
                    checked = isSimulating,
                    onCheckedChange = onToggleSimulation,
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = NeonCyan,
                        checkedTrackColor = DashSurfaceBorder
                    )
                )
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Raw Incoming JSON Logs
        Text(
            text = "Data JSON Serial Diterima (Baud Rate 115200):",
            color = TextGray,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(140.dp)
                .clip(RoundedCornerShape(8.dp))
                .background(Color.Black)
                .border(1.dp, DashSurfaceBorder, RoundedCornerShape(8.dp))
                .padding(8.dp)
        ) {
            Column(modifier = Modifier.verticalScroll(rememberScrollState())) {
                if (rawLog.isEmpty()) {
                    Text(
                        text = "Menunggu data JSON dari ESP32 via Serial.println()...",
                        color = TextGray,
                        fontSize = 11.sp,
                        fontFamily = FontFamily.Monospace
                    )
                } else {
                    rawLog.forEach { line ->
                        Text(
                            text = "> $line",
                            color = NeonGreen,
                            fontSize = 11.sp,
                            fontFamily = FontFamily.Monospace
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ManualControlTab(
    data: DashboardData,
    onUpdateData: (DashboardData) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
    ) {
        Text(
            text = "Atur Parameter Dashboard Secara Manual:",
            color = TextGray,
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(8.dp))

        // 1. SPEED SLIDER
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(text = "Kecepatan: ${data.speed} km/h", color = TextWhite, fontSize = 13.sp, modifier = Modifier.width(160.dp))
            Slider(
                value = data.speed.toFloat(),
                onValueChange = { onUpdateData(data.copy(speed = it.toInt())) },
                valueRange = 0f..299f,
                colors = SliderDefaults.colors(thumbColor = NeonCyan, activeTrackColor = NeonCyan)
            )
        }

        // 2. RPM SLIDER
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(text = "RPM: ${data.rpm}", color = TextWhite, fontSize = 13.sp, modifier = Modifier.width(160.dp))
            Slider(
                value = data.rpm.toFloat(),
                onValueChange = { onUpdateData(data.copy(rpm = it.toInt())) },
                valueRange = 0f..12000f,
                colors = SliderDefaults.colors(thumbColor = NeonRed, activeTrackColor = NeonRed)
            )
        }

        // 3. GEAR SLIDER
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(text = "Gigi / Gear: ${if (data.gear == 0) "N" else data.gear}", color = TextWhite, fontSize = 13.sp, modifier = Modifier.width(160.dp))
            Slider(
                value = data.gear.toFloat(),
                onValueChange = { onUpdateData(data.copy(gear = it.toInt(), neutral = (it.toInt() == 0))) },
                valueRange = 0f..6f,
                steps = 5,
                colors = SliderDefaults.colors(thumbColor = GearBlue, activeTrackColor = GearBlue)
            )
        }

        // 4. TEMP & FUEL
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(text = "Suhu: ${data.temp.toInt()} °C", color = TextWhite, fontSize = 13.sp, modifier = Modifier.width(160.dp))
            Slider(
                value = data.temp.toFloat(),
                onValueChange = { onUpdateData(data.copy(temp = it.toDouble())) },
                valueRange = 20f..120f
            )
        }

        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(text = "Bensin: ${data.fuel.toInt()}%", color = TextWhite, fontSize = 13.sp, modifier = Modifier.width(160.dp))
            Slider(
                value = data.fuel.toFloat(),
                onValueChange = { onUpdateData(data.copy(fuel = it.toDouble())) },
                valueRange = 0f..100f
            )
        }

        Divider(color = DashSurfaceBorder, modifier = Modifier.padding(vertical = 8.dp))

        // TOGGLES FOR INDICATORS
        Text(text = "Indikator & Warning Lights:", color = TextGray, fontSize = 12.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(4.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = data.left, onCheckedChange = { onUpdateData(data.copy(left = it)) })
                    Text("Lampu Sen Kiri", color = TextWhite, fontSize = 12.sp)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = data.right, onCheckedChange = { onUpdateData(data.copy(right = it)) })
                    Text("Lampu Sen Kanan", color = TextWhite, fontSize = 12.sp)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = data.highbeam, onCheckedChange = { onUpdateData(data.copy(highbeam = it)) })
                    Text("Lampu Jauh (High Beam)", color = TextWhite, fontSize = 12.sp)
                }
            }

            Column {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = data.abs, onCheckedChange = { onUpdateData(data.copy(abs = it)) })
                    Text("Indikator ABS", color = TextWhite, fontSize = 12.sp)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = data.oil, onCheckedChange = { onUpdateData(data.copy(oil = it)) })
                    Text("Lampu Oli", color = TextWhite, fontSize = 12.sp)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = data.engine, onCheckedChange = { onUpdateData(data.copy(engine = it)) })
                    Text("Check Engine", color = TextWhite, fontSize = 12.sp)
                }
            }
        }
    }
}

@Composable
private fun Esp32CodeTab(context: Context) {
    val esp32Code = """
#include <Arduino.h>
#include <ArduinoJson.h> // Library ArduinoJson v6

void setup() {
  Serial.begin(115200); // Pastikan Baud Rate 115200
}

void loop() {
  StaticJsonDocument<256> doc;
  
  doc["speed"] = 135;
  doc["rpm"] = 6500;
  doc["gear"] = 6;
  doc["temp"] = 82;
  doc["fuel"] = 68;
  doc["volt"] = 12.8;
  doc["trip"] = 235.6;
  doc["odo"] = 12035;
  doc["left"] = false;
  doc["right"] = true;
  doc["highbeam"] = true;
  doc["neutral"] = false;
  doc["abs"] = true;
  doc["oil"] = false;
  doc["engine"] = false;
  doc["mode"] = "RACE";

  serializeJson(doc, Serial);
  Serial.println(); // Kirim karakter newline (\n) di akhir JSON
  delay(100);      // Kirim data setiap 100ms
}
    """.trimIndent()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Contoh Program Arduino / ESP32:",
                color = TextWhite,
                fontSize = 13.sp,
                fontWeight = FontWeight.Bold
            )

            OutlinedButton(
                onClick = {
                    val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                    val clip = ClipData.newPlainText("ESP32 Code", esp32Code)
                    clipboard.setPrimaryClip(clip)
                    Toast.makeText(context, "Kode ESP32 Berhasil Disalin!", Toast.LENGTH_SHORT).show()
                }
            ) {
                Icon(imageVector = Icons.Default.ContentCopy, contentDescription = "Copy", modifier = Modifier.padding(end = 4.dp))
                Text("Salin Kode")
            }
        }

        Spacer(modifier = Modifier.height(8.dp))

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(8.dp))
                .background(Color.Black)
                .border(1.dp, DashSurfaceBorder, RoundedCornerShape(8.dp))
                .padding(12.dp)
        ) {
            Text(
                text = esp32Code,
                color = NeonCyan,
                fontSize = 11.sp,
                fontFamily = FontFamily.Monospace
            )
        }
    }
}
