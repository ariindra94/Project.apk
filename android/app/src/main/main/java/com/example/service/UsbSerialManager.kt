package com.example.service

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.os.Build
import android.util.Log
import com.example.data.DashboardData
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.nio.charset.StandardCharsets

class UsbSerialManager(private val context: Context) {

    private val TAG = "UsbSerialManager"
    private val ACTION_USB_PERMISSION = "com.example.USB_PERMISSION"

    private val usbManager: UsbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager

    private val _connectionState = MutableStateFlow<String>("Terputus")
    val connectionState: StateFlow<String> = _connectionState.asStateFlow()

    private val _parsedData = MutableStateFlow<DashboardData?>(null)
    val parsedData: StateFlow<DashboardData?> = _parsedData.asStateFlow()

    private val _rawLog = MutableStateFlow<List<String>>(emptyList())
    val rawLog: StateFlow<List<String>> = _rawLog.asStateFlow()

    private var usbConnection: UsbDeviceConnection? = null
    private var usbInterface: UsbInterface? = null
    private var inEndpoint: UsbEndpoint? = null
    private var readJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.IO)

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                ACTION_USB_PERMISSION -> {
                    synchronized(this) {
                        val device: UsbDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
                        } else {
                            @Suppress("DEPRECATION")
                            intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                        }

                        if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                            device?.let { connectToDevice(it) }
                        } else {
                            _connectionState.value = "Izin USB Ditolak"
                        }
                    }
                }
                UsbManager.ACTION_USB_DEVICE_ATTACHED -> {
                    scanAndConnect()
                }
                UsbManager.ACTION_USB_DEVICE_DETACHED -> {
                    disconnect()
                    _connectionState.value = "ESP32 Terputus"
                }
            }
        }
    }

    init {
        val filter = IntentFilter().apply {
            addAction(ACTION_USB_PERMISSION)
            addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
            addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(usbReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            context.registerReceiver(usbReceiver, filter)
        }
    }

    fun scanAndConnect() {
        val deviceList = usbManager.deviceList
        if (deviceList.isEmpty()) {
            _connectionState.value = "Tidak Ada Device USB"
            return
        }

        // Find first available serial device
        val device = deviceList.values.firstOrNull() ?: return

        if (!usbManager.hasPermission(device)) {
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val permissionIntent = PendingIntent.getBroadcast(
                context, 0, Intent(ACTION_USB_PERMISSION), flags
            )
            _connectionState.value = "Meminta Izin USB..."
            usbManager.requestPermission(device, permissionIntent)
        } else {
            connectToDevice(device)
        }
    }

    private fun connectToDevice(device: UsbDevice) {
        try {
            _connectionState.value = "Menghubungkan ke ${device.deviceName}..."
            
            // Find appropriate interface and endpoint
            var selectedInterface: UsbInterface? = null
            var selectedEndpoint: UsbEndpoint? = null

            for (i in 0 until device.interfaceCount) {
                val iface = device.getInterface(i)
                for (j in 0 until iface.endpointCount) {
                    val ep = iface.getEndpoint(j)
                    if (ep.direction == UsbConstants.USB_DIR_IN) {
                        selectedInterface = iface
                        selectedEndpoint = ep
                        break
                    }
                }
                if (selectedEndpoint != null) break
            }

            if (selectedInterface == null || selectedEndpoint == null) {
                _connectionState.value = "Endpoint Serial Tidak Ditemukan"
                return
            }

            val connection = usbManager.openDevice(device)
            if (connection == null) {
                _connectionState.value = "Gagal Membuka USB Connection"
                return
            }

            if (!connection.claimInterface(selectedInterface, true)) {
                _connectionState.value = "Gagal Claim Interface USB"
                connection.close()
                return
            }

            // Set baud rate if CDC / standard control transfer (115200 8N1)
            val baudRate = 115200
            val lineCoding = byteArrayOf(
                (baudRate and 0xFF).toByte(),
                (baudRate shr 8 and 0xFF).toByte(),
                (baudRate shr 16 and 0xFF).toByte(),
                (baudRate shr 24 and 0xFF).toByte(),
                0x00, // 1 stop bit
                0x00, // parity none
                0x08  // 8 data bits
            )
            try {
                connection.controlTransfer(0x21, 0x20, 0, 0, lineCoding, lineCoding.size, 1000)
                // Set DTR / RTS high
                connection.controlTransfer(0x21, 0x22, 0x03, 0, null, 0, 1000)
            } catch (e: Exception) {
                Log.w(TAG, "Control transfer line coding warning: ${e.message}")
            }

            usbConnection = connection
            usbInterface = selectedInterface
            inEndpoint = selectedEndpoint

            _connectionState.value = "Terhubung (${device.deviceName})"
            startReading()

        } catch (e: Exception) {
            Log.e(TAG, "Error connecting USB", e)
            _connectionState.value = "Error: ${e.localizedMessage}"
        }
    }

    private fun startReading() {
        readJob?.cancel()
        readJob = scope.launch {
            val buffer = ByteArray(1024)
            val stringBuilder = StringBuilder()

            while (usbConnection != null && inEndpoint != null) {
                val bytesRead = usbConnection?.bulkTransfer(inEndpoint, buffer, buffer.size, 500) ?: -1
                if (bytesRead > 0) {
                    val chunk = String(buffer, 0, bytesRead, StandardCharsets.UTF_8)
                    stringBuilder.append(chunk)

                    var lineEnd = stringBuilder.indexOf("\n")
                    while (lineEnd != -1) {
                        val line = stringBuilder.substring(0, lineEnd).trim()
                        stringBuilder.delete(0, lineEnd + 1)

                        if (line.isNotEmpty()) {
                            addLog(line)
                            val data = DashboardData.fromJson(line)
                            if (data != null) {
                                _parsedData.value = data
                            }
                        }
                        lineEnd = stringBuilder.indexOf("\n")
                    }
                } else {
                    delay(50)
                }
            }
        }
    }

    private fun addLog(line: String) {
        val currentList = _rawLog.value.toMutableList()
        if (currentList.size > 20) {
            currentList.removeAt(0)
        }
        currentList.add(line)
        _rawLog.value = currentList
    }

    fun disconnect() {
        readJob?.cancel()
        readJob = null
        try {
            usbInterface?.let { usbConnection?.releaseInterface(it) }
            usbConnection?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting", e)
        }
        usbConnection = null
        usbInterface = null
        inEndpoint = null
        _connectionState.value = "Terputus"
    }

    fun unregister() {
        disconnect()
        try {
            context.unregisterReceiver(usbReceiver)
        } catch (e: Exception) {
            // ignore
        }
    }
}
