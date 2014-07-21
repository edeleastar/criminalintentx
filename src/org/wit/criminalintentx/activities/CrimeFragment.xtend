package org.wit.criminalintentx.activities

import java.util.Date;
import java.util.UUID;
import org.wit.criminalintentx.R;
import org.wit.criminalintentx.model.Crime
import org.wit.criminalintentx.model.CrimeLab
import org.wit.criminalintentx.model.Photo
import org.wit.criminalintentx.utils.DatePickerFragment;
import org.wit.criminalintentx.utils.ImageFragment
import org.wit.criminalintentx.utils.PictureUtils
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
import android.widget.ImageButton
import android.widget.ImageView
import android.content.pm.PackageManager
import android.graphics.drawable.BitmapDrawable

public class CrimeFragment extends Fragment
{
  public val static String EXTRA_CRIME_ID = "criminalintent.CRIME_ID"
  
  val static DIALOG_DATE     = "date"
  val static DIALOG_IMAGE    = "image"
  val static REQUEST_DATE    = 0
  val static REQUEST_PHOTO   = 1
  val static REQUEST_CONTACT = 2
  
  var Crime       mCrime
  var EditText    mTitleField
  var Button      mDateButton
  var CheckBox    mSolvedCheckBox
  var Button      mSuspectButton
  var Button      reportButton
  var ImageButton mPhotoButton
  var ImageView   mPhotoView
  
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
  
  var photoButtonClicked =
  [
    var i = new Intent(activity, typeof(CrimeCameraActivity))
    startActivityForResult(i, REQUEST_PHOTO)  
  ]

  var photoViewClicked =
  [
    val p = mCrime.photo
    if (p == null)
      return

    val fm   = activity.supportFragmentManager
    val path = activity.getFileStreamPath(p.filename).absolutePath
    ImageFragment.createInstance(path).show(fm, DIALOG_IMAGE)
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
    mPhotoButton    = v.findViewById(R.id.crime_imageButton)   as ImageButton
    mPhotoView      = v.findViewById(R.id.crime_imageView)     as ImageView

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
    mPhotoButton.onClickListener            = photoButtonClicked
    mPhotoView.onClickListener              = photoViewClicked
    
        // if camera is not available, disable camera functionality
    val pm = activity.packageManager
    if (!pm.hasSystemFeature(PackageManager.FEATURE_CAMERA) && !pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_FRONT))
    {
      mPhotoButton.enabled = false
    }
    
    v
   }

  override onStop()
  {
    super.onStop
    PictureUtils.cleanImageView(mPhotoView)
  }
  
  override onStart()
  {
    super.onStart
    showPhoto
  }
  
  override onPause()
  {
    super.onPause
    CrimeLab.get(activity).saveCrimes
  }
  
  def void showPhoto()
  {
    // (re)set the image button's image based on our photo
    val p = mCrime.photo
    var BitmapDrawable b = null;
    if (p != null)
    {
      val path = activity.getFileStreamPath(p.getFilename()).absolutePath
      b = PictureUtils.getScaledDrawable(activity, path);
    }
    mPhotoView.setImageDrawable(b)
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
      case REQUEST_PHOTO:
      {
        val filename = data.getStringExtra(CrimeCameraFragment.EXTRA_PHOTO_FILENAME);
        if (filename != null)
        {
          val p = new Photo(filename)
          mCrime.photo = p
          showPhoto
        }        
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