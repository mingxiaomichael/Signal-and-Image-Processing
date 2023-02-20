clc;clear;close all;
test_quantity = 45;
%%%Image Processing+getting ideal binary image%%%
A = imread('2.jpg');
A = imrotate(A, -90, 'bilinear');
A_gray = rgb2gray(A);
A_gray = imadjust(A_gray, [0, 0.6]); %Enhanced Contrast
A_gray = imcomplement(A_gray); %imcomplement
%Median Filtering (improved based on Gaussian Filtering)
A_gray = medfilt2(A_gray, [2 5]); %Median Filtering, blurring the information beyond the answer
n = graythresh(A_gray);
A_bw = imbinarize(A_gray, n);  %gray to binary
A_bw = bwareaopen(A_bw, 25);
figure(1)
subplot(1,3,1);
imshow(A), xlabel('Original Image');
subplot(1,3,2);
imshow(A_gray), xlabel('Processed Gary Image');
subplot(1,3,3);
imshow(A_bw), xlabel('Binary Image');
[height,width]=size(A_bw);

%%%Using Hough Function to determine the baseline%%%
[H, T, R] = hough(A_bw);
peaks = houghpeaks(H, 4, 'threshold', ceil(0.3*max(H(:))));
lines = houghlines(A_bw, T, R, peaks, 'FillGap', 50, 'MinLength', 7);
figure(2)
subplot(1,2,1);
imshow(A_bw), title('All Baselines'), hold on;
for i = 1 : length(lines) %all baselines
    if abs(lines(i).theta) > 85 
    line = [lines(i).point1; lines(i).point2];
    len(i) = norm(lines(i).point1 - lines(i).point2);
    plot(line(:, 1), line(:, 2), 'LineWidth', 4, 'Color', 'red');
    xyD{i} = line;
    end
end
[len, ind] = sort(len(:), 'descend'); %ordering in descent
for i = 1 : length(ind)
    xyN{i} = xyD{ind(i)};
end
line_max = xyN{1};
subplot(1,2,2);
imshow(A_bw), title('Separating Line'), hold on;
plot(line_max(:, 1), line_max(:, 2), 'LineWidth', 4, 'Color', 'red');

%%%Image rotation(in correct angle)+Separating personal infomation and answer%%%
for i = 1 : length(lines)
    if abs(lines(i).theta) > 45
        angle(i) =  lines(i).theta;
    if abs(lines(i).theta) <= 45
        angle(i) = Null;
    end
    end
end
angle_mean = mean(angle(angle~=0));
A_bw = imrotate(A_bw, (90+angle_mean), 'crop', 'bilinear');
info = A_bw;
answer = A_bw;
standard = xyN{1};
if standard(1,2) > standard(2,2)
    yanswer = standard(1,2);
    yinfo = standard(2,2);
else
    yanswer = standard(2,2);
    yinfo = standard(1,2);
end
info((yinfo:height), :) = 0;
answer((1:yanswer), :) = 0;
answer((658:height), :) = 0;

figure(3)
subplot(1,2,1);
imshow(info), title('Personal Information');
subplot(1,2,2);
imshow(answer), title('Answer');

%%%Finding ID, subject, ABCD choosing%%%
info = removelargearea(info, 80);
answer = removelargearea(answer, 80);
[L1, num1] = bwlabel(info);
stats1 = regionprops(L1);
[L2, num2] = bwlabel(answer);
stats2 = regionprops(L2);
figure(4)
subplot(1,2,1);
imshow(info); title('Label the infomation'); hold on;
for i = 1 : num1
    temp = stats1(i).Centroid;
    plot(temp(1), temp(2), 'r.');
end
subplot(1,2,2);
imshow(answer); title('Label the answer'); hold on;
for i = 1 : num2
    temp2 = stats2(i).Centroid;
    plot(temp2(1), temp2(2), 'b.');
end
hold off;
%ID
    id_str = "";
if num1 > 15
    k = 1;
    for i = 1:num1
        if (stats1(i).Centroid(1,1) > 230) && (stats1(i).Centroid(1,1) < 360) %getting the 9-bits-ID accoding to the centroid
            test_id(k) = stats1(i).Centroid(1,2);
            k = k + 1;
        end
    end
    y1(1) = 100;
    for i = 1:length(test_id)
        for i_id = 2:1:11
            y1(i_id) = abs(test_id(i) - stats1(num1-12+i_id).Centroid(1,2));
            if y1(i_id) > y1(i_id-1)
                break;
            end
        end
        id(i) = i_id - 3;
    end
    for i = 1:1:length(id)
        id_str = id_str + string(id(i));
    end
end
if num1 <= 15
    disp('No ID Filled In');
end
%subject
for i = 1:num1
    if (stats1(i).Centroid(1,1) > 406) && (stats1(i).Centroid(1,1) < 418) %getting subject accoding to the centroid
        subject_test = stats1(i).Centroid(1,2);
    end
end
y(1) = 100;
for i_subject = 2:1:11
    y(i_subject) = abs(subject_test - stats1(num1-12+i_subject).Centroid(1,2));
    if y(i_subject) > y(i_subject-1)
        break;
    end
