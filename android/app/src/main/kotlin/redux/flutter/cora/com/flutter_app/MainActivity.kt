package redux.flutter.cora.com.flutter_app

import android.Manifest
import android.app.Dialog
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.util.Log
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.widget.Button
import android.widget.ImageView
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.BufferedOutputStream
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.lang.Exception
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat


class MainActivity : FlutterActivity() {
    var path = Environment.getExternalStorageDirectory().absolutePath
    override fun onCreate(savedInstanceState: Bundle?) {
        val CHANNEL = "samples.flutter.io/systemChannel"
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        MethodChannel(flutterView, CHANNEL).setMethodCallHandler(
                object : MethodCallHandler {
                    override fun onMethodCall(call: MethodCall, result: Result) {
                        if (call.method == "getVersion") { //获取版本号
                            Log.e("MainActivity", "param= " + call.argument<String>("param"))
//                            startActivity(Intent(this@MainActivity, TestActivity::class.java))
                            result.success(getVersion())
                        } else if (call.method == "imageChannel") {//显示图片
                            //获取二进制数据
                            val type = call.argument<Int>("type")
                            Log.e("MainActivity", "type=" + type)
                            val ba = call.argument<ByteArray>("value")
                            if (ba != null) {
                                test(ba)
                                initDialog(ba, result, type)
                            }
//                            startActivity(Intent(this@MainActivity, TestActivity::class.java))
                        } else {
                            result.notImplemented()
                        }
                    }
                })

        if (Build.VERSION.SDK_INT >= 23) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE), 1)
            } else {
            }
        }
    }

    //存入sd卡根目录,用于调试显示
    private fun test(byteArray: ByteArray) {
        try {
            var file = File(path + "/flutter_test.jpg");
            var fos = FileOutputStream(file);
            var bos = BufferedOutputStream(fos);
            bos.write(byteArray);
        } catch (e: Exception) {
            e.printStackTrace()
        }

    }

    //显示dialog
    private fun initDialog(byteArray: ByteArray, result: Result, type: Int?) {
        val dia = Dialog(this, R.style.AlertDialog_AppCompat)
        dia.setContentView(R.layout.activity_start_dialog);
        val imageView: ImageView = dia.findViewById(R.id.start_img)
        // 转换为Bitmap显示
        imageView.setImageBitmap(BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size))
        dia.setCanceledOnTouchOutside(true)
        val w: Window = dia.getWindow();
        val lp: WindowManager.LayoutParams = w.getAttributes();
        lp.x = 0
        lp.y = 40
        dia.onWindowAttributesChanged(lp);
        imageView.setOnClickListener(
                object : View.OnClickListener {
                    override fun onClick(v: View?) {
                        dia.dismiss()
                    }
                })
        val button: Button = dia.findViewById(R.id.button)
        button.setOnClickListener { v ->
            //传递原生图片数据到flutter显示
            if (type == 1) {
                result.success(getByteArray(R.mipmap.test))
            } else {
                result.success(getByteArray(R.mipmap.tess))
            }
            dia.dismiss()
        }
        dia.show()
    }

    //可以替换为真正获取的版本号
    private fun getVersion(): String {
        return "Android V3.0.2"
    }

    //获取本地图片二进制数据
    private fun getByteArray(id: Int): ByteArray {
        val bitmap: Bitmap = BitmapFactory.decodeResource(resources, id)
        val baos = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos)
        return baos.toByteArray()
    }
}
