function bulkFret
    clc %Because I only want errors from _the most recent version_ showing up.
    
    cellTable={'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12';'B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12';'C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12';'D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12';'E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12';'F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12';'G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12';'H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12'};
    %^ stores the cell scrings in the format used by the selector table, a
    %2d array
    cellList={'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12','C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12','E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12','H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12'}; 
    %^ stores the cell strings in a 1d array.

    
    doubles=zeros(1,99);      %stores data in a readable format.  May need to change how sizing this is handled in the future.
    backgrounds=[]; %stores the background vectors such that the background for a cell is stored in the same column as the cell.  As initalized, will have no effect
    normalizations=ones(size(doubles,2)+1,1); %stores the normalization constants such that the appropriate constant is at the same column as the cell data.  As initalized, will have no effect.
    normRanges=zeros(99,2);

    backgroundsStrings={'  '};  %hold list of backgrounds in human readable format
    backgroundIDs=[];           %stores the IDs of the backgrounds.  A1=0,A2=1,B1=12, etc
    selectedCells=[];           %stores the selected cells in the same format as background IDs
    
    legendLables=cellList;
    cellColors=repmat([0,0,0;0,0,1;0,1,0;0,1,1;1,0,0;1,0,1;1,1,0;1,1,1]/2+ones(8,3)/4,12,1); %Default color scheme.
    graphStyle=[0,1,1]; %stores the style to be used in plotting.  Format is [points,lines,smoothed].
    

    file=''; % stores the file name to open.
    path=''; % stores the file path.
    
    %Set up the UI
    
    %main window
    mainWindow          = figure('Name','Bulk Fret','NumberTitle','off','Visible','on','Position',[25,25,1280,720],'ResizeFcn',@resizeWindow,'KeyPressFcn',@keyDownCallback);
    
    %Gets some of the icons used in the default toolbar.
    openImg             = get(findall(mainWindow,'ToolTipString','Open File'),'CData');
    saveImg             = get(findall(mainWindow,'ToolTipString','Save Figure'),'CData');
    ZoomInImg           = get(findall(mainWindow,'ToolTipString','Zoom In'),'CData');
    ZoomOutImg          = get(findall(mainWindow,'ToolTipString','Zoom Out'),'CData');
    PanImg              = get(findall(mainWindow,'ToolTipString','Pan'),'CData');
    
    set(mainWindow,'MenuBar','none'); %Deletes the default menus and toolbar.
    
    
    toolBar=uitoolbar(mainWindow); %Creates a new toolbar to populate with the buttons we actually want.
    
    %populates the toolbar.
    openButton          = uipushtool(toolBar,'CData',openImg,'ToolTipString','Open File','ClickedCallback',@openFile);
    saveButton          = uipushtool(toolBar,'CData',saveImg,'ToolTipString','Save CSV','ClickedCallback',@exportCSV);
    zoomInButton        = uitoggletool(toolBar,'CData',ZoomInImg,'ToolTipString','Zoom In','Separator','on','ClickedCallback',@zoomCallback);
    zoomOutButton       = uitoggletool(toolBar,'CData',ZoomOutImg,'ToolTipString','Zoom Out','ClickedCallback',@zoomCallback);
    PanButton           = uitoggletool(toolBar,'CData',PanImg,'ToolTipString','Pan','ClickedCallback',@panCallback);

    %file menu
    fileMenu            = uimenu('Label','File');
    openMenu            = uimenu(fileMenu,'Label','Open','Callback',@openFile);
    saveMenu            = uimenu(fileMenu,'Label','Save CSV','Callback',@exportCSV);
    exportMenu          = uimenu(fileMenu,'Label','Export Image','Callback',@exportImage);
    
    %view menu
    viewMenu            = uimenu('Label','View');
    drawScatter         = uimenu(viewMenu,'Label','Draw Data Points','Callback',@drawScatterCallback);
    drawLines           = uimenu(viewMenu,'Label','Draw Lines','Callback',@drawLinesCallback);
    smoothLines         = uimenu(viewMenu,'Label','Smooth Lines','Callback',@smoothLinesCallback);
    
    %Following if statements ensure that the check marks on the menu match
    %the initial values for graphStyle.
    if graphStyle(1)
       set(drawScatter,'Checked','on') 
    else
       set(drawScatter,'Checked','off') 
    end
    if graphStyle(2)
       set(drawLines,'Checked','on') 
    else
       set(drawLines,'Checked','off') 
    end
    if graphStyle(3)
       set(smoothLines,'Checked','on') 
    else
       set(smoothLines,'Checked','off') 
    end
    
    %cell select table
    table               = uitable(mainWindow,'Data',cellTable,'Position',[10,530,332,168],'ColumnWidth',{25,25,25,25,25,25,25,25,25,25,25,25},'CellSelectionCallback',@CellSelection,'Enable','off');
    
    %main graph
    graph               = axes('Units','Pixels','Position',[400,100,800,600],'Parent',mainWindow,'ButtonDownFcn',@graphClickCallback);
    
    %button to add cellected cells to list of possible backgrounds
    addToBackgrounds	= uicontrol('Style','pushbutton','String','Add selected cells to background list.','Position',[10,500,200,25],'Callback',@addBackgrounds);
    
    %dropdown to chose background for current cells.
    useBackgrounds      = uicontrol('Style','popupmenu','String',backgroundsStrings,'Callback',@useBackground,'Position',[200,450,50,25]);
    backgroundLable     = uicontrol('Style','text','String','Select Background for current cells','HorizontalAlignment','left','Position',[10,457,175,15]);
    
    %checkbox to enable subtracting backgrounds
    backgroundEnable	= uicontrol('Style','checkbox','String','Subtract Backgrounds','Position',[10,425,150,25],'Value',1,'Callback',@drawCellsCallback);
    
    %checkbox to enable normalization of plots
    normEnable          = uicontrol('Style','checkbox','String','Normalize plots','Position',[10,400,125,25],'Value',1,'Callback',@drawCellsCallback);
    
    captionEdit         = uicontrol('Style','edit','Position',[10,375,125,25],'HorizontalAlignment','left','Callback',@captionEdited);
    
    colorEdit           = uicontrol('Style','pushbutton','String','Edit color','Position',[150,375,125,25],'Callback',@changeColor);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       Helper functions     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function data=normalizeAndBackgroundSubtract(input,cells,n,b)
        
        % Returns a version of input with the backgrounds subtracted and
        % normalization applies, as specified by n and b.
        %
        % input := The unprocessed data, as a matrix
        % cells := The a matrix specifying the cells to process. 
        % n     := Boolean specifying whether to normalize the data.
        % b     := Boolean specifying whether to subtract backgrounds.
        
        data=input;  %If n and b are both false, we want to return input as is.
        if b %subtracts the backgrounds from the data
            for i=1:size(cells,1)
                if backgrounds(cells(i)+1)~=0
                    data(1:end,cells(i)+3)=input(1:end,cells(i)+3)-input(1:end,backgrounds(cells(i)+1)+3);
                end
            end
        end
        if n %multiplies the vectors by the normalization scalers.
            if b %which normalization values we use depends 
                for i=1:size(cells,1)
                    data(1:end,cells(i)+3)=normalizations(cells(i)+3,1)*data(1:end,cells(i)+3);
                end
            else
                for i=1:size(cells,1)
                    data(1:end,cells(i)+3)=normalizations(cells(i)+3,1)*data(1:end,cells(i)+3);
                end
            end
        end
    end

    function norms=getNormalizationValues(data,bckgrnd)
        
        % Returns a 96x2 matrix of positive normalization scalers, to be
        % used for later processing.
        %
        % data    := the raw data to use.
        % bckgrnd := the backgrounds to subtract.
        
        norms=ones(size(data,1),2); %A normalization value of one has no effect, so if that's the default value
        for i=3:99
            j=normRanges(i,1); % normRange specifies which wavelengths to use in normalizations
            k=normRanges(i,2);
            if (j+k~=0) %Don't modify the normalization values if there's no normalization range.
                xMin=data(j,1);
                xMax=data(k,1);
                
                fit=polyfit(data(j:k,1),data(j:k,i),2);
                a=fit(1);
                b=fit(2);
                c=fit(3);
                if (a<0 && c-b*b/(4*a)>0) % Verify the parabola is downward opening (i.e. it's a max, not a min) and vertex above the x axis.
                    if xMin>-b/(2*a) %Only want to use the vertex of the parabola if it's actually in the normalization range.
                        norms(i,1)=a*xMin*xMin+b*xMin+c;
                    elseif xMax<-b/(2*a)
                        norms(i,1)=a*xMax*xMax+b*xMax+c;
                    else
                        norms(i,1)=1/(c-b*b/(4*a));
                    end
                end
                
                %repeats following lines, but for the background subtracted
                %version of the data.
                fit=polyfit(data(j:k,1),data(j:k,i)-bckgrnd(j:k,i),2);
                a=fit(1);
                b=fit(2);
                c=fit(3);
                if (a<0 && c-b*b/(4*a)>0)
                    if xMin>-b/(2*a)
                        norms(i,1)=a*xMin*xMin+b*xMin+c;
                    elseif xMax<-b/(2*a)
                        norms(i,1)=a*xMax*xMax+b*xMax+c;
                    else
                        norms(i,1)=1/(c-b*b/(4*a));
                    end
                end
            end
        end
    end

    function drawCells(cells,ax)
        
        % Draws specified cells to a specified axes.
        % 
        % cells := a matrix identifying the cells to draw.
        % ax    := the axes to draw too.
        
        
        data=normalizeAndBackgroundSubtract(doubles,cells,get(normEnable,'Value'),get(backgroundEnable,'Value'));
        
        X=data(1:end,1); %the wavelengths are stored in the first column
        Xi=min(X):0.2:max(X); % produces a more precise x axis for the smoothing function
        
        labels={};
        plots=[];
        
        yMin=0;
        yMax=0;
        
        cla(graph) %wipes the graph before drawing the selected cells
        
        
        for i=1:size(cells,1)
            
            Y=data(1:end,cells(i)+3);
            if sum(Y)~=0
                hold on
                if graphStyle(1)
                    plots(i)=scatter(ax,X,Y,6,cellColors(cells(i)+1,1:end));
                end
                if graphStyle(2)
                    if graphStyle(3)
                        Yi=pchip(X,Y,Xi); %creates smoothed version of the Y data
                        plots(i)=plot(ax,Xi,Yi,'LineWidth',1.5,'Color',cellColors(cells(i)+1,1:end));
                    else
                        plots(i)=plot(ax,X,Y,'LineWidth',1.5,'Color',cellColors(cells(i)+1,1:end));
                    end
                end

                hold off
            end
            if sum(data(1:end,cells(i)+3))~=0
                labels(i)=legendLables(cells(i)+1);
            end
            
            %Determine the range of th plotted values
            Max=max(data(1:end,cells(i)+3));
            Min=min(data(1:end,cells(i)+3));
            if Max>yMax
                yMax=Max;
            end
            if Min<yMin
                yMin=Min;
            end
        end
        
        %sets up the scaling of the graph such that covers the domain and
        %range of the data, but not more.
        bufferSize=0.05;
        set(graph,'Xlim',[min(X),max(X)])
        if yMin<yMax
            set(ax,'Ylim',[yMin-bufferSize*(yMax-yMin),(1+bufferSize)*yMax-bufferSize*yMin])
        else
            set(ax,'Ylim',[yMin-bufferSize,(1+bufferSize)])
        end
        
        if size(labels,1)>0
            legend(ax,'show')
            legend(ax,plots,labels);
        else
            legend(ax,'off')
        end
        
        %Labels the axes
        set(get(ax,'XLabel'),'String','Wavelength');
        set(get(ax,'YLabel'),'String','Intensity');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %          Callbacks         %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function openFile(source,event)
        %Opens a dialog to select a file, then decodes it into a readable
        %format.
        
        %[file,path]=uigetfile({'*.xls';'*.csv';'*.*'},'File Selector');
        [file,path,filter]=uigetfile({'*.xls;*.csv','Spreadsheet files';'*.*','All files'},'File Selector');
        if file==0
            return
        end
        if file(end-2:end)=='xls'
            fid=fopen([path,file]);
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
        else
            doubles=csvread([path,file],1,0);
        end
        backgrounds=zeros(size(doubles));
        
        set(get(graph,'XLabel'),'String','Wavelength');
        set(get(graph,'YLabel'),'String','Intensity');
        set(table,'Enable','on'); %if the table is enabled before a file is open, bad things end up happening.
    end

    function resizeWindow(source,event)
        %function to move and resize GUI elements when the window is
        %resized.
        try
            newPos  = get(mainWindow,'Position');
            newSize = newPos(3:4);
            if or(newSize(1)<500,newSize(2)<200) % placeholder, replace with this https://www.mathworks.com/matlabcentral/fileexchange/38527-limit-figure-size eventually
                newSize=[1000,700];
                newPos=[newPos(1:2),newSize];
                set(mainWindow,'Position',newPos);
            end
            delSize = newSize-[1280,720];
            set(table,'Position',[10,530+delSize(2),332,168]);
            set(graph,'Position',[[400,100],[800,600]+delSize]);
            set(addToBackgrounds,'Position',[10,500+delSize(2),200,25]);
            set(useBackgrounds,'Position',[200,450+delSize(2),50,25]);
            set(backgroundLable,'Position',[10,457+delSize(2),175,15]);
            set(backgroundEnable,'Position',[10,425+delSize(2),150,25]);
            set(normEnable,'Position',[10,400+delSize(2),125,25]);
            set(captionEdit,'Position',[10,375+delSize(2),125,25]);
            set(colorEdit,'Position',[150,375+delSize(2),125,25]);
        end    
    end

    function drawCellsCallback(source,event)
        %needed because I can't call drawCells directly from the checkbox.
        drawCells(selectedCells,graph);
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
        if size(cellBackgrounds,1)==1 && size(find(backgroundIDs==cellBackgrounds,1),1)
            set(useBackgrounds,'Value',1+find(backgroundIDs==cellBackgrounds,1))
        else
            set(useBackgrounds,'Value',1);
        end
        drawCells(selectedCells,graph);  %Need to update which cells are actually drawn after the cells are selected
    end

    function addBackgrounds(source,event)
        %addes the selected cells to the dropdown list of possible
        %backgrounds.
        for i=1:size(selectedCells,1)
            if any(backgroundIDs==selectedCells(i))==0
                backgroundIDs=[backgroundIDs;selectedCells(i)];
            end
        end
        backgroundIDs=sort(backgroundIDs,1);
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
        drawCells(selectedCells,graph)
        normalizations=getNormalizationValues(doubles,backgrounds);
    end
    
    function captionEdited(source,event)
        %allows the user to edit the caption for the selected line(s)
        for i=1:size(selectedCells,1)
            legendLables{selectedCells(i)+1}=get(source,'String');
        end
        drawCells(selectedCells,graph)
    end
    
    function changeColor(source,event)
        %allows the user to pick a color to for the selected line(s)
        color=uisetcolor([0,0,0]);
        for i=1:size(selectedCells,1)
            cellColors(selectedCells(i)+1,1:end)=color;
        end
        drawCells(selectedCells,graph)
    end
    
    function exportImage(source,event)
        %exports a PNG of whats being rendered on the graph.
        [iFile,iPath]=uiputfile({'*.png';'*.*'},'Export Image');
        tempFigure=figure('Position',get( 0, 'Screensize' )); %may not work for multi-monitor
        tempGraph=axes('Units','Pixels','Parent',tempFigure);
        drawCells(selectedCells,tempGraph);
        try
            print(tempFigure,[iPath,iFile],'-dpng');
        end
        close(tempFigure);
        drawCells(selectedCells,graph);
    end
    
    function exportCSV(source,event)
        %exports a csv _all_ of the data, with background subtraction and
        %normalization done if the boxes are checked.
        [cFile,cPath]=uiputfile({'*.csv';'*.*'},'Export csv');
        data=normalizeAndBackgroundSubtract(doubles,(0:95).',get(normEnable,'Value'),get(backgroundEnable,'Value'));
        commaHeader = [[{'Wavelength','Temperature'},cellList];repmat({','},1,numel([{'Wavelength','Temperature'},cellList]))];
        commaHeader = commaHeader(:)';
        header=cell2mat(commaHeader);
        try
            fid=fopen([cPath,cFile],'w');
            fprintf(fid,'%s\n',header);
            fclose(fid);
            dlmwrite([cPath,cFile],data,'-append');
        end
    end

    function graphClickCallback(source,event)
        %used to select the region to use for normalization.
        [X,Y]=ginput(2);
        [index1, index1]=min(abs(doubles(1:end,1)-X(1)));
        [index2, index2]=min(abs(doubles(1:end,1)-X(2)));
        if (index2<index1)
            temp=index2;
            index2=index1;
            index1=temp;
        end
        for i=1:size(selectedCells,1)
            normRanges(selectedCells(i)+3,1)=index1;
            normRanges(selectedCells(i)+3,2)=index2;
        end
        normalizations=getNormalizationValues(doubles,backgrounds);
        drawCells(selectedCells,graph);
    end

    function drawScatterCallback(source,event)
    % Toggles drawing the data points as a scatter plot.    
    
        if graphStyle(1)
            graphStyle(1)=0;
            set(drawScatter,'Checked','off')
            
            %Need to make sure that the lines are on or the scatter is.
            graphStyle(2)=1;
            set(drawLines,'Checked','on')
        else
            graphStyle(1)=1;
            set(drawScatter,'Checked','on')
        end
        drawCells(selectedCells,graph); %Updates the graph
    end

    function drawLinesCallback(source,event)
        % Toggles drawing lines between the data points.
        if graphStyle(2)
            graphStyle(2)=0;
            set(drawLines,'Checked','off')
            
            %Need to make sure that the lines are on or the scatter is.
            graphStyle(1)=1;
            set(drawScatter,'Checked','on')
        else
            graphStyle(2)=1;
            set(drawLines,'Checked','on')
        end
        drawCells(selectedCells,graph); %Updates the graph
    end

    function smoothLinesCallback(source,event)
        % Toogles smoothing of the lines.
        if graphStyle(3)
            graphStyle(3)=0;
            set(smoothLines,'Checked','off')
        else
            graphStyle(3)=1;
            set(smoothLines,'Checked','on')
        end
        drawCells(selectedCells,graph);  
    end

    function zoomCallback(source,event)
        
        %Changes the zoom mode based on the users selection from the
        %toolbar.
        
        toggle   = strcmp(get(source,'State'),'on');
        inButton = strcmp(get(source,'Separator'),'on');
        if inButton 
            if toggle
                set(zoom,'Enable','On')
                set(zoom,'Direction','in')
            else
                set(zoom,'Enable','Off')
            end
            set(zoomOutButton,'State','off')
        else
            if toggle
                set(zoom,'Enable','On')
                set(zoom,'Direction','out')
            else
                set(zoom,'Enable','Off')
            end
            set(zoomInButton,'State','off')
        end
        
        %Pan and zoom must be mutually exclusive.
        set(PanButton,'State','off') 
        pan off;
    end

    function panCallback(source,event)
        toggle   = strcmp(get(source,'State'),'on');
        if toggle
            pan on
        else
            pan off
        end
        
        %Pan and zoom must be mutually exclusive.
        zoom off
        set(zoomInButton,'State','off')
        set(zoomOutButton,'State','off')
    end

end