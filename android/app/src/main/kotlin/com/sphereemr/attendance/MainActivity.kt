package com.sphereemr.attendance

import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Main Activity with Kiosk Mode (Lock Task Mode) support
 * 
 * When configured as Device Owner, this enables:
 * - App launches at boot
 * - No system UI (status bar, navigation)
 * - No app switching
 * - Cannot exit without admin action
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "com.sphereemr.attendance/kiosk"
    }

    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var adminComponentName: ComponentName

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize device policy manager
        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        adminComponentName = ComponentName(this, AttendanceDeviceAdminReceiver::class.java)
        
        // Set up immersive mode (hide system UI)
        hideSystemUI()
        
        // Keep screen on
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        
        // Start kiosk mode if device owner
        if (isDeviceOwner()) {
            startKioskMode()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up method channel for Flutter communication
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isDeviceOwner" -> {
                    result.success(isDeviceOwner())
                }
                "isKioskModeActive" -> {
                    result.success(isKioskModeActive())
                }
                "startKioskMode" -> {
                    val success = startKioskMode()
                    result.success(success)
                }
                "stopKioskMode" -> {
                    // No PIN required - exit kiosk directly
                    stopKioskMode()
                    result.success(true)
                }
                "getKioskStatus" -> {
                    result.success(mapOf(
                        "isDeviceOwner" to isDeviceOwner(),
                        "isKioskActive" to isKioskModeActive(),
                        "deviceModel" to Build.MODEL,
                        "androidVersion" to Build.VERSION.SDK_INT
                    ))
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Check if app is set as Device Owner
     */
    private fun isDeviceOwner(): Boolean {
        return devicePolicyManager.isDeviceOwnerApp(packageName)
    }

    /**
     * Check if Lock Task Mode is currently active
     */
    private fun isKioskModeActive(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            activityManager.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
        } else {
            @Suppress("DEPRECATION")
            activityManager.isInLockTaskMode
        }
    }

    /**
     * Start Lock Task Mode (Kiosk Mode)
     */
    private fun startKioskMode(): Boolean {
        return try {
            if (isDeviceOwner()) {
                // Set this package as the lock task package
                devicePolicyManager.setLockTaskPackages(adminComponentName, arrayOf(packageName))
                
                // Configure lock task features (what's allowed in kiosk mode)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    devicePolicyManager.setLockTaskFeatures(
                        adminComponentName,
                        DevicePolicyManager.LOCK_TASK_FEATURE_NONE
                        // Add features if needed:
                        // or DevicePolicyManager.LOCK_TASK_FEATURE_SYSTEM_INFO
                        // or DevicePolicyManager.LOCK_TASK_FEATURE_NOTIFICATIONS
                    )
                }
                
                // Start lock task mode
                startLockTask()
                Log.d(TAG, "Kiosk mode started successfully")
                true
            } else {
                Log.w(TAG, "Cannot start kiosk mode - not device owner")
                false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start kiosk mode", e)
            false
        }
    }

    /**
     * Stop Lock Task Mode (exit kiosk)
     */
    private fun stopKioskMode() {
        try {
            stopLockTask()
            Log.d(TAG, "Kiosk mode stopped")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop kiosk mode", e)
        }
    }

    /**
     * Hide system UI for immersive full-screen experience
     */
    private fun hideSystemUI() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.let { controller ->
                controller.hide(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
                controller.systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_FULLSCREEN
            )
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            hideSystemUI()
        }
    }

    override fun onResume() {
        super.onResume()
        hideSystemUI()
        
        // Re-enable kiosk mode if device owner and not already in kiosk
        if (isDeviceOwner() && !isKioskModeActive()) {
            startKioskMode()
        }
    }
}
