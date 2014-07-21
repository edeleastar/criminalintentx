package org.wit.criminalintentx.utils

import android.app.Activity
import android.graphics.BitmapFactory
import android.graphics.drawable.BitmapDrawable
import android.widget.ImageView

public class PictureUtils
{
  static def BitmapDrawable getScaledDrawable(Activity a, String path)
  {
    val display    = a.windowManager.defaultDisplay
    val destWidth  = display.getWidth();
    val destHeight = display.getHeight();

    // read in the dimensions of the image on disk
    var options = new BitmapFactory.Options
    options.inJustDecodeBounds = true
    BitmapFactory.decodeFile(path, options)

    val srcWidth  = options.outWidth
    val srcHeight = options.outHeight

    var inSampleSize = 1;
    if (srcHeight > destHeight || srcWidth > destWidth)
    {
      if (srcWidth > srcHeight)
      {
        inSampleSize = Math.round(srcHeight as float / destHeight as float)
      }
      else
      {
        inSampleSize = Math.round(srcWidth as float/ destWidth as float)
      }
    }

    options = new BitmapFactory.Options
    options.inSampleSize = inSampleSize

    var bitmap = BitmapFactory.decodeFile(path, options)
    return new BitmapDrawable(a.resources, bitmap)
  }

   static def void cleanImageView(ImageView imageView)
  {
    if (!(imageView.drawable instanceof BitmapDrawable))
      return

    // clean up the view's image for the sake of memory
    val b = imageView.drawable as BitmapDrawable
    b.bitmap.recycle
    imageView.imageDrawable = null
  }
}
