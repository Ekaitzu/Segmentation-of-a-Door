## Segmentation-of-a-Door
The task is about recognition of the position of the door in the image and the corner points of the door.

The problem is divided in five parts:
Part 1: Image preprocessing: improve contrast in the image and suppress noise.
Part 2: Feature extraction: generate features for door gap detection.
Part 3: Image segmentation: segment pixels belonging to the door gap.
Part 4: 2D image measurement: determine location of linear sections of door gap.
Part 5: Classification: classify door gap sections and measure and classify 2D corner points.


For Part 1: 
- Converted the color image (left) to a grayscale image (center).
- Adjusted the contrast in the image using the imadjust function.
- Reduced noise by filtering the image with a 5 x 5 binomial filter, applying various linear filters to the image.
- Took advantage of the separability of the binomial filter and performed two 1D correlations instead of one 2D correlation.

For Part 2:

- Calculate the gradient in the x-direction and y-direction using the Sobel operator. Use the provided optimized filter coefficients for filtering.
- Apply separable filtering.
- Calculate the magnitude of the gradients and display the gradient strength on a logarithmic scale: imagesc(log(1+img)).
- Extract strong light-dark transitions in the image by applying a threshold operation to the gradient strength and considering only negative gradients.
- Use morphological operators, such as imerode, imdilate, imopen, and imclose, to remove small size transitions and emphasize continuous transitions along the door column.
- Extract dark-bright transitions according to the same scheme, both in x and y directions.

For Part 3:
- Design a filter that emphasizes symmetrical light-dark-light transitions in the image and suppresses asymmetrical ones. Combine the features from Task 2 using pointwise logical operations.
- Combine the results of symmetry filtering with the binary image for light-dark-light transitions to obtain candidates for the door gap contour. With appropriate processing via morphological operators, you can complete and widen these contours.

For Part 4:
- Apply the Hough transform to the binary images of the contours segmented in the x and y directions.
- Extract the two straight lines in Hough space with the largest amount of associated pixels. This can be done using the Matlab routines hough(), houghpeaks(), and houghlines().
Note: To get better results with the Hough transformation, you can again widen the contours with morphological operators.

For Part 5:
- Classify the straight line sections of the door gap into four categories: left vertical gap, right vertical gap, upper horizontal gap, and lower horizontal gap. This is done by calculating the intersections of adjacent straight line sections with subpixel accuracy and assigning appropriate labels.
- Determine the coordinates of the vertices of the door by calculating the intersections of the door gap lines. Assign the classes to the coordinates: Bottom Left (LB), Bottom Right (RB), Top Left (LU), and Top Right (RU).
- You can test the algorithm with another test pattern 01 - R2442 - a.jpg to check for robustness.
