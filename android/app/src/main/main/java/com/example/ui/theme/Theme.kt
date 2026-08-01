package com.example.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val RacingDashboardColorScheme = darkColorScheme(
    primary = NeonCyan,
    onPrimary = DashBackground,
    secondary = NeonBlue,
    onSecondary = DashBackground,
    tertiary = NeonRed,
    background = DashBackground,
    onBackground = TextWhite,
    surface = DashSurface,
    onSurface = TextWhite,
    surfaceVariant = DashSurfaceBorder,
    onSurfaceVariant = TextGray
)

@Composable
fun DashboardTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = RacingDashboardColorScheme,
        typography = Typography,
        content = content
    )
}
