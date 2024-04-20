%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Matlab Lab Testat Winter Term 2020/21                                   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
%%%% Read in a test image with a door %%%%%

% First test image 
image = imread('01 - R2441 - i.JPG');



% Second test image
%image = imread('01 - R2442 - i.JPG');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 1: Image Preprocessing - Contrast Adjustment, Noise Reduction      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Your code goes here ...
figure;
[M N C] = size(image);

imshow(image), title("Original image");
%%%% Conversion to Gray Value Image %%%%
image_gray = rgb2gray(image);

%%%% Adjust Contrast %%%%
im_adj = imadjust(image_gray);

%%%% Noise reduction via binomial low-pass filtering %%%% 

% Define a 5x5 binomial filter
binomialFilter = [1, 4, 6, 4, 1] / 16;

% Apply the filter horizontally and then vertically (separably)
filteredImage = imfilter(imfilter(im_adj, binomialFilter, 'conv', 'replicate'), binomialFilter', 'conv', 'replicate');

% Display the original and filtered images
figure;
subplot(1, 2, 1), imshow(image_gray), title('Original Image');
subplot(1, 2, 2), imshow(filteredImage), title('Filtered Image');

%%%% If you have no result load the given one %%%%

%load('Solutions_Task_1.mat')
%figure(2),imshow(img,'Border','tight');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 2: Feature Extraction - Contours                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Your code goes here ...

%%%% Optimized Sobel x %%%%

Sobel_x = 1/32 * [-3 0 3; -10 0 10; -3 0 3];
Sobel_y = 1/32 * [-3 -10 -3; 0 0 0; 3 10 3];

gradientX = conv2(filteredImage,-Sobel_x, "valid");
gradientY = conv2(filteredImage,Sobel_y, "valid");


figure;
subplot(1, 2, 1), imagesc(gradientX), title("Gradient X"); colorbar; colormap hsv; axis off;
subplot(1, 2, 2), imagesc(gradientY), title("Gradient Y"); colorbar; colormap hsv; axis off;

figure;
subplot(1, 2, 1), imagesc(log(1 + abs(gradientX))), title("Magnitude X"); colorbar; colormap parula; axis off;
subplot(1, 2, 2), imagesc(log(1 + abs(gradientY))), title("Magnitude Y"); colorbar; colormap parula; axis off;

%%%% Edge Strength %%%%

% Negative x-Gradients (bright to dark) 


mean_x = mean(gradientX, "all");
mean_y = mean(gradientY,"all");

% Define edge strength threshold %

threshold1 = mean_x - 2.5;
threshold2 = mean_y -2.5;

% Segment strong negative x-Gradients %
figure;

x_edge_neg = gradientX < threshold1;
y_edge_neg = gradientY < threshold2;

subplot(1, 2, 1);
imshow(x_edge_neg), title("X Negative Edge"); colorbar; axis off; 

subplot(1, 2, 2);
imshow(y_edge_neg), title("Y Negative Edge"); colorbar; axis off;

% Noise reduction %
se = strel('square', 4);

OpenedImage_X_neg = imopen(x_edge_neg, se);
OpenedImage_Y_neg = imopen(y_edge_neg, se);

% Dilate for 1 pixel %

DilatedImage_X_neg = imdilate(OpenedImage_X_neg, se);
DilatedImage_Y_neg = imdilate(OpenedImage_Y_neg, se);

% Positive x-Gradients (dark to bright) %


threshold3 = mean_x + 2.5;
threshold4 = mean_y + 2.5;

% Segment strong positive x-Gradients %
x_edge_pos = gradientX > threshold3;
y_edge_pos = gradientY > threshold4;



% Noise reduction %

OpenedImage_X_pos = imopen(x_edge_pos, se);
OpenedImage_Y_pos = imopen(y_edge_pos, se);



% Dilate for 1 pixel %
DilatedImage_X_pos = imdilate(OpenedImage_X_pos, se);
DilatedImage_Y_pos = imdilate(OpenedImage_Y_pos, se);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 3: Segmentation of Door Gap Contour                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Your code goes here ...

% Extract Vertical Edge candidates for %
figure;

candidates_x = DilatedImage_X_pos & DilatedImage_X_neg;

candidates_y = zeros(size(candidates_x));
candidates_y(1:1500, :) = (DilatedImage_Y_pos(1:1500, :) & DilatedImage_Y_neg(1:1500,:));
candidates_y(1500:3250, :) = imerode(DilatedImage_Y_pos(1500:3250,:), se);

subplot(1, 2, 1); imshow(candidates_x), title("Candidates X"); axis off;
subplot(1, 2, 2); imshow(candidates_y), title("Candidates Y"); axis off;


% Design a symmetric filter %


% Combine knowledge on gray value range and bright-to-dark gradients

% Fatten lines to improve detection 

% Extract Horizontal Edge candidates 

% Combine knowledge on absolute gray value and bright-to-dark-gradient

% Fatten lines to improve detection 


%%%% If you have no result load the given one %%%%

%load('Solutions_Task_3.mat')

%%%% Visualize Results %%%%
%figure(8),imagesc(max(max(img_sym_x))-abs(img_sym_x));colorbar; colormap gray;axis off;
%figure(9),imagesc(1-candidates_x);colorbar; colormap gray;axis off;
%%figure(10),imagesc(1-candidates_y);colorbar; colormap gray;axis off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 4: Measuring Lines of the Door Gap                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Your code goes here ...

% Compute Hough space for vertical lines
[H_x,T_x,R_x] = hough(imdilate(candidates_x,se));

[H_y,T_y,R_y] = hough(imdilate(candidates_y,se));

%Plot Peaks
figure;
subplot(1, 2, 1);
P_x  = houghpeaks(H_x,2);
imshow(H_x,[],'XData',T_x,'YData',R_x,'InitialMagnification','fit'),title("Hough Peaks X");
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
plot(T_x(P_x(:,2)),R_x(P_x(:,1)),'s','color','white');

P_y  = houghpeaks(H_y,2);
subplot(1 , 2, 2);
imshow(H_y,[],'XData',T_y,'YData',R_y,'InitialMagnification','fit'),title("Hough Peaks Y");
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
plot(T_y(P_y(:,2)),R_y(P_y(:,1)),'s','color','white');

% Hough Lines


lines_x = houghlines(imdilate(candidates_x,se),T_x,R_x,P_x,"FillGap",1000);

lines_y = houghlines(imdilate(candidates_y,se),T_y,R_y,P_y,"FillGap",1000);


figure;
imshow(image), title("Lines after houghlines()"), hold on

for k = 1:length(lines_x)
   xy = [lines_x(k).point1; lines_x(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
end

for k = 1:length(lines_y)
   xy = [lines_y(k).point1; lines_y(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
end

hold off;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Task 5: Measure and Classify Corner Points                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Your code goes here ...

% Find left and right door gap lines %
figure;

imshow(image), title("Drawing lines with 'lines' Parameters"); axis off;
hold on;

% Itera sobre cada línea detectada
for k = 1:length(lines_x)
    % Obtiene los parámetros de Hesse para la línea actual
    r = lines_x(k).rho;
    theta = lines_x(k).theta;

    % Calcula puntos a lo largo de la línea de Hesse
    

    if theta == 0

        y = linspace(1, size(image, 1), 100);

        x = ones(1,100)* lines_x(k).point1(1);

        % Plot the line
       
    else
        % Handle the case where sind(theta) is close to zero (vertical line)
        % For vertical lines, x is constant, so we draw a vertical line
        x = linspace(1, size(image, 2), 100);
        y = (r - x * cosd(theta)) / sind(theta);
       
    end
        plot(x, y, 'LineWidth', 1, 'Color', 'green');
end

% Find up and down door gap lines %

% Itera sobre cada línea detectada
for k = 1:length(lines_y)
    % Obtiene los parámetros de Hesse para la línea actual
    r = lines_y(k).rho;
    theta = lines_y(k).theta;

    % Calcula puntos a lo largo de la línea de Hesse
    x = linspace(1, size(image, 2), 100);
    y = (r - x * cosd(theta)) / sind(theta);

    % Dibuja la línea en la imagen
    plot(x, y, 'LineWidth', 1, 'Color', 'green');
end



% Find corner points %

for i = 1:length(lines_x)
    for j = 1:length(lines_y)
        % Extract parameters for linesX
        r1 = lines_x(i).rho;
        theta1 = lines_x(i).theta;

        % Extract parameters for linesY
        r2 = lines_y(j).rho;
        theta2 = lines_y(j).theta;

        % Calculate intersection point
        A = [cosd(theta1), sind(theta1); cosd(theta2), sind(theta2)];
        b = [r1; r2];
        intersectionPoint = A \ b;

        % Plot the intersection point
        plot(intersectionPoint(1), intersectionPoint(2), 'diamond', 'MarkerSize', 10, 'LineWidth', 1, 'Color','r');
    end
end

hold off;

%%%% If you have no result load the given one %%%%

%load('Solutions_Task_5.mat')
%%%% Visualize Results %%%%
%figure(12),imshow(image,'Border','tight');hold on;
%plot([round(-(l_x_left(2)+l_x_left(3))/l_x_left(1)); round(-(M*l_x_left(2)+l_x_left(3))/l_x_left(1));],...
 %   [1,M],...
 %   'LineWidth',1,'Color','red');hold on;
%plot([round(-(l_x_right(2)+l_x_right(3))/l_x_right(1)); round(-(M*l_x_right(2)+l_x_right(3))/l_x_right(1));],...
%    [1,M],...
%    'LineWidth',1,'Color','green');hold on;
%plot([1,N],...
%    [round(-(l_y_up(1)+l_y_up(3))/l_y_up(2)); round(-(N*l_y_up(1)+l_y_up(3))/l_y_up(2));],... 
%    'LineWidth',1,'Color','red');hold on;
%plot([1,N],...
%    [round(-(l_y_down(1)+l_y_down(3))/l_y_down(2)); round(-(N*l_y_down(1)+l_y_down(3))/l_y_down(2));],... 
%    'LineWidth',1,'Color','green');hold on;
%plot(lb(1),lb(2),'ro','MarkerFaceColor','r');hold on;
%plot(lu(1),lu(2),'go','MarkerFaceColor','g');hold on;
%plot(ru(1),ru(2),'bo','MarkerFaceColor','b');hold on;
%plot(rb(1),rb(2),'ko','MarkerFaceColor','k');hold on;
