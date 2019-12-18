package redux.flutter.cora.com.flutter_app

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.io.*
import java.lang.Exception


class TestActivity : Activity() {
    companion object {
        val BYTEARRAY: ByteArray = ByteArray(0)
    }

    var path = Environment.getExternalStorageDirectory().absolutePath
    @SuppressLint("WrongThread")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= 23) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE), 1)
                Log.e("dddd", "dddd1");
            } else {
                val bitmap: Bitmap = BitmapFactory.decodeResource(resources, R.mipmap.test)
                val baos = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos)
                test(baos.toByteArray())
            }
        }

//        test();

    }

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
}



