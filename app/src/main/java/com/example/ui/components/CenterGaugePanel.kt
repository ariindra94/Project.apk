package com.example.ui.components

import android.graphics.Paint
import android.graphics.Typeface
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.DashboardData
import com.example.ui.theme.DashSurface
import com.example.ui.theme.DashSurfaceBorder
import com.example.ui.theme.NeonCyan
import com.example.ui.theme.NeonRed
import com.example.ui.theme.TextGray
import com.example.ui.theme.TextMuted
import com.example.ui.theme.TextWhite
import kotlin.math.cos
import kotlin.math.sin

@Composable
fun CenterGaugePanel(
    data: DashboardData,
    onSelectMode: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        // 1. TACHOMETER CANVAS ARC & TICKS
        Canvas(modifier = Modifier.fillMaxSize()) {
            val canvasWidth = size.width
            val canvasHeight = size.height

            val centerX = canvasWidth / 2f
            val centerY = canvasHeight / 2f + 8f
            val radius = (canvasWidth.coerceAtMost(canvasHeight) * 0.43f)

            val startAngle = 145f
            val sweepAngle = 250f
            val maxRpm = 12000f

            // Outer bezel track arc
            drawArc(
                color = Color.White.copy(alpha = 0.08f),
                startAngle = startAngle,
                sweepAngle = sweepAngle,
                useCenter = false,
                topLeft = Offset(centerX - radius, centerY - radius),
                size = Size(radius * 2, radius * 2),
                style = Stroke(width = 16f, cap = StrokeCap.Round)
            )

            // Dynamic Active RPM Arc with Cyan Glow
            val currentRpm = data.rpm.toFloat().coerceIn(0f, maxRpm)
            val currentSweep = (currentRpm / maxRpm) * sweepAngle

            if (currentSweep > 0f) {
                val rpmGradient = Brush.sweepGradient(
                    0.0f to NeonCyan,
                    0.7f to NeonCyan,
                    0.85f to NeonRed,
                    1.0f to NeonRed,
                    center = Offset(centerX, centerY)
                )

                // Background Glow Arc
                drawArc(
                    brush = rpmGradient,
                    startAngle = startAngle,
                    sweepAngle = currentSweep,
                    useCenter = false,
                    topLeft = Offset(centerX - radius, centerY - radius),
                    size = Size(radius * 2, radius * 2),
                    style = Stroke(width = 22f, cap = StrokeCap.Round),
                    alpha = 0.35f
                )

                // Core Bright Arc
                drawArc(
                    brush = rpmGradient,
                    startAngle = startAngle,
                    sweepAngle = currentSweep,
                    useCenter = false,
                    topLeft = Offset(centerX - radius, centerY - radius),
                    size = Size(radius * 2, radius * 2),
                    style = Stroke(width = 14f, cap = StrokeCap.Round)
                )
            }

            // Ticks and Labels 0..12
            val textPaint = Paint().apply {
                color = android.graphics.Color.parseColor("#94A3B8")
                textSize = 24f
                textAlign = Paint.Align.CENTER
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            }

            val redlinePaint = Paint().apply {
                color = android.graphics.Color.parseColor("#EF4444")
                textSize = 24f
                textAlign = Paint.Align.CENTER
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            }

            for (i in 0..12) {
                val tickFraction = i / 12f
                val angleDeg = startAngle + tickFraction * sweepAngle
                val angleRad = Math.toRadians(angleDeg.toDouble())

                val outerX = centerX + cos(angleRad).toFloat() * (radius + 14f)
                val outerY = centerY + sin(angleRad).toFloat() * (radius + 14f)

                val innerX = centerX + cos(angleRad).toFloat() * (radius - 20f)
                val innerY = centerY + sin(angleRad).toFloat() * (radius - 20f)

                val isRedline = i >= 9
                val tickColor = if (isRedline) NeonRed else Color(0x6694A3B8)

                drawLine(
                    color = tickColor,
                    start = Offset(innerX, innerY),
                    end = Offset(outerX, outerY),
                    strokeWidth = if (i % 2 == 0) 4f else 2f
                )

                // Labeled numbers for 0, 2, 4, 6, 8, 10, 12
                if (i % 2 == 0) {
                    val textRadius = radius - 38f
                    val textX = centerX + cos(angleRad).toFloat() * textRadius
                    val textY = centerY + sin(angleRad).toFloat() * textRadius + 8f

                    drawContext.canvas.nativeCanvas.drawText(
                        "$i",
                        textX,
                        textY,
                        if (isRedline) redlinePaint else textPaint
                    )
                }
            }

            // x1000 RPM header
            val labelPaint = Paint().apply {
                color = android.graphics.Color.parseColor("#64748B")
                textSize = 20f
                textAlign = Paint.Align.CENTER
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.ITALIC)
            }
            drawContext.canvas.nativeCanvas.drawText(
                "x1000 RPM",
                centerX,
                centerY - radius + 18f,
                labelPaint
            )
        }

        // 2. CENTER CONTENT: GEAR, SPEEDOMETER
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(top = 10.dp)
        ) {
            // GEAR LABEL & LARGE GEARED DIGIT
            Text(
                text = "GEAR",
                color = TextGray,
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 2.sp
            )
            Text(
                text = if (data.gear == 0 || data.neutral) "N" else "${data.gear}",
                color = NeonCyan,
                fontSize = 38.sp,
                fontWeight = FontWeight.Black,
                fontFamily = FontFamily.Monospace,
                lineHeight = 38.sp
            )

            Spacer(modifier = Modifier.height(4.dp))

            // SPEEDOMETER VALUE
            Row(
                verticalAlignment = Alignment.Bottom,
                horizontalArrangement = Arrangement.Center
            ) {
                Text(
                    text = "${data.speed}",
                    color = TextWhite,
                    fontSize = 64.sp,
                    fontWeight = FontWeight.Black,
                    fontStyle = FontStyle.Italic,
                    fontFamily = FontFamily.SansSerif,
                    letterSpacing = (-2).sp,
                    lineHeight = 64.sp
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "km/h",
                    color = TextGray,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    fontStyle = FontStyle.Italic,
                    modifier = Modifier.padding(bottom = 8.dp)
                )
            }
        }

        // 3. BOTTOM RIDING MODES BAR
        Row(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 6.dp)
                .clip(RoundedCornerShape(20.dp))
                .background(Color.Black.copy(alpha = 0.6f))
                .border(1.dp, DashSurfaceBorder, RoundedCornerShape(20.dp))
                .padding(horizontal = 10.dp, vertical = 4.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            val modes = listOf("RACE", "SPORT", "STREET", "RAIN")
            val currentMode = data.mode.ifEmpty { "RACE" }

            modes.forEach { m ->
                val isSelected = currentMode.equals(m, ignoreCase = true)
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(12.dp))
                        .clickable { onSelectMode(m) }
                        .then(
                            if (isSelected) Modifier
                                .background(NeonCyan.copy(alpha = 0.15f))
                                .border(1.dp, NeonCyan, RoundedCornerShape(12.dp))
                                .padding(horizontal = 10.dp, vertical = 3.dp)
                            else Modifier.padding(horizontal = 6.dp, vertical = 3.dp)
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = m,
                        color = if (isSelected) NeonCyan else TextMuted,
                        fontSize = 11.sp,
                        fontWeight = if (isSelected) FontWeight.Black else FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                }
            }
        }
    }
}

