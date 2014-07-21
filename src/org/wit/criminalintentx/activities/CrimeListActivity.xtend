package org.wit.criminalintentx.activities

import org.wit.criminalintentx.utils.SingleFragmentActivity;

class CrimeListActivity extends SingleFragmentActivity
{
  override createFragment()
  {
    return new CrimeListFragment
  }
} 