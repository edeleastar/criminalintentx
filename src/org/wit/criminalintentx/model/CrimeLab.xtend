package org.wit.criminalintentx.model

import java.util.ArrayList;
import java.util.UUID;

import android.content.Context;
import android.util.Log;

class CrimeLab
{
  val static TAG      = "CrimeLab"
  val static FILENAME = "crimes.json"
  var static CrimeLab sCrimeLab

  var ArrayList<Crime>             mCrimes
  var CriminalIntentJSONSerializer mSerializer
  var Context                      mAppContext

  new(Context appContext)
  {
    mAppContext = appContext
    mSerializer = new CriminalIntentJSONSerializer(mAppContext, FILENAME)

    try
    {
      mCrimes = mSerializer.loadCrimes
    }
    catch (Exception e)
    {
      mCrimes = new ArrayList<Crime>()
      Log.e(TAG, "Error loading crimes: ", e)
    }
  }

  def static CrimeLab get(Context c)
  {
    if (sCrimeLab == null)
    {
      sCrimeLab = new CrimeLab(c.getApplicationContext())
    }
    sCrimeLab
  }

  def getCrime(UUID id)
  {
    for (Crime c : mCrimes)
    {
      if (c.id.equals(id))
        return c
    }
    return null
  }

  def addCrime(Crime c)
  {
    mCrimes.add(c)
    saveCrimes
  }

  def ArrayList<Crime> getCrimes()
  {
    return mCrimes
  }

  def deleteCrime(Crime c)
  {
    mCrimes.remove(c)
    saveCrimes
  }

  def boolean saveCrimes()
  {
    try
    {
      mSerializer.saveCrimes(mCrimes)
      Log.d(TAG, "crimes saved to file")
      true
    }
    catch (Exception e)
    {
      Log.e(TAG, "Error saving crimes: " + e)
      false
    }
  }
}

