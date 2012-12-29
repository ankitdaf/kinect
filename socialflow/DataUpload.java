/* Upload script to convert the Image to a POST request
 * Courtesy philho
 * Source http://bazaar.launchpad.net/~philho/+junk/Processing/files/head:/ImageUpload/
 */

import java.net.*;
import java.io.*;
import javax.imageio.*;
import javax.imageio.stream.*;
import java.awt.image.BufferedImage;

class DataUpload
{
  /** The field name as expected by the PHP script, equivalent to the name in the tag input type="file"
   * in an HTML upload form.
   */
  private static final String FIELD_NAME = "image";
  /** PHP script name. */
  // I hard-code it here, I suppose there is no need for several scripts per applet...
  // and source can be edited for your own sketch.
  // Can be easily transformed into a mutable field specified at construction time or with a setter
  private static final String SCRIPT_NAME = "script.php";
  /** URL path to the PHP script. */
  // Same remark here: hardcoded for usage within a given sketch
  private static final String BASE_URL = "http://yourwebsite.com/extension/";
  /** A computed, hopefully unique (not found in data) Mime boundary string,
   * separating the various parts of the message.
   */
  private String boundary;
  /** Made of the URL and the server script name. Can add parameters too. */
  private String uploadURL;
  /** The connection to the server. */
  private HttpURLConnection connection;
  /** The output stream to write the binary data. */
  private DataOutputStream output;

  DataUpload()
  {
    // Mime boundary of the various parts of the message.
    boundary = "-----MyuploadcodeforLuxInstallation---Yourrandomstringhere-----" + System.currentTimeMillis();
    // We can add optional parameters, eg. a string given by the user, parameters used, etc.
    uploadURL = BASE_URL + "/" + SCRIPT_NAME;// + "?optionalParam=value&foo=bar";
  }

  /** Pushes any binary data to server. */
  boolean UploadBinaryData(String fileName, String dataMimeType, byte[] data)
  {
    try
    {
      boolean isOK = StartPOSTRequest(fileName, dataMimeType);
      if (!isOK)
        return false;

      // Spit out the data bytes at once
      output.write(data, 0, data.length);  // throws IOException

      // And actually do the send (flush output and close it)
      EndPOSTRequest();
    }
    catch (Exception e)
    {
      e.printStackTrace();
      return false; // Problem
    }
    finally
    {
      if (output != null)
      {
        try { output.close(); } catch (IOException ioe) {}
      }
    }

    return true;  // OK
  }

  /** Pushes image to server. Similar to UploadBinaryData but is given a BufferedImage
   * and guesses the Mime type with the file name extension.
   */
  boolean UploadImage(String fileName, BufferedImage image)
  {
    String imageType = null, imageMimeType = null;
    boolean bUseOtherMethod = false;
    if (fileName.endsWith("png"))
    {
      imageType = "png";
      imageMimeType = "image/png";
    }
    else if (fileName.endsWith("jpg"))
    {
      imageType = "jpg";
      imageMimeType = "image/jpeg";
    }
    else if (fileName.endsWith("jpeg"))
    {
      imageType = "jpeg";
      imageMimeType = "image/jpeg";
      bUseOtherMethod = true;
    }
    else
    {
      return false; // Unsupported image format
    }

    try
    {
      boolean isOK = StartPOSTRequest(fileName, imageMimeType);
      if (!isOK)
        return false;

      // Output the encoded image data
      if (!bUseOtherMethod)
      {
        // Uses the default method
        ImageIO.write(image, imageType, output);
      }
      else
      {
        // Alternative for better Jpeg quality control
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        java.util.Iterator iter = ImageIO.getImageWritersByFormatName(imageType);
        if (iter.hasNext())
        {
          ImageWriter writer = (ImageWriter) iter.next();
          ImageWriteParam iwp = writer.getDefaultWriteParam();
          iwp.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
          iwp.setCompressionQuality(1.0f);

          ImageOutputStream ios = new MemoryCacheImageOutputStream(baos);
          writer.setOutput(ios);
          writer.write(image);
          byte[] b = baos.toByteArray();
          output.write(b, 0, b.length);
        }
      }

      // And actually do the send (flush output and close it)
      EndPOSTRequest();
    }
    catch (Exception e)
    {
      e.printStackTrace();
      return false; // Problem
    }
    finally
    {
      if (output != null)
      {
        try { output.close(); } catch (IOException ioe) {}
      }
    }

    return true;  // OK
  }

