function or_map = orientation_map(I)

pyr_or = genPyr(I,'gauss',10);
[Gx,Gy] = imgradientxy(pyr_or{4},'sobel');
Gx = imresize(Gx,size(I));
Gy = imresize(Gy,size(I));
Gdir = atan2(Gy,Gx)-pi/2;
or_map = Gdir;








