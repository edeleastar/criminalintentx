package org.wit.criminalintentx.utils

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import org.wit.criminalintentx.R;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.widget.DatePicker;
import android.widget.DatePicker.OnDateChangedListener;

class DatePickerFragment extends DialogFragment
{
  val static  EXTRA_DATE = "criminalintent.DATE"

  var Date mDate
  
  var update =    
  [ 
  	DatePicker view, int year, int month, int day |
    mDate = new GregorianCalendar(year, month, day).time
    arguments.putSerializable(EXTRA_DATE, mDate);
  ]  as  OnDateChangedListener

  var click =    
  [ 
  	DialogInterface dialog, int which |
    sendResult(Activity.RESULT_OK)
  ]  as  OnClickListener

  def static DatePickerFragment newInstance(Date date)
  {
    var args = new Bundle
    args.putSerializable(EXTRA_DATE, date)

    val fragment = new DatePickerFragment
    fragment.setArguments(args)

    fragment
  }

  private def sendResult(int resultCode)
  {
    if (targetFragment == null)
      return
    val i = new Intent
    i.putExtra(EXTRA_DATE, mDate)
    targetFragment.onActivityResult(targetRequestCode, resultCode, i)
  }

  override onCreateDialog(Bundle savedInstanceState)
  {
    val mDate = arguments.getSerializable(EXTRA_DATE) as Date

    val calendar  = Calendar.instance
    calendar.time = mDate
    val year      = calendar.get(Calendar.YEAR)
    val month     = calendar.get(Calendar.MONTH)
    val day       = calendar.get(Calendar.DAY_OF_MONTH)
    
    val v          = activity.layoutInflater.inflate(R.layout.dialog_date, null)
    val datePicker = v.findViewById(R.id.dialog_date_datePicker) as DatePicker
    datePicker.init(year, month, day, update)

    val dialog    = new AlertDialog.Builder(activity)
    dialog.view   = v
    dialog.title  = R.string.date_picker_title
    dialog.setPositiveButton(android.R.string.ok, click)
    return dialog.create
//    return new AlertDialog.Builder(getActivity()).setView(v).setTitle(R.string.date_picker_title).setPositiveButton(android.R.string.ok, click).create();  
  }
}