  /** Reads output from server. */
  String GetServerFeedback()
  {
    if (connection == null)
    {
      // ERROR: Can't get server feedback without first uploading data!
      return null;
    }
    BufferedReader input = null;
    StringBuffer answer = new StringBuffer();
    try
    {
      input = new BufferedReader(new InputStreamReader(connection.getInputStream()));
      String answerLine = null;
      do
      {
        answerLine = input.readLine();
        if (answerLine != null)
        {
          answer.append(answerLine + "\n");
        }
      } while (answerLine != null);
    }
    catch (Exception e)
    {
      // Can display some feedback to user there, or just ignore the issue
      e.printStackTrace();
      return null;  // Problem
    }
    finally
    {
      if (input != null)
      {
        try { input.close(); } catch (IOException ioe) {}
      }
    }

    return answer.toString();
  }

  int GetResponseCode()
  {
    int responseCode = -1;
    if (connection == null)
    {
      // ERROR: Can't get server response without first uploading data!
      return -1;
    }
    // Note that 200 means OK
    try
    {
      responseCode = connection.getResponseCode();
    }
    catch (IOException ioe)
    {
    }
    return responseCode;
  }

  /*-- Private section --*/

  private boolean StartPOSTRequest(String fileName, String dataMimeType)
  {
    try
    {
      URL url = new URL(uploadURL); // throws MalformedURLException
      connection = (HttpURLConnection) url.openConnection();  // throws IOException
      // connection is probably of HttpURLConnection  type now

      connection.setDoOutput(true); // We output stuff
      connection.setRequestMethod("POST");  // With POST method
      connection.setDoInput(true);  // We want feedback!
      connection.setUseCaches(false); // No cache, it is (supposed to be) a new image each time, even if URL is always the same

      // Post multipart data
      // Set request headers
      // Might put something like "Content-Length: 8266"
      connection.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
      // throws IllegalStateException, NullPointerException

      // Open a stream which can write to the URL
      output = new DataOutputStream(connection.getOutputStream());
      // the get throws IOException, UnknownServiceException

      // Write content to the server, begin with the tag that says a content element is coming
      output.writeBytes("--" + boundary + "\r\n"); // throws IOException

      // Describe the content:
      // filename isn't really important here, it is probably ignored by the upload script, or can be set to user name if logged in
      output.writeBytes("Content-Disposition: form-data; name=\"" + FIELD_NAME +
          "\"; filename=\"" + fileName + "\"\r\n");
      // Mime type of the data, like image/jpeg or image/png
      // Likely to be ignored by the PHP script (which can't trust such external info) but (might be) mandatory and nice to indicate anyway
      output.writeBytes("Content-Type: " + dataMimeType + "\r\n");
      // By default it is Base64 encoding (that's what most browsers use), but here we don't use this,
      // for simplicity sake and because it is less data to transmit. As long as destination server understands it...
      // See http://www.freesoft.org/CIE/RFC/1521/5.htm for details
      output.writeBytes("Content-Transfer-Encoding: binary\r\n\r\n");
    }
    catch (Exception e) // Indistinctly catch all kinds of exceptions this code can throw at us
    {
      // Can display some feedback to user there, or just ignore the issue
      e.printStackTrace();
      return false; // Problem
    }

    return true;
  }

  private boolean EndPOSTRequest()
  {
    try
    {
      // Close the multipart form request
      output.writeBytes("\r\n--" + boundary + "--\r\n\r\n");

      // And actually do the send (flush output and close it)
      output.flush(); // throws IOException
    }
    catch (Exception e) // Indistinctly catch all kinds of exceptions this code can throw at us
    {
      // Can display some feedback to user there, or just ignore the issue
      e.printStackTrace();
      return false; // Problem
    }

    return true;
  }
}
