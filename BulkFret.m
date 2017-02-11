function bulkFret
    clc
    
    doubles=zeros(116,99);      %stores data in a readable format
    backgroundsStrings={'  '};  %hold list of backgrounds in human readable format
    backgroundIDs=[];           %stores the IDs of the backgrounds.  A1=0,A2=1,B1=12, etc
    selectedCells=[];           %stores the selected cells in the same format as background IDs
    cellTable={'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12';'B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12';'C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12';'D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12';'E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12';'F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12';'G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12';'H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12'};
    %^ stores the cell scrings in the format used by the selector table, a
    %2d array
    cellList={'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12','C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12','E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12','H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12'}; 
    %^ stores the cell strings in a 1d array.
    backgrounds=zeros(size(doubles,2)+1,1); %stores the background vectors such that the background for a cell is stored in the same column as the cell.  As initalized, will have no effect
    normalizations=ones(size(doubles,2)+1,1); %stores the normalization constants such that the appropriate constant is at the same column as the cell data.  As initalized, will have no effect.
    file=''; % stores the file name to open
    path=''; % stores the file path.
    
    %Set up the UI
    
    %main window
    mainWindow          = figure('Name','Bulk Fret','NumberTitle','off','Visible','on','Position',[25,25,1280,720],'ResizeFcn',@resizeWindow);
    mainWindow.MenuBar='none';
    
    %file menu
    fileMenu=uimenu('Label','File');
    uimenu(fileMenu,'Label','Open','Callback',@openFile);
    uimenu(fileMenu,'Label','Save','Callback','disp(''save'')');
    uimenu(fileMenu,'Label','Quit','Callback','disp(''exit'')');
    
    %view menu
    viewMenu=uimenu('Label','View');
    uimenu(viewMenu,'Label','Quit','Callback','disp(''exit'')');
    
    %cell select table
    table               = uitable(mainWindow,'Data',cellTable,'Position',[10,530,332,168],'ColumnWidth',{25,25,25,25,25,25,25,25,25,25,25,25},'CellSelectionCallback',@CellSelection,'Enable','off');
    
    %main graph
    graph               = axes('Units','Pixels','Position',[400,100,800,600],'Parent',mainWindow);
    
    %button to add cellected cells to list of possible backgrounds
    addToBackgrounds	= uicontrol('Style','pushbutton','String','Add selected cells to background list.','Position',[10,500,200,25],'Callback',@addBackgrounds);
    
    %dropdown to chose background for current cells.
    useBackgrounds      = uicontrol('Style','popupmenu','String',backgroundsStrings,'Callback',@useBackground,'Position',[200,450,50,25]);
    backgroundLable     = uicontrol('Style','text','String','Select Background for current cells','HorizontalAlignment','left','Position',[10,457,175,15]);
    
    %checkbox to enable subtracting backgrounds
    backgroundEnable	= uicontrol('Style','checkbox','String','Subtract Backgrounds','Position',[10,425,150,25],'Value',1,'Callback',@drawCellsCallback);
    
    %checkbox to enable normalization of plots
    normEnable          = uicontrol('Style','checkbox','String','Normalize plots','Position',[10,400,125,25],'Value',1,'Callback',@drawCellsCallback);
    


    function openFile(source,event)
        %Opens a dialog to select a file, then decodes it into a readable
        %a usable format.
        
        [file,path]=uigetfile({'*.xls';'*.*'},'File Selector');
        fid=fopen(strcat(path,file));
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
        
        set(get(graph,'XLabel'),'String','Wavelength');
        set(get(graph,'YLabel'),'String','Intensity');
        set(table,'Enable','on'); %if the table is enabled before a file is open, bad things end up happening.
    end

    function resizeWindow(source,event)
        %function to move and resize GUI elements when the window is
        %resized.
        
        newPos  = get(mainWindow,'Position');
        newSize = newPos(3:4);
        delSize = newSize-[1280,720];
        
        set(table,'Position',[10,530+delSize(2),332,168]);
        set(graph,'Position',[[400,100],[800,600]+delSize]);
        set(addToBackgrounds,'Position',[10,500+delSize(2),200,25]);
        set(useBackgrounds,'Position',[200,450+delSize(2),50,25]);
        set(backgroundLable,'Position',[10,457+delSize(2),175,15]);
        set(backgroundEnable,'Position',[10,425+delSize(2),150,25]);
        set(normEnable,'Position',[10,400+delSize(2),125,25]);
    end

    function drawCells(cells)
        %backend function to draw the cells specified by "cells" to the
        %figure.  Should be called after most updates.
        
        bkgrdEnabled=get(backgroundEnable,'Value');
        normalize=get(normEnable,'Value');
        %Need these two to know how to draw the plots.
        
        data=doubles;  %data is what eventually get's plotted.
        if bkgrdEnabled %subtracts the backgrounds from the data
            for i=1:size(cells,1)
                if backgrounds(cells(i)+1)~=0
                    data(1:end,cells(i)+3)=doubles(1:end,cells(i)+3)-doubles(1:end,backgrounds(cells(i)+1)+3);
                end
            end
        end
        
        if normalize %multiplies the vectors by the normalization scalers.
            for i=1:size(cells,1)
                data(1:end,cells(i)+3)=normalizations(cells(i)+3)*data(1:end,cells(i)+3);
            end
        end
        
        X=data(1:end,1); %the wavelengths are stored in the first column
        Xi=min(X):0.2:max(X); % produces a more precise x axis for the smoothing function
        
        plot(graph,[600,600],[0,0]) %wipes the graph before drawing the selected cells
        
        for i=1:size(cells,1)
            Y=data(1:end,cells(i)+3);
            if sum(Y)~=0
                hold on
                Yi=pchip(X,Y,Xi); %creates smoothed version of the Y data
                plot(graph,Xi,Yi,'LineWidth',1.5);
                hold off
            end  
        end
        
        %sets up the scaling of the graph such that covers the domain and
        %range of the data, but not more.
        bufferSize=0.05;
        yMin=0;
        yMax=0;
        for i=1:size(cells,1)
            Max=max(data(1:end,cells(i)+3));
            Min=min(data(1:end,cells(i)+3));
            if Max>yMax
                yMax=Max;
            end
            if Min<yMin
                yMin=Min;
            end
        end
        set(graph,'Xlim',[min(X),max(X)])
        if yMin<yMax
            set(graph,'Ylim',[yMin-bufferSize*(yMax-yMin),(1+bufferSize)*yMax-bufferSize*yMin])
        else
            set(graph,'Ylim',[yMin-bufferSize,(1+bufferSize)])
        end
        
        %Labels the axes
        set(get(graph,'XLabel'),'String','Wavelength');
        set(get(graph,'YLabel'),'String','Intensity');
    end

    function drawCellsCallback(source,event)
        %needed because I can't call drawCells directly from the checkbox.
        drawCells(selectedCells);
    end 
    
    function CellSelection(source,event) 
        %called when which cells are selected on the table.
        tempList=event.Indices;
        selectedCells=zeros(size(tempList,1),1);
        
        cellBackgrounds=[];
        for i=1:size(selectedCells,1)
            selectedCells(i)=12*(tempList(i,1)-1)+(tempList(i,2)-1); % actually builds up selectedCells, arguably the main job of this function
            %The rest of this loop and the next if statement are dedicated
            %to updating the dropdown
            try
                backgroundID=backgrounds(selectedCells(i)+1);
            catch
                backgroundID=0;
            end
            cellBackgrounds=unique([cellBackgrounds;backgroundID]);
        end
        if and(size(cellBackgrounds,1)==1,size(find(backgroundIDs==cellBackgrounds,1),1))
            set(useBackgrounds,'Value',1+find(backgroundIDs==cellBackgrounds,1))
        else
            set(useBackgrounds,'Value',1);
        end
        drawCells(selectedCells);  %Need to update which cells are actually drawn after the cells are selected
    end

    function addBackgrounds(source,event)
        %addes the selected cells to the dropdown list of possible
        %backgrounds.
        for i=1:size(selectedCells,1)
            if any(backgroundIDs==selectedCells(i))==0
                backgroundIDs=[backgroundIDs;selectedCells(i)];
            end
        end
        backgroundIDs=sort(backgroundIDs,1)
        backgroundsStrings={'--'};
        for i=1:size(backgroundIDs,1)
            backgroundStrings(i+1)=cellList(backgroundIDs(i)+1);
        end
        set(useBackgrounds,'String',backgroundStrings);
    end

    function useBackground(source,event)
        %selects which cell to use as the background for the selected cell,
        %out of the dropdown list.
        try
            backgroundID=backgroundIDs(get(source,'Value')-1);
        catch
            backgroundID=0;
        end
        for i=1:size(selectedCells,1)
            backgrounds(selectedCells(i)+1)=backgroundID;
        end
        drawCells(selectedCells)
    end
end