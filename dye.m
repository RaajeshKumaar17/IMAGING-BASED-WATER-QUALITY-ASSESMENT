% Load images
blank_img = imread('fresh water.jpg');% Image without dye (reference/clean water)
max_img = imread('algae.jpg');% Image with maximum known concentration of dye/contaminant
test_img = imread('lessalgae.jpg');% Test image for assessment

% Crop images to region of interest (e.g., the water sample area)
% Adjust cropping coordinates [x, y, width, height] as necessary
roi = [50, 50, 200, 200];
blank_img_cropped = imcrop(blank_img, roi);
max_img_cropped = imcrop(max_img, roi);
test_img_cropped = imcrop(test_img, roi);

% Convert cropped images to double precision and HSV color space
blank_img_hsv = rgb2hsv(im2double(blank_img_cropped));
max_img_hsv = rgb2hsv(im2double(max_img_cropped));
test_img_hsv = rgb2hsv(im2double(test_img_cropped));

% Calculate the intensity difference between blank and max images (for calibration)
brightness_blank = blank_img_hsv(:,:,3); % Brightness channel of blank image
brightness_max = max_img_hsv(:,:,3);     % Brightness channel of max concentration image
intensity_blank = mean(brightness_blank(:));
intensity_max = mean(brightness_max(:));
known_concentration = 50;  % Known concentration for max dye image (e.g., in ppm)

% Calculate the brightness (intensity) of the test image
brightness_test = test_img_hsv(:,:,3);
intensity_test = mean(brightness_test(:));

% Estimate concentration in the test image based on linear interpolation
concentration = (intensity_test - intensity_blank) / (intensity_max - intensity_blank) * known_concentration;

% Turbidity Calculation (inverse of brightness as higher turbidity reduces brightness)
turbidity_index = 1 - intensity_test;

% Color Segmentation for contaminants (example: green for algae presence)
% Define green hue range in HSV (adjust as necessary for specific contaminants)
hue_test = test_img_hsv(:,:,1);
green_mask = (hue_test >= 0.25) & (hue_test <= 0.4); % Example range for green hue
algae_percentage = sum(green_mask(:)) / numel(green_mask) * 100; % Percentage of green (algae) coverage

% Display results on original test image
figure;
imshow(test_img);
title(sprintf('Algae Coverage: %.2f%%\nTurbidity Index: %.2f\nEstimated Concentration: %.2f ppm', ...
    algae_percentage, turbidity_index, concentration));

% Plot the calibration curve for visual reference
figure;
plot([0, known_concentration], [intensity_blank, intensity_max], 'r-o', 'LineWidth', 2);
hold on;
plot(concentration, intensity_test, 'bx', 'MarkerSize', 10); % Mark test concentration
xlabel('Concentration (ppm)');
ylabel('Mean Intensity (Brightness)');
title('Calibration Curve for Concentration Estimation');
legend('Calibration', 'Test Sample');
grid on;
