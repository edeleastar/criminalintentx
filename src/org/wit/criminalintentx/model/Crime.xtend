package org.wit.criminalintentx.model

import java.util.Date
import java.util.UUID;

import org.json.JSONException
import org.json.JSONObject
 
public class Crime
{
  val static JSON_id      = "id"
  val static JSON_title   = "title"
  val static JSON_date    = "date"
  val static JSON_solved  = "solved"
  val static JSON_photo   = "photo"
  val static JSON_suspect = "suspect"

  @Property UUID    id
  @Property String  title
  @Property Date    date
  @Property boolean solved
  @Property Photo   photo
  @Property String  suspect

  new ()
  {
    id  = UUID.randomUUID
    date = new Date
  }

  new (JSONObject json) throws JSONException
  {
    id     = UUID.fromString(json.getString(JSON_id))
    title  = json.getString(JSON_title)
    solved = json.getBoolean(JSON_solved)
    date   = new Date(json.getLong(JSON_date))
    if (json.has(JSON_photo))
      photo = new Photo(json.getJSONObject(JSON_photo))
    if (json.has(JSON_suspect))
      suspect = json.getString(JSON_suspect)
  }

  def JSONObject toJSON() throws JSONException
  {
    val json = new JSONObject
    json.put(JSON_id,     id.toString)
    json.put(JSON_title,  title)
    json.put(JSON_solved, solved)
    json.put(JSON_date,   date.time)
    if (photo != null)
      json.put(JSON_photo, photo.toJSON)
    json.put(JSON_suspect, suspect)
    json
  }

  override toString()
  {
    title
  }
}