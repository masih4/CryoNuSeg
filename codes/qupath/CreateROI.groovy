// Script to create a 512 x 512 rectangle ROI in Qupath
import qupath.lib.roi.RectangleROI
import qupath.lib.objects.PathAnnotationObject
// Adapted from:
// https://github.com/qupath/qupath/issues/137
// Size in pixels at the base resolution
int size = 511

// Get center pixel
def viewer = getCurrentViewer()
int cx = viewer.getCenterPixelX()
int cy = viewer.getCenterPixelY()

// Create & add annotation
def roi = new RectangleROI(cx-size/2, cy-size/2, size, size)
def annotation = new PathAnnotationObject(roi)
addObject(annotation)