end
subject = i_subject - 2;
a = whichsubject(subject);
%answer
for i = 1:1:num2
    x_all(i) = stats2(i).Centroid(1,1);
end
k = 1;
for i = 1:1:num2
    if x_all(i) > (max(x_all(:))-10)
        y_jz(k) = stats2(i).Centroid(1,2);
        k = k + 1;
    end
end
[y_jz, y_jz_num] = sort(y_jz(:), 'ascend');

%single choice
q =1;
for i = 1:1:num2
        if (stats2(i).Centroid(1,2) < y_jz(7)) && (stats2(i).Centroid(1,1) < (max(x_all(:))-10))
            y_answer(q) = stats2(i).Centroid(1,2);
            q = q+1;
        end
end
q1 = 21;
for i = 1:1:num2
    if (stats2(i).Centroid(1,2) > y_jz(8)) && (stats2(i).Centroid(1,2) < y_jz(13)) && (stats2(i).Centroid(1,1) < (max(x_all(:))-10))
        y_answer(q1) = stats2(i).Centroid(1,2);
        q1 = q1+1;
    end
end
%multi choice
q2 = 41;
for i = 1:1:num2
        if (stats2(i).Centroid(1,2) > y_jz(14)) &&(stats2(i).Centroid(1,2) < y_jz(19)) &&  (stats2(i).Centroid(1,1) < (max(x_all(:))-10))
            y_answer(q2) = stats2(i).Centroid(1,2);
            x_answer(q2) = stats2(i).Centroid(1,1);
            q2 = q2+1;
        end
end
%single
for i = 1:1:20
    array1 = [abs(y_answer(i)-y_jz(3)), abs(y_answer(i)-y_jz(4)), abs(y_answer(i)-y_jz(5)), abs(y_answer(i)-y_jz(6))];
    minnum = min(array1);
    array2 = [abs(y_answer(i+20)-y_jz(9)), abs(y_answer(i+20)-y_jz(10)), abs(y_answer(i+20)-y_jz(11)), abs(y_answer(i+20)-y_jz(12))];
    minnum1 = min(array2);
    if abs(y_answer(i)-y_jz(3)) == minnum
        a1(i) = "A";
    end
    if abs(y_answer(i)-y_jz(4)) == minnum
        a1(i) = "B";
    end
    if abs(y_answer(i)-y_jz(5)) == minnum
        a1(i) = "C";
    end
    if abs(y_answer(i)-y_jz(6)) == minnum
        a1(i) = "D";
    end

    if abs(y_answer(i+20)-y_jz(9)) == minnum1
        a2(i) = "A";
    end
    if abs(y_answer(i+20)-y_jz(10)) == minnum1
        a2(i) = "B";
    end
    if abs(y_answer(i+20)-y_jz(11)) == minnum1
        a2(i) = "C";
    end
    if abs(y_answer(i+20)-y_jz(12)) == minnum1
        a2(i) = "D";
    end
end
%multi
for i = 1:1:q2-q1
    array3 = [abs(y_answer(i+40)-y_jz(15)), abs(y_answer(i+40)-y_jz(16)), abs(y_answer(i+40)-y_jz(17)), abs(y_answer(i+40)-y_jz(18))];
    minnum2 = min(array3);
    if abs(y_answer(i+40)-y_jz(15)) == minnum2
        a3(i) = "A";
    end
    if abs(y_answer(i+40)-y_jz(16)) == minnum2
        a3(i) = "B";
    end
    if abs(y_answer(i+40)-y_jz(17)) == minnum2
        a3(i) = "C";
    end
    if abs(y_answer(i+40)-y_jz(18)) == minnum2
        a3(i) = "D";
    end
end
a3_quantity = 1;
a4 = ["";"";"";"";""]; a5 = ["";"";"";"";""];
for i = 1:1:q2-q1-2
    if abs(x_answer(i+40)-x_answer(i+40+1)) < 1 && abs(x_answer(i+40+2)-x_answer(i+40+1)) > 1
        a3_quantity = a3_quantity;
        a4(a3_quantity) = string(a3(i)) + string(a3(i+1));
    end
    if abs(x_answer(i+40)-x_answer(i+40+1)) < 1 && abs(x_answer(i+40+2)-x_answer(i+40+1)) < 1
        a3_quantity = a3_quantity;
        a5(a3_quantity) = string(a3(i)) + string(a3(i+1)) + string(a3(i+2));
    end
    if abs(x_answer(i+40)-x_answer(i+40+1)) > 1
        a3_quantity = a3_quantity+1;
    end
end
for i=1:1:a3_quantity
    if strlength(string(a4(i))) > strlength(string(a5(i)))
        a6(i) = string(a4(i));
    end
    if strlength(string(a4(i))) < strlength(string(a5(i)))
        a6(i) = string(a5(i));
    end
end

%output
data = [a1';a2';a6'];
file_name = a + id_str;
xlswrite(file_name, data);











