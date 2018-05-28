package io.predict.android.sdk.react

import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import predictio.sdk.PowerMode
import predictio.sdk.PredictIOError
import predictio.sdk.PredictIo
import predictio.sdk.protocols.PredictIoCallback
import predictio.sdk.services.public_imports.PredictIOTripEventType
import java.text.SimpleDateFormat
import java.util.*

const val TRIP_EVENT = "PredictIOTripEvent"

class RNPredictIOModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    @ReactMethod
    fun start(apiKey: String, powerMode: String = "lowPower", callback: Callback) {
        val _powerMode = when (powerMode) {
            "highPower" -> PowerMode.HIGH_POWER
            "lowPower" -> PowerMode.LOW_POWER
            else -> {
                PowerMode.LOW_POWER
            }
        }
        PredictIo.start(object : PredictIoCallback {
            override fun error(error: PredictIOError?) {
                val jsError: String = when (error) {
                    null -> "success"
                    PredictIOError.invalidKey -> "invalidKey"
                    PredictIOError.killSwitch -> "killSwitch"
                    PredictIOError.locationPermission -> "locationPermission"
                    PredictIOError.wifiDisabled -> "wifiDisabled"
                    PredictIOError.invalidPredictIoKey -> "invalidKey"
                    PredictIOError.unknown -> "unknown"
                }
                callback.invoke(jsError)
            }
        }, apiKey = apiKey, powerMode = _powerMode)

        listenForSDKEvents()
    }

    private fun listenForSDKEvents() {
        PredictIo.notify(PredictIOTripEventType.ANY, {
            val jsType: String = when (it.type) {
                PredictIOTripEventType.ANY -> "any"
                PredictIOTripEventType.ARRIVAL -> "arrival"
                PredictIOTripEventType.DEPARTURE -> "departure"
                PredictIOTripEventType.ENROUTE -> "enroute"
                PredictIOTripEventType.STILL -> "still"
            }

            val timezone = TimeZone.getTimeZone("UTC")
            val dateFormatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'")
            dateFormatter.timeZone = timezone
            val jsDate = dateFormatter.format(it.timestamp)

            val mapEvent = WritableNativeMap()
            mapEvent.putString("type", jsType)
            mapEvent.putString("timestamp", jsDate)

            val coordinateMap = WritableNativeMap()
            it.coordinate?.longitude?.let { it1 -> coordinateMap.putDouble("longitude", it1) }
            it.coordinate?.latitude?.let { it1 -> coordinateMap.putDouble("latitude", it1) }
            mapEvent.putMap("coordinate", coordinateMap)

            this.reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                    .emit(TRIP_EVENT, mapEvent)
        })
    }

    @ReactMethod
    fun setCustomParameter(params: Map<String, String>) {
        PredictIo.setCustomParameter(params = params)
    }

    @ReactMethod
    fun setWebhookURL(url: String) {
        PredictIo.setWebHookURL(url = url)
    }

    override fun getConstants(): MutableMap<String, Any> {
        return mapOf(
                "versionNumber" to "5.1.0-beta",
                "buildNumber" to 0
        ) as MutableMap<String, Any>
    }

    override fun getName(): String {
        return "PredictIO"
    }
}
