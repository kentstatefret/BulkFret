mainWindow = figure('Visible','on','Position',[100,100,1375,900],'Resize','off');

cells=[];

for i=1:12
    for j=1:8
         miniCell.create(110*i-85,110*j-85,100,100,1:10,mainWindow);
    end
end