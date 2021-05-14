package com.nordicdfuexample;

import android.content.Context;
import android.content.ContextWrapper;
import android.content.res.AssetManager;
import android.os.Bundle;
import com.facebook.react.ReactActivity;
import com.facebook.react.ReactActivityDelegate;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import javax.annotation.Nullable;

public class MainActivity extends ReactActivity {

  /**
   * Returns the name of the main component registered from JavaScript. This is used to schedule
   * rendering of the component.
   */
  @Override
  protected String getMainComponentName() {
    return "NordicDFUExample";
  }

  /**
   * Called at construction time, override if you have a custom delegate
   * implementation.
   */
  protected ReactActivityDelegate createReactActivityDelegate() {
    return new MainActivityDelegate(this, getMainComponentName());
  }

  class MainActivityDelegate extends ReactActivityDelegate {
    public MainActivityDelegate(ReactActivity activity,
                                @Nullable String mainComponentName) {
      super(activity, mainComponentName);
    }
  
    private void copyInputStreamToFile(InputStream in, File file) {
      OutputStream out = null;

      try {
        if (file.exists()) {
          file.delete();
        }
        out = new FileOutputStream(file);
        byte[] buf = new byte[1024];
        int len;
        while ((len = in.read(buf)) > 0) {
          out.write(buf, 0, len);
        }
      } catch (Exception e) {
        e.printStackTrace();
      } finally {
        // Ensure that the InputStreams are closed even if there's an exception.
        try {
          if (out != null) {
            out.close();
          }

          // If you want to close the "in" InputStream yourself then remove this
          // from here but ensure that you close it yourself eventually.
          in.close();
        } catch (IOException e) {
          e.printStackTrace();
        }
      }
    }

    private String copyDfuFirmware(String filename) {
      AssetManager assetManager = getAssets();
      try {
        InputStream in = assetManager.open("firmware/" + filename);
        ContextWrapper cw = new ContextWrapper(getApplicationContext());
        File outDir = cw.getDir("firmware", Context.MODE_PRIVATE);
        File outFile = new File(outDir, filename);
        copyInputStreamToFile(in, outFile);
        return outFile.getAbsolutePath();
      } catch (IOException e) {
        e.printStackTrace();
      }
      return "";
    }

    @Nullable
    @Override
    protected Bundle getLaunchOptions() {

      Bundle options = new Bundle();
      String path = copyDfuFirmware("app.zip");
      options.putString("firmwarePath", path);

      return options;
    }

  }
}
