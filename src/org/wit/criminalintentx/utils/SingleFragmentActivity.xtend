package org.wit.criminalintentx.utils

import org.wit.criminalintentx.R
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentActivity

public abstract class SingleFragmentActivity extends FragmentActivity
{
 def abstract Fragment createFragment()

  override onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState)
    contentView  = R.layout.activity_fragment
    val manager  = supportFragmentManager
    var fragment = manager.findFragmentById(R.id.fragmentContainer)

    if (fragment == null)
    {
      fragment = createFragment
      manager.beginTransaction.add(R.id.fragmentContainer, fragment).commit
    }
  }
}
