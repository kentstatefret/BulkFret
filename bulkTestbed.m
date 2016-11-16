clc

fid=fopen('example.xls');
line = fgetl(fid);
lines = [];

while ischar(line)
    lines{end+1,1} = line;
    line = fgetl(fid);
end
fclose(fid);
cells=[];

for i=7:size(lines,1)-12
    cLine=strsplit(char(lines(i)));
    if size(cLine,2)==99
        cells=[cells;cLine];
    end
end

doubles=zeros(size(cells));

for i=1:size(cells,1)
    for j=1:size(cells,2)
        if size(char(cells(i,j)),2)~=1
            raw=char(cells(i,j));
            striped=[];
            for k=1:size(raw,2)
                if rem(k,2)==0
                    striped=[striped,raw(k)];
                end
            end
            doubles(i,j)=str2double(striped);
        end
    end
end


X=doubles(1:end,1);

for i=3:size(doubles,2)
    Y=doubles(1:end,i);
    if sum(Y)~=0
        Y=Y/max(Y(1:50));
        hold on
        plot(X,Y)
        hold off
    end  
end

disp('done')




