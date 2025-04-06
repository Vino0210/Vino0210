import java.io.File;
import java.nio.file.*;
import java.awt.Color;

String sourceFolderPath = "D:/AAstudy/Term2visualessay/satellite_images";        // Put your input images here
String outputFolderPath = "D:/AAstudy/Term2visualessay/green"; // Output folder for selected images

void setup() {
  File sourceFolder = new File(dataPath(sourceFolderPath));
  File[] files = sourceFolder.listFiles();

  if (files == null) {
    println("Source folder not found or empty!");
    exit();
  }

  // Create output folder if it doesn't exist
  File outputFolder = new File(dataPath(outputFolderPath));
  if (!outputFolder.exists()) {
    outputFolder.mkdirs();
  }

  for (File file : files) {
    if (file.isFile() && file.getName().toLowerCase().matches(".*\\.(jpg|jpeg|png)")) {
      PImage img = loadImage(sourceFolderPath + "/" + file.getName());
      img.loadPixels();

      int greenPixelCount = 0;
      int totalPixels = img.pixels.length;

      for (int i = 0; i < totalPixels; i++) {
        color rgb = img.pixels[i];
        float r = red(rgb) / 255.0;
        float g = green(rgb) / 255.0;
        float b = blue(rgb) / 255.0;

        float[] hsb = new float[3];
        Color.RGBtoHSB((int)(r * 255), (int)(g * 255), (int)(b * 255), hsb);

        float h = hsb[0]; // Hue (0.0 ~ 1.0)
        float s = hsb[1]; // Saturation
        float v = hsb[2]; // Brightness

        // Natural vegetation green threshold (tuned for satellite image)
        if (h >= 0.15 && h <= 0.45 && s >= 0.2 && v >= 0.15) {
          greenPixelCount++;
        }
      }

      float greenRatio = greenPixelCount / (float) totalPixels;

      if (greenRatio > 0.7) {
        println(file.getName() + " -> Green vegetation: " + nf(greenRatio * 100, 0, 2) + "% ✅");
        Path sourcePath = file.toPath();
        Path destPath = Paths.get(dataPath(outputFolderPath), file.getName());
        try {
          Files.copy(sourcePath, destPath, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
          e.printStackTrace();
        }
      } else {
        println(file.getName() + " -> Green vegetation: " + nf(greenRatio * 100, 0, 2) + "% ❌");
      }
    }
  }

  println("Processing completed!");
  exit();
}
