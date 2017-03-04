function bulkFret

    clc
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %      Global  variables     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Stores the actual data$
    wavelengths=[];
    intensities=zeros(8,12,2);

    %global UI constants and initial values
    defaultPosition = [25,25,1280,720];
    cellTable       = {'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12';'B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12';'C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12';'D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12';'E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12';'F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12';'G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12';'H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12'};
    cellColors      = permute(repmat([0,0,0;0,0,1;0,1,0;0,1,1;1,0,0;1,0,1;1,1,0;1,1,1;],[1,1,12]),[3,1,2])/2+ones(12,8,3)/4; %Default color scheme.
    graphStyle      = [0,1,1]; %stores the style to be used in plotting.  Format is [points,lines,smoothed].

    %     UI global variables    %
    selectedCells      = zeros(0,2); %stores a list of the currently selected cells

    cellBackgrounds    = zeros(8,12); %stores the index of each cells background from the list of possible backgrounds.
    
    backgroundIDs      = zeros(0,2); %stores a list of the possible backgrounds by their coordinates on the cells
    backgroundStrings = { '  '};    %stores a list of the possible backgrounds in human readable format

    %         UI elements        %
    mainWindow=0;

    %Tool Bar%
    toolBar=0;
    openButton=0;
	saveButton=0;
    zoomInButton=0;
    zoomOutButton=0;
    PanButton=0;

    %file menu
    fileMenu=0;
    openMenu=0;
    saveMenu=0;
    exportMenu=0;

    %view menu
    viewMenu=0;
    drawScatter=0;
    drawLines=0;
    smoothLines=0;

    %cell select table
    table=0;

    %main graph
    graph=0;

    %button to add cellected cells to list of possible backgrounds
    addToBackgrounds=0;

    %dropdown to chose background for current cells.
    useBackgrounds=0;
    backgroundLable=0;
    
    %checkbox to enable subtracting backgrounds
    backgroundEnable=0;

    %checkbox to enable normalization of plots
    normEnable=0;

    %Controls for editing the legend
    captionEdit=0;
    colorEdit=0;
    
    setupGUI();
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       Helper functions     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function out=nonEmpty(in)
        indicies=find(~cellfun(@isempty,in));
        out=cell(size(indicies));
        for i=1:size(indicies,2)
            out(i)=in(indicies(i));
        end
    end
    
    function processedData = normalizeAndBackgroundSubtract(input,cells,n,b) %need implimented
        
        % Returns a version of input with the backgrounds subtracted and
        % normalization applies, as specified by n and b.
        %
        % input := The unprocessed data, as a matrix
        % cells := The a matrix specifying the cells to process. 
        % n     := Boolean specifying whether to normalize the data.
        % b     := Boolean specifying whether to subtract backgrounds.
        
    end

    function norms=getNormalizationValues() %need implimented
        % Returns a 8x12x2 matrix of positive normalization scalers, to be
        % used for later processing.
        %
        % data    := the raw data to use.
        % bckgrnd := the backgrounds to subtract.
    end

    function drawCells(cells,ax) %need implimented
        
        % Draws specified cells to a specified axes.
        % 
        % cells := a matrix identifying the cells to draw.
        % ax    := the axes to draw too.
        
        pData=intensities;
        
        X=wavelengths; %the wavelengths are stored in the first column
        Xi=min(X):0.2:max(X); % produces a more precise x axis for the smoothing function
        
        labels={};
        plots=[];
        
        yMin=0;
        yMax=0;
        
        cla(ax)
        for i=1:size(cells,1)    
            Y=permute(intensities(cells(i,1),cells(i,2),1:end),[3,2,1]);
            cells(i,:)
            color=permute(cellColors(cells(i,2),cells(i,1),:),[3,1,2]);
            if sum(Y)~=0
                hold on
                if graphStyle(1)
                    plots(i)=scatter(ax,X,Y,300,color,'.');
                end
                if graphStyle(2)
                    if graphStyle(3)
                        Yi=pchip(X,Y,Xi); %creates smoothed version of the Y data
                        plots(i)=plot(ax,Xi,Yi,'LineWidth',1.5,'Color',color);
                    else
                        plots(i)=plot(ax,X,Y,'LineWidth',1.5,'Color',color);
                    end
                end

                hold off
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    Callbacks and Setup     %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function setupGUI
        mainWindow=figure('Name','Bulk Fret','NumberTitle','off','Visible','on','Position',defaultPosition);
        
        %Gets some of the icons used in the default toolbar.
        openImg             = get(findall(mainWindow,'ToolTipString','Open File'),'CData');
        saveImg             = get(findall(mainWindow,'ToolTipString','Save Figure'),'CData');
        ZoomInImg           = get(findall(mainWindow,'ToolTipString','Zoom In'),'CData');
        ZoomOutImg          = get(findall(mainWindow,'ToolTipString','Zoom Out'),'CData');
        PanImg              = get(findall(mainWindow,'ToolTipString','Pan'),'CData');
        
        set(mainWindow,'MenuBar','none'); %Deletes the default menus and toolbar.
        toolBar=uitoolbar(mainWindow); %Creates a new toolbar to populate with the buttons we actually want.
        
        openButton          = uipushtool(toolBar,'CData',openImg,'ToolTipString','Open File','ClickedCallback',@openFile);
        saveButton          = uipushtool(toolBar,'CData',saveImg,'ToolTipString','Save CSV','ClickedCallback',@exportCSV);
        zoomInButton        = uitoggletool(toolBar,'CData',ZoomInImg,'ToolTipString','Zoom In','Separator','on','ClickedCallback',@zoomCallback);
        zoomOutButton       = uitoggletool(toolBar,'CData',ZoomOutImg,'ToolTipString','Zoom Out','ClickedCallback',@zoomCallback);
        PanButton           = uitoggletool(toolBar,'CData',PanImg,'ToolTipString','Pan','ClickedCallback',@panCallback);
        
        fileMenu            = uimenu('Label','File');
        openMenu            = uimenu(fileMenu,'Label','Open','Callback',@openFile);
        saveMenu            = uimenu(fileMenu,'Label','Save CSV','Callback',@exportCSV);
        exportMenu          = uimenu(fileMenu,'Label','Export Image','Callback',@exportImage);
        
        viewMenu            = uimenu('Label','View');
        drawScatter         = uimenu(viewMenu,'Label','Draw Data Points','Callback',@drawScatterCallback);
        drawLines           = uimenu(viewMenu,'Label','Draw Lines','Callback',@drawLinesCallback);
        smoothLines         = uimenu(viewMenu,'Label','Smooth Lines','Callback',@smoothLinesCallback);
        
        %The following if statements ensure that the check marks on the menu match
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
        
        table = uitable(mainWindow,'Data',cellTable,'Position',[10,530,332,168],'ColumnWidth',{25,25,25,25,25,25,25,25,25,25,25,25},'CellSelectionCallback',@CellSelection,'Enable','off');
        
        graph = axes('Units','Pixels','Position',[400,100,800,600],'Parent',mainWindow,'ButtonDownFcn',@graphClickCallback);
        set(get(graph,'XLabel'),'String','\lambda (nm)');
        set(get(graph,'YLabel'),'String','Intensity (arb. units)');      
        set(graph,'FontSize',20)
        
        addToBackgrounds	= uicontrol('Style','pushbutton','String','Add selected cells to background list.','Position',[10,500,200,25],'Callback',@addBackgrounds);
    
        useBackgrounds      = uicontrol('Style','popupmenu','String',backgroundStrings,'Callback',@useBackground,'Position',[200,450,50,25]);
        backgroundLable     = uicontrol('Style','text','String','Select Background for current cells','HorizontalAlignment','left','Position',[10,457,175,15]);

        backgroundEnable	= uicontrol('Style','checkbox','String','Subtract Backgrounds','Position',[10,425,150,25],'Value',1,'Callback',@drawCellsCallback);

        normEnable          = uicontrol('Style','checkbox','String','Normalize plots','Position',[10,400,125,25],'Value',1,'Callback',@drawCellsCallback);

        captionEdit         = uicontrol('Style','edit','Position',[10,375,125,25],'HorizontalAlignment','left','Callback',@captionEdited);

        colorEdit           = uicontrol('Style','pushbutton','String','Edit color','Position',[150,375,125,25],'Callback',@changeColor);
        
        set(mainWindow,'ResizeFcn',@resizeWindow);
    end

    function openFile(source,event)
        %[file,path]=uigetfile({'*.xls';'*.csv';'*.*'},'File Selector');
        [file,path,filter]=uigetfile({'*.xls;*.csv;*txt','Spreadsheet files'});
        if file==0
            return
        end
        
        doubles=zeros(1,98);
        if strcmp(file(end-2:end),'xls') || strcmp(file(end-2:end),'txt')
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
        elseif strcmp(file(end-2:end),'csv')
            doubles=csvread([path,file],1,0);
        end
        
        wavelengths=doubles(:,1);
        for i=1:size(intensities,1)
            for j=1:size(intensities,2)
                intensities(i,j,1:size(doubles,1))=doubles(:,3+(j-1)+12*(i-1));
            end
        end
        set(table,'Enable','on'); %if the table is enabled before a file is open, bad things end up happening.
    end

    function resizeWindow(source,event)
        %function to move and resize GUI elements when the window is
        %resized.
        
        newPos  = get(mainWindow,'Position');
        delPos  = newPos-defaultPosition;
        
        if newPos(3)<500
            newPos(3)=500;
        end
        if newPos(4)<200
            newPos(4)=200;
        end
        set(table,'Position',[10,530+delPos(4),332,168]);
        set(graph,'Position',[[400,100],[800,600]+delPos(3:4)]);
        set(addToBackgrounds,'Position',[10,500+delPos(4),200,25]);
        set(useBackgrounds,'Position',[200,450+delPos(4),50,25]);
        set(backgroundLable,'Position',[10,457+delPos(4),175,15]);
        set(backgroundEnable,'Position',[10,425+delPos(4),150,25]);
        set(normEnable,'Position',[10,400+delPos(4),125,25]);
        set(captionEdit,'Position',[10,375+delPos(4),125,25]);
        set(colorEdit,'Position',[150,375+delPos(4),125,25]);
        
        
    end%need implimented

    function drawCellsCallback(source,event)
        
    end %need implimented
    
    function CellSelection(source,event)
        %called when which cells are selected on the table.
        selectedCells=event.Indices;
        backgrounds=[];
        for i=1:size(selectedCells,1)
            backgrounds=unique([backgrounds,cellBackgrounds(selectedCells(i,1),selectedCells(i,2))]);
        end
               
        if size(backgrounds,2)==1
            set(useBackgrounds,'Value',1+backgrounds);
        else
            set(useBackgrounds,'Value',1);
        end
        
        drawCells(selectedCells,graph);
    end%need implimented

    function addBackgrounds(source,event)
        %addes the selected cells to the dropdown list of possible
        %backgrounds.
        
        for i=1:size(selectedCells,1)
            backgroundIDs=unique([backgroundIDs;selectedCells(i,1),selectedCells(i,2)],'rows');
        end
        for i=1:size(backgroundIDs,1)
            backgroundStrings(i+1)=cellTable(backgroundIDs(i,1),backgroundIDs(i,2));
        end
        set(useBackgrounds,'String',backgroundStrings);
    end

    function useBackground(source,event)
        %selects which cell to use as the background for the selected cell,
        %out of the dropdown list.
        backgroundID=get(source,'Value')-1;
        for i=1:size(selectedCells,1)
            cellBackgrounds(selectedCells(i,1),selectedCells(i,2))=backgroundID;
        end
    end
    
    function captionEdited(source,event)
        %allows the user to edit the caption for the selected line(s)
    end%need implimented
    
    function changeColor(source,event)
        %allows the user to pick a color to for the selected line(s)
    end%need implimented
    
    function exportImage(source,event)
        %exports a PNG of whats being rendered on the graph.
    end%need implimented
    
    function exportCSV(source,event)
        %exports a csv _all_ of the data, with background subtraction and
        %normalization done if the boxes are checked.
    end%need implimented

    function graphClickCallback(source,event)
        %used to select the region to use for normalization.
    end%need implimented

    function drawScatterCallback(source,event)
    % Toggles drawing the data points as a scatter plot.    
    end%need implimented

    function drawLinesCallback(source,event)
        % Toggles drawing lines between the data points.
    end%need implimented

    function smoothLinesCallback(source,event)
        % Toogles smoothing of the lines.
    end%need implimented

    function zoomCallback(source,event)
        
    end%need implimented

    function panCallback(source,event)

    end%need implimented
end