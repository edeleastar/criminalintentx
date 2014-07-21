package org.wit.criminalintentx.activities

import java.util.ArrayList;
import java.util.UUID;
import org.wit.criminalintentx.R;
import org.wit.criminalintentx.model.Crime;
import org.wit.criminalintentx.model.CrimeLab;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;

class CrimePagerActivity extends FragmentActivity 
{
  var ViewPager mViewPager;

  override onCreate(Bundle savedInstanceState) 
  {
    super.onCreate(savedInstanceState)

    mViewPager = new ViewPager(this)
    mViewPager.id = R.id.viewPager
    setContentView(mViewPager)

    val ArrayList<Crime> crimes = CrimeLab.get(this).crimes

    val fm = getSupportFragmentManager
    mViewPager.adapter = new PagerAdapter(fm, crimes)

    val crimeId = intent.getSerializableExtra(CrimeFragment.EXTRA_CRIME_ID) as UUID
    for (var i = 0; i < crimes.size(); i++) 
    {
      if (crimes.get(i).id.equals(crimeId)) 
      {
        mViewPager.setCurrentItem(i)
        return
      }
    }
  }
}

class PagerAdapter extends FragmentStatePagerAdapter 
{
  var ArrayList<Crime> crimes

  new(FragmentManager fm, ArrayList<Crime> crimes) 
  {
    super(fm)
    this.crimes = crimes
  }

  override getItem(int pos) 
  {
    val crimeId = crimes.get(pos).id
    return CrimeFragment.newInstance(crimeId)
  }

  override getCount() 
  {
    return crimes.size
  }
}
