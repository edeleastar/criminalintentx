package org.wit.criminalintentx.utils

import android.os.Bundle
import android.support.v4.app.DialogFragment
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.ImageView
 
public class ImageFragment extends DialogFragment
{
  public static final String EXTRA_IMAGE_PATH = "path"
  var ImageView mImageView

  def static ImageFragment createInstance(String imagePath)
  {
    val args = new Bundle
    args.putSerializable(EXTRA_IMAGE_PATH, imagePath)

    val fragment = new ImageFragment
    fragment.setArguments(args)
    fragment.setStyle(DialogFragment.STYLE_NO_TITLE, 0)

    return fragment;
  }


  override onCreateView(LayoutInflater inflater, ViewGroup parent, Bundle savedInstanceState)
  {
    mImageView = new ImageView(activity)
    val path   = arguments.getSerializable(EXTRA_IMAGE_PATH) as String
    val image  = PictureUtils.getScaledDrawable(activity, path)

    mImageView.imageDrawable = image
    mImageView
  }

  override onDestroyView()
  {
    super.onDestroyView
    PictureUtils.cleanImageView(mImageView)
  }
}