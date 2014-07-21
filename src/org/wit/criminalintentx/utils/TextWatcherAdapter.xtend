package org.wit.criminalintentx.utils

import android.text.TextWatcher
import android.text.Editable

interface AfterTextChanged
{
  def void afterTextChanged(Editable text)  
}
 
class TextWatcherAdapter implements TextWatcher
{
  var AfterTextChanged afterTextChangedLambda
  
  new (AfterTextChanged f)
  {
    afterTextChangedLambda = f
  }
   
  override afterTextChanged(Editable arg)
  { 
    afterTextChangedLambda.afterTextChanged (arg)
  }

  override beforeTextChanged(CharSequence arg0, int arg1, int arg2, int arg3)
  {
  }

  override onTextChanged(CharSequence arg0, int arg1, int arg2, int arg3)
  {
  } 
}
