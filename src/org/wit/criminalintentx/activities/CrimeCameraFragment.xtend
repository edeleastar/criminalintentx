package org.wit.criminalintentx.activities

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.UUID;
import org.wit.criminalintentx.R;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.hardware.Camera;
import android.hardware.Camera.Size;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

class CrimeCameraFragment extends Fragment
{
  val static TAG  = "CrimeCameraFragment"
  public val static EXTRA_PHOTO_FILENAME = "CrimeCameraFragment.filename"

  var Camera         mCamera
  var SurfaceView    mSurfaceView
  var View           mProgressContainer
  var CameraSurface  cameraSurface

  val mShutterCallback =
  [ |
    mProgressContainer.visibility = View.VISIBLE
  ] as Camera.ShutterCallback

  val takePicture =
  [
    if (mCamera != null)
    {
      mCamera.takePicture(mShutterCallback, null, mJpegCallBack);
    }
  ]

  val mJpegCallBack =
  [
    byte[] data, Camera camera |
      // create a filename
    val filename = UUID.randomUUID.toString + ".jpg"
    // save the jpeg data to disk
    var FileOutputStream os = null
    var success = true
    try
    {
      os = activity.openFileOutput(filename, Context.MODE_PRIVATE)
      os.write(data)
    }
    catch (Exception e)
    {
      Log.e(TAG, "Error writing to file " + filename, e)
      success = false
    }
    finally
    {
      try
      {
        os?.close
      }
      catch (Exception e)
      {
        Log.e(TAG, "Error closing file " + filename, e)
        success = false
      }
    }

    if (success)
    {
      // set the photo filename on the result intent
      if (success)
      {
        val i = new Intent
        i.putExtra(EXTRA_PHOTO_FILENAME, filename)
        activity.setResult(Activity.RESULT_OK, i)
      }
      else
      {
        activity.setResult(Activity.RESULT_CANCELED)
      }
    }
    activity.finish()
  ]

  override onCreateView(LayoutInflater inflater, ViewGroup parent, Bundle savedInstanceState)
  {
    val v = inflater.inflate(R.layout.fragment_crime_camera, parent, false)

    mProgressContainer = v.findViewById(R.id.crime_camera_progressContainer)
    mProgressContainer.setVisibility(View.INVISIBLE)
    val takePictureButton = v.findViewById(R.id.crime_camera_takePictureButton) as Button
    takePictureButton.onClickListener = takePicture

    mSurfaceView =  v.findViewById(R.id.crime_camera_surfaceView) as SurfaceView
    val holder = mSurfaceView.holder
    // deprecated, but required for pre-3.0 devices
   // holder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS)
    
    cameraSurface = new CameraSurface
    holder.addCallback(cameraSurface)
    
    return v
    }


  override onResume()
  {
    super.onResume
    mCamera = Camera.open(0)
    cameraSurface.mCamera = mCamera
  }

  override onPause()
  {
    super.onPause
    if (mCamera != null)
    {
      mCamera.release
      mCamera = null;
      cameraSurface.mCamera = null
    }
  }
}

class CameraSurface implements SurfaceHolder.Callback
{
  public var Camera mCamera
  
  override surfaceCreated(SurfaceHolder holder)
  {
    // tell the camera to use this surface as its preview area
    try
    {
      if (mCamera != null)
      {
        mCamera.setPreviewDisplay(holder);
      }
    }
    catch (IOException exception)
    {
      Log.e("CAMERA", "Error setting up preview display", exception);
    }
  }

  override surfaceDestroyed(SurfaceHolder holder)
  {
    // we can no longer display on this surface, so stop the preview.
    if (mCamera != null)
    {
      mCamera.stopPreview();
    }
  }

  override surfaceChanged(SurfaceHolder holder, int format, int w, int h)
  {
    if (mCamera == null)
      return;

    // the surface has changed size; update the camera preview size
    val parameters = mCamera.parameters
    var s = getBestSupportedSize(parameters.getSupportedPreviewSizes(), w, h)
    parameters.setPreviewSize(s.width, s.height);
    s = getBestSupportedSize(parameters.getSupportedPictureSizes(), w, h)
    parameters.setPictureSize(s.width, s.height)
    mCamera.setParameters(parameters)
    try
    {
      mCamera.startPreview
    }
    catch (Exception e)
    {
      Log.e("CAMERA", "Could not start preview", e)
      mCamera.release
      mCamera = null
    }
  }
    /**
   * a simple algorithm to get the largest size available. For a more robust
   * version, see CameraPreview.java in the ApiDemos sample app from Android.
   */
  def getBestSupportedSize(List<Size> sizes, int width, int height)
  {
    var bestSize = sizes.get(0)
    var largestArea = bestSize.width * bestSize.height
    for (Size s : sizes)
    {
      val area = s.width * s.height
      if (area > largestArea)
      {
        bestSize = s
        largestArea = area
      }
    }
    return bestSize
  }
}
    