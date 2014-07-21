package org.wit.criminalintentx.activities

import java.util.ArrayList;
import org.wit.criminalintentx.R;
import org.wit.criminalintentx.model.Crime;
import org.wit.criminalintentx.model.CrimeLab;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.ListFragment;
import android.view.ActionMode;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView.MultiChoiceModeListener;
import android.widget.AdapterView.AdapterContextMenuInfo;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.ListView;
import android.widget.TextView;
import android.app.Activity

class CrimeListFragment extends ListFragment 
{
  var ArrayList<Crime> mCrimes
  var boolean          mSubtitleVisible

  override onCreate(Bundle savedInstanceState) 
  {
    super.onCreate(savedInstanceState)
    
    hasOptionsMenu   = true
    activity.title   = R.string.crimes_title
    mCrimes          = CrimeLab.get(activity).crimes
    retainInstance   = true
    mSubtitleVisible = false
    
    listAdapter = new CrimeAdapter(activity, mCrimes)
  }
  
  override onCreateView(LayoutInflater inflater, ViewGroup parent, Bundle savedInstanceState)
  {
    val v = super.onCreateView(inflater, parent, savedInstanceState);

    if (mSubtitleVisible)
    {
      activity.actionBar.subtitle = R.string.subtitle
    }

    val listView =  v.findViewById(android.R.id.list) as ListView

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB)
    {
      registerForContextMenu(listView)
    }
    else
    {
      listView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE_MODAL);
      listView.setMultiChoiceModeListener(new CrimeListListener(this))
    }
    v
  }

  override onListItemClick(ListView l, View v, int position, long id)
  {
    val adapter = listAdapter as CrimeAdapter
    val c =  adapter.getItem(position)
    val i = new Intent(activity, typeof(CrimePagerActivity))
    i.putExtra(CrimeFragment.EXTRA_CRIME_ID, c.id)
    startActivityForResult(i, 0)
  }

  override onActivityResult(int requestCode, int resultCode, Intent data)
  {
    val adapter = listAdapter as CrimeAdapter
    adapter.notifyDataSetChanged
  }

  override onCreateOptionsMenu(Menu menu, MenuInflater inflater)
  {
    super.onCreateOptionsMenu(menu, inflater)
    inflater.inflate(R.menu.fragment_crime_list, menu)
    val showSubtitle = menu.findItem(R.id.menu_item_show_subtitle)
    if (mSubtitleVisible && showSubtitle != null)
    {
      showSubtitle.title = R.string.hide_subtitle
    }
  }

  override onOptionsItemSelected(MenuItem item)
  {
    switch (item.itemId)
    {
      case R.id.menu_item_new_crime:
      {
        val crime = new Crime
        CrimeLab.get(activity).addCrime(crime)
        val i = new Intent(activity, typeof(CrimeActivity))
        i.putExtra(CrimeFragment.EXTRA_CRIME_ID, crime.id)
        startActivityForResult(i, 0)
        true 
      }
      case R.id.menu_item_show_subtitle:
      {
        if (activity.actionBar.subtitle == null)
        {
          activity.actionBar.subtitle = R.string.subtitle
          mSubtitleVisible            = true;
          item.title                  = R.string.hide_subtitle
        }
        else
        {
          activity.actionBar.subtitle = null
          mSubtitleVisible            = false;
          item.title                  = R.string.show_subtitle
        }
        true
      }
      default:
      {
        return super.onOptionsItemSelected(item)
      }
    }
  }

  override onCreateContextMenu(ContextMenu menu, View v, ContextMenuInfo menuInfo)
  {
    activity.menuInflater.inflate(R.menu.crime_list_item_context, menu)
  }

  override onContextItemSelected(MenuItem item)
  {
    val info     = item.getMenuInfo as AdapterContextMenuInfo
    val position = info.position
    val adapter  = listAdapter as CrimeAdapter 
    val crime    = adapter.getItem(position)

    switch (item.itemId)
    {
      case R.id.menu_item_delete_crime:
      {
        CrimeLab.get(activity).deleteCrime(crime)
        adapter.notifyDataSetChanged
        return true
      }
    }
    return super.onContextItemSelected(item)
  }
}

class CrimeAdapter extends ArrayAdapter<Crime> 
{
  var Activity activity

  new(Activity activity, ArrayList<Crime> crimes) 
  {
    super(activity, android.R.layout.simple_list_item_1, crimes)
    this.activity = activity
  }

  override getView(int position, View view, ViewGroup parent) 
  {
    // if we weren't given a view, inflate one
    var View convertView
    if (null == view) 
    {
      convertView = activity.layoutInflater.inflate(R.layout.list_item_crime, null)
    }
    else
    {
      convertView = view
    }

    // configure the view for this Crime
    val c = getItem(position)

    val titleTextView  = convertView.findViewById(R.id.crime_list_item_titleTextView)  as TextView
    val dateTextView   = convertView.findViewById(R.id.crime_list_item_dateTextView)   as TextView
    val solvedCheckBox = convertView.findViewById(R.id.crime_list_item_solvedCheckBox) as CheckBox
    
    titleTextView.text     = c.title
    dateTextView.text      = c.date.toString
    solvedCheckBox.checked = c.solved

    convertView
  }
}

class CrimeListListener implements MultiChoiceModeListener
{
  var ListFragment listFragment
  
  new (ListFragment fragment)
  {
    this.listFragment = fragment
  }
  
  override onCreateActionMode(ActionMode mode, Menu menu)
  {
    val inflater = mode.menuInflater
    inflater.inflate(R.menu.crime_list_item_context, menu);
    true
  }

  override onItemCheckedStateChanged(ActionMode mode, int position, long id, boolean checked)
  {
  }

  override onActionItemClicked(ActionMode mode, MenuItem item)
  {
    switch (item.itemId)
    {
      case R.id.menu_item_delete_crime:
      {
        val adapter  =  listFragment.listAdapter as CrimeAdapter
        val crimeLab = CrimeLab.get(listFragment.activity)
        for (var i = adapter.count - 1; i >= 0; i--)
        {
          if (listFragment.listView.isItemChecked(i))
          {
            crimeLab.deleteCrime(adapter.getItem(i));
          }
        }
        mode.finish
        adapter.notifyDataSetChanged
        true
      }
      default:
      {
        false
      }
    }
  }

  override onPrepareActionMode(ActionMode mode, Menu menu)
  {
    false
  }

  override onDestroyActionMode(ActionMode mode)
  {
  }  
}
