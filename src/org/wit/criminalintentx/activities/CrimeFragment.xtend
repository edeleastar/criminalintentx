package org.wit.criminalintentx.activities

import java.util.Date;
import java.util.UUID;
import org.wit.criminalintentx.R;
import org.wit.criminalintentx.model.Crime
import org.wit.criminalintentx.model.CrimeLab
import org.wit.criminalintentx.utils.DatePickerFragment;
import android.content.Intent;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.support.v4.app.Fragment;
import android.support.v4.app.NavUtils;
import android.text.Editable;
import android.text.format.DateFormat;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import org.wit.criminalintentx.utils.TextWatcherAdapter

public class CrimeFragment extends Fragment
{
  public val static String EXTRA_CRIME_ID = "criminalintent.CRIME_ID"
  
  val static DIALOG_DATE     = "date"
  val static REQUEST_DATE    = 0
  val static REQUEST_CONTACT = 2
  
  var Crime       mCrime
  var EditText    mTitleField
  var Button      mDateButton
  var CheckBox    mSolvedCheckBox
  var Button      mSuspectButton
  var Button      reportButton
  
  var titleChanged = 
  [ 
    Editable text |
    mCrime.title = text.toString
  ]  
  
  var solvedChecked =
  [ 
    CompoundButton buttonView, boolean isChecked |
    mCrime.solved = isChecked
  ] 

  var dateClicked =
  [
    val fm = activity.supportFragmentManager
    val dialog = DatePickerFragment.newInstance(mCrime.date)
    dialog.setTargetFragment(CrimeFragment.this, REQUEST_DATE)
    dialog.show(fm, DIALOG_DATE)
  ]
  
  var suspectClicked =
  [
    val i = new Intent(Intent.ACTION_PICK, ContactsContract.Contacts.CONTENT_URI)
    startActivityForResult(i, REQUEST_CONTACT)
  ]
  
  var reportClicked =
  [
    var i = new Intent(Intent.ACTION_SEND)
    i.type = "text/plain"
    i.putExtra(Intent.EXTRA_TEXT, crimeReport)
    i.putExtra(Intent.EXTRA_SUBJECT, getString(R.string.crime_report_subject))
    i = Intent.createChooser(i, getString(R.string.send_report))
    startActivity(i)
  ]
  
  def static CrimeFragment newInstance(UUID crimeId)
  {
    val args = new Bundle
    args.putSerializable(EXTRA_CRIME_ID, crimeId)

    var fragment = new CrimeFragment
    fragment.arguments = args
    fragment
  }

  override onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState)

    val crimeId = arguments.getSerializable(EXTRA_CRIME_ID) as UUID
    mCrime = CrimeLab.get(activity).getCrime(crimeId)
    hasOptionsMenu = true
  }

 override onCreateView(LayoutInflater inflater, ViewGroup parent, Bundle savedInstanceState)
  {
    val v = inflater.inflate(R.layout.fragment_crime, parent, false)
    activity.actionBar.displayHomeAsUpEnabled = true

    mTitleField     = v.findViewById(R.id.crime_title)         as EditText   
    mSolvedCheckBox = v.findViewById(R.id.crime_solved)        as CheckBox
    mDateButton     = v.findViewById(R.id.crime_date)          as Button
    mSuspectButton  = v.findViewById(R.id.crime_suspectButton) as Button
    reportButton    = v.findViewById(R.id.crime_reportButton)  as Button

    mTitleField.text        = mCrime.title
    mSolvedCheckBox.checked = mCrime.solved
    mDateButton.text        = mCrime.date.toString
    if (mCrime.suspect != null)
    {
      mSuspectButton.text = mCrime.suspect
    }

    mTitleField.addTextChangedListener(new TextWatcherAdapter(titleChanged))
    mSolvedCheckBox.onCheckedChangeListener = solvedChecked
    mDateButton.onClickListener             = dateClicked
    mSuspectButton.onClickListener          = suspectClicked    
    reportButton.onClickListener            = reportClicked
    v
   }

  override onStop()
  {
    super.onStop
  }
  
  override onStart()
  {
    super.onStart
  }
  
  override onPause()
  {
    super.onPause
    CrimeLab.get(activity).saveCrimes
  }

  override onActivityResult(int requestCode, int resultCode, Intent data)
  {
    switch (requestCode)
    {
      case REQUEST_DATE : 
      {
        mCrime.date      = data.getSerializableExtra(DatePickerFragment.EXTRA_DATE) as Date
        mDateButton.text = mCrime.date.toString
      }
      case REQUEST_CONTACT :                  
      {
        val contactUri = data.data
        val String[] queryFields = #[ContactsContract.Contacts.DISPLAY_NAME_PRIMARY]
        val c = activity.contentResolver.query(contactUri, queryFields, null, null, null)

        if (c.count > 0)
        {
          c.moveToFirst
          mCrime.suspect      = c.getString(0)
          mSuspectButton.text = c.getString(0)
        }
        c.close
      }                
    }
  }

  def String getCrimeReport()
  {
    val solvedString = if (mCrime.solved)          getString(R.string.crime_report_solved)                  else getString(R.string.crime_report_unsolved) 
    val suspect      = if (mCrime.suspect == null) getString(R.string.crime_report_suspect, mCrime.suspect) else getString(R.string.crime_report_no_suspect)
    val dateString   = DateFormat.format("EEE, MMM dd", mCrime.date).toString
    getString(R.string.crime_report, mCrime.title, dateString, solvedString, suspect)
  }

  override onOptionsItemSelected(MenuItem item)
  {
    switch (item.itemId)
    {  
      case android.R.id.home: NavUtils.navigateUpFromSameTask(activity)
      default:                super.onOptionsItemSelected(item)
    }
    true
  }
} 