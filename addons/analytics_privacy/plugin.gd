@tool
extends EditorPlugin

var exporter: EditorExportPlugin

func _enter_tree() -> void:
	exporter = PrivacyExport.new()
	add_export_plugin(exporter)

func _exit_tree() -> void:
	remove_export_plugin(exporter)

class PrivacyExport extends EditorExportPlugin:
	func _get_name() -> String:
		return "EquilibristaAnalyticsPrivacy"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_manifest_application_element_contents(_platform: EditorExportPlatform, _debug: bool) -> String:
		return """
<meta-data android:name="google_analytics_adid_collection_enabled" android:value="false"/>
<meta-data android:name="google_analytics_ssaid_collection_enabled" android:value="false"/>
<meta-data android:name="google_analytics_default_allow_ad_personalization_signals" android:value="false"/>
<meta-data android:name="google_analytics_default_allow_ad_storage" android:value="false"/>
<meta-data android:name="google_analytics_default_allow_ad_user_data" android:value="false"/>
<meta-data android:name="google_analytics_automatic_screen_reporting_enabled" android:value="false"/>
"""

	func _get_android_manifest_element_contents(_platform: EditorExportPlatform, _debug: bool) -> String:
		return """
<uses-permission android:name="com.google.android.gms.permission.AD_ID" tools:node="remove"/>
<uses-permission android:name="android.permission.ACCESS_ADSERVICES_AD_ID" tools:node="remove"/>
<uses-permission android:name="android.permission.ACCESS_ADSERVICES_ATTRIBUTION" tools:node="remove"/>
<uses-permission android:name="android.permission.ACCESS_ADSERVICES_TOPICS" tools:node="remove"/>
"""
