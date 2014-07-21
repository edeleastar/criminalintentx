package org.wit.criminalintentx.model

import java.io.Serializable
import org.json.JSONException
import org.json.JSONObject

class Photo implements Serializable
{
  val static serialVersionUID = 1L
  val static JSON_FILENAME    = "filename"

  @Property String filename

  new (String filename)
  {
    _filename = filename
  }

  new (JSONObject json) throws JSONException
  {
    _filename = json.getString(JSON_FILENAME)
  }

  def JSONObject toJSON() throws JSONException
  {
    val json = new JSONObject
    json.put(JSON_FILENAME, _filename)
    json
  }
}
