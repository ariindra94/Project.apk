package com.example.ui.components

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.Highlight
import androidx.compose.material.icons.filled.OilBarrel
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.DashboardData
import com.example.ui.theme.DashSurface
import com.example.ui.theme.DashSurfaceBorder
import com.example.ui.theme.IndicatorInactive
import com.example.ui.theme.NeonBlue
import com.example.ui.theme.NeonCyan
import com.example.ui.theme.NeonGreen
import com.example.ui.theme.NeonRed
import com.example.ui.theme.NeonYellow
import com.example.ui.theme.TextGray
import com.example.ui.theme.TextWhite

@Composable
fun LeftIndicatorPanel(
    data: DashboardData,
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition(label = "BlinkLeft")
    val blinkAlpha by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 0.2f,
        animationSpec = infiniteRepeatable(
            animation = tween(400, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "AlphaLeft"
    )

    Column(
        modifier = modifier
            .fillMaxHeight()
            .padding(12.dp),
        verticalArrangement = Arrangement.SpaceEvenly,
        horizontalAlignment = Alignment.Start
    ) {
        // 1. LEFT TURN SIGNAL BADGE
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(DashSurface)
                .border(1.dp, DashSurfaceBorder, RoundedCornerShape(12.dp))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            val isLeftActive = data.left
            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = "Left Turn Signal",
                tint = if (isLeftActive) NeonGreen else IndicatorInactive,
                modifier = Modifier
                    .size(24.dp)
                    .alpha(if (isLeftActive) blinkAlpha else 0.3f)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "LEFT TURN",
                color = if (isLeftActive) NeonGreen else TextGray.copy(alpha = 0.4f),
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
        }

        // 2. HIGH BEAM
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(DashSurface)
                .border(1.dp, DashSurfaceBorder, RoundedCornerShape(12.dp))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            val isActive = data.highbeam
            Icon(
                imageVector = Icons.Default.Highlight,
                contentDescription = "High Beam",
                tint = if (isActive) NeonBlue else IndicatorInactive,
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "HIGH BEAM",
                color = if (isActive) TextWhite else TextGray.copy(alpha = 0.4f),
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
        }

        // 3. NEUTRAL & GEAR STATUS
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(DashSurface)
                .border(1.dp, DashSurfaceBorder, RoundedCornerShape(12.dp))
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            val isActive = data.neutral || data.gear == 0
            Box(
                modifier = Modifier
                    .size(20.dp)
                    .clip(CircleShape)
                    .background(if (isActive) NeonGreen else IndicatorInactive),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "N",
                    color = if (isActive) Color.Black else TextGray,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Black
                )
            }
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "NEUTRAL",
                color = if (isActive) NeonGreen else TextGray.copy(alpha = 0.4f),
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
        }

        // 4. ABS & ENGINE STATUS TILES
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // ABS
            val isAbs = data.abs
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(12.dp))
                    .background(DashSurface)
                    .border(
                        1.dp,
                        if (isAbs) NeonYellow else DashSurfaceBorder,
                        RoundedCornerShape(12.dp)
                    )
                    .padding(vertical = 8.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "ABS",
                    color = if (isAbs) NeonYellow else TextGray.copy(alpha = 0.4f),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Black
                )
            }

            // OIL
            val isOil = data.oil
            Box(
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(12.dp))
                    .background(DashSurface)
                    .border(
                        1.dp,
                        if (isOil) NeonRed else DashSurfaceBorder,
                        RoundedCornerShape(12.dp)
                    )
                    .padding(vertical = 8.dp),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.OilBarrel,
                    contentDescription = "Oil Warning",
                    tint = if (isOil) NeonRed else IndicatorInactive,
                    modifier = Modifier.size(18.dp)
                )
            }
        }

        // 5. CHECK ENGINE
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(DashSurface)
                .border(
                    1.dp,
                    if (data.engine) NeonYellow else DashSurfaceBorder,
                    RoundedCornerShape(12.dp)
                )
                .padding(horizontal = 10.dp, vertical = 6.dp)
        ) {
            val isActive = data.engine
            Icon(
                imageVector = Icons.Default.Build,
                contentDescription = "Check Engine",
                tint = if (isActive) NeonYellow else IndicatorInactive,
                modifier = Modifier.size(18.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "ENGINE CHECK",
                color = if (isActive) NeonYellow else TextGray.copy(alpha = 0.4f),
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.sp
            )
        }
    }
}

