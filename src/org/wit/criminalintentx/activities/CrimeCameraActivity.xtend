package org.wit.criminalintentx.activities

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.Window;
import android.view.WindowManager
import org.wit.criminalintentx.utils.SingleFragmentActivity

class CrimeCameraActivity extends SingleFragmentActivity
{
  override onCreate(Bundle savedInstanceState)
  {
    // hide the window title.
    requestWindowFeature(Window.FEATURE_NO_TITLE)
    // hide the status bar and other OS-level chrome
    window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
    super.onCreate(savedInstanceState)
  }

  override Fragment createFragment()
  {
    return new CrimeCameraFragment
  }
}
