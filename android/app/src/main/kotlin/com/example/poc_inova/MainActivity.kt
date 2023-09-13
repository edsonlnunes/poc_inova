package com.example.poc_inova

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkCapabilities.NET_CAPABILITY_INTERNET
import android.net.NetworkCapabilities.TRANSPORT_WIFI
import android.net.NetworkRequest
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiManager
import android.net.wifi.WifiNetworkSpecifier
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PatternMatcher
import android.os.PatternMatcher.PATTERN_PREFIX
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val wifiChannel = "com.example.poc_inova/wifi"


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        var currentNetworkCallback: ConnectivityManager.NetworkCallback? = null

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            wifiChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "disconnectToWifi" -> {
                    val localCurrentNetworkCallback = currentNetworkCallback

                    if (localCurrentNetworkCallback != null) {
                        val connectivityManager =
                            context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                        connectivityManager.unregisterNetworkCallback(localCurrentNetworkCallback)
                        currentNetworkCallback = null
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            connectivityManager.bindProcessToNetwork(null)
                        }
                    }
                    result.success(true)
                }

                "connectToWiFi" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) { // api 29
                            val wifiManager =
                                applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

                            if (wifiManager.isWifiEnabled) {

                                val ssid = call.argument<String>("ssid")
                                val pass = call.argument<String>("pass")

                                val specifier = if (pass != null) WifiNetworkSpecifier.Builder()
                                    .setSsid(ssid!!).setWpa2Passphrase(pass)
                                    .build() else WifiNetworkSpecifier.Builder()
                                    .setSsid(ssid!!)
                                    .build()

                                val networkRequest = NetworkRequest.Builder()
                                    .addTransportType(TRANSPORT_WIFI)
                                    .removeCapability(NET_CAPABILITY_INTERNET)
                                    .setNetworkSpecifier(specifier)
                                    .build()


                                val connectivityManager =
                                    applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

                                val networkCallback =
                                    object : ConnectivityManager.NetworkCallback() {
                                        override fun onAvailable(@NonNull network: Network) {
                                            connectivityManager.bindProcessToNetwork(network)
                                            currentNetworkCallback = this
                                            Log.i("WIFI", "CONECTOU")
                                            Log.i("WIFI", network.toString())
                                            result.success(true)
                                        }

                                        override fun onUnavailable() {
                                            Log.i("WIFI", "NAO CONECTOU")
                                            result.success(false);
                                        }
                                    }

                                val handler = Handler(Looper.getMainLooper())

                                connectivityManager.requestNetwork(
                                    networkRequest,
                                    networkCallback,
                                    handler,
                                    60000
                                )
                            }
                        }
                    } catch (e: Exception) {
                        result.error("CONNECTION_ERROR", e.message, null)
                    }
                }

                else -> {
                    result.notImplemented();
                }
            }
        }
    }
}
