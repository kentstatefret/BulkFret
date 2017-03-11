x = 0:pi/100:2*pi;
y = sin(x);
f=figure('position',[25,25,960,540]);
a=axes(f);

plot(a,x,y);

img=print('-RGBImage','-r384');

size(img)

imwrite(img,'test4k.png')