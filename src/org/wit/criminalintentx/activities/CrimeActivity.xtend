package org.wit.criminalintentx.activities

import java.util.UUID
import org.wit.criminalintentx.utils.SingleFragmentActivity
 
class CrimeActivity extends SingleFragmentActivity
{
  override createFragment()
  {
    val crimeId = intent.getSerializableExtra(CrimeFragment.EXTRA_CRIME_ID)  as UUID
    return CrimeFragment.newInstance(crimeId)
  }
}