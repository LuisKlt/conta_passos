class MainActivity : FlutterActivity() {
    private lateinit var permissionLauncher: ActivityResultLauncher<Set<Permission>>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        permissionLauncher = registerForActivityResult(RequestHealthPermissions()) { granted ->
            Log.d("PERMISSION_RESULT", "Permissões concedidas: $granted")
        }

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.seuapp.health")
            .setMethodCallHandler { call, result ->
                if (call.method == "requestPermissions") {
                    val permissions = setOf(
                        HealthPermission.getReadPermission(StepsRecord::class)
                    )
                    permissionLauncher.launch(permissions)
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
    }
}
