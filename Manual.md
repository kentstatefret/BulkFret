# BulkFret Analysis Software

## A user manual

----

##File Commands

### Opening a file

A file may be opened by selecting File->Open, or by clicking the manila envelope on the far left of the toolbar.  This will open a standard file selector dialog, which can be used as any other dialog you are likely to be familiar with.  Allowed formats are the .xls or .txt files produced by the lab equipment, and the .csv files exported from this software.  It does not support opening files with any other extension.  Attempting to open other files, even files with the .csv or .xls extension, which came from other sources will result in unspecified behavior and is discouraged.

Please note that the software may take several seconds to process your file before it finishes opening it.

###Saving a CSV  File

The software is capable of generating a coma separated value (CSV) file containing the data _as it is graphed by the software at the time of export_ (meaning any normalization and background removal is preserved).  To do so, click either File->Save CSV or the blue floppy disk on the toolbar.  A standard dialog will appear and allow you to specify where you want to place the resulting file and what you want to name it.

The resulting file can be opened in a text editor or imported by spreadsheet software.  It is formatted in a very similar manner to the xls file that it opens.  However, **some of the information at the header section of the initial spreadsheet is not saved**.

The software is capable of reopening the .csv files it produces.  However, doing so will not preserve several features that would be usable by finishing whatever processing is desired in a single session:

- Colors and labels for the cells are not saved with the .csv, and will be restored to a default on reopening it.
- Which cells are and are not potential backgrounds are not saved.  Any cells you wish to continue using as a background will have to be re-added to the background list
- Since the data is simply saved as displayed, it is non-trivial to undo and background removals or normalization that were done on the original, and the software is not equipped to attempt to do so at this time.

###Exporting a .png image.

To export a .png image, click File-Export Image, then use the resulting dialog to specify where to you wish to save your file and what you wish to name it.  The software will then briefly open a new figure at your monitors native resolution, plot the data to it in the same way it is currently shown in the main window, saves an image of that figure, then closes it again.  Please allow up to a few seconds for this process to complete.

----

##View Commands

###Selecting cells to display and edit.

To select a cell to display, simply find it in the table of cells found in the top left of the window.  

To select a range of cells, click and drag over mutliple cells in the table, or select a cell in the corner of the desired range, hold shift, then click on a cell in the opposite corner of the range you wish to select. 

To select multiple cells that cannot be described by a rectangular range, hold control and click on each desired cell.

Please note that the cell selection table is disabled on initial launch of the software, until a file is successfully opened.  Allow several seconds for the file opening process to complete before attempting to select cell(s).

###Zooming and out.

Sometimes it may be necessary to get a closer look at parts of the data.  To do this, click on the icon of a magnifying glass with a "+" in it's lenses, then click on the section of the graph you want to zoom in on.  Repeat until the magnification has been sufficiently increased.  To zoom out,  icon of a magnifying glass with a "-" in it's lenses, then click on the graph, repeating as needed to achieve the desired magnification.  This functionality is the same as a normal matlab figure.

###Plotting style.

There are three toggle options that have aesthetic effects on the plot.  

- Draw Data Points.  When enabled, a point is drawn for each data point represented in the graph.
- Draw Lines.  When enabled, line graphs connect the data points represented in the graph.
- Smooth Lines.  When enabled, the aforementioned lines are an interpolation based on the data.  When disabled, the lines are simply straight between each data point.

None of these options are mutually exclusive.  However, Smooth Lines will have no effect if Draw Lines is disabled, since there will be no lines to smooth.  Further, either Draw Lines or Draw Data Points _must_ be enabled, or the graph will always be empty.  This condition is maintained automatically.

###Plotting Data.

Whether to subtract the user defined backgrounds and whether to normalize the data can both be toggled by the user.  To do so, use the two labeled check boxes on the left side of the window.

---

##Data Manipulation.

###Background removal.

The software allows the user to specify a particular cell as the background of another cell, from a dropdown list of cells on the left of the window.  However, **this list is initally empty**, as a 96 element drop-down would be unwieldy.  The user must specify to the software which cells may be used as a background first.

To designate a cell or cells as background, select it/them, then click the "Added selected cells to background list" button immediately bellow the cell selection table.  The selected cells will then be added to the dropdown (if any of them are already in the dropdown list, the will not be duplicated).

To select which cell to use as a background for another cell or multiple other cells, select the cells you wish to select the background from, then select the desired background from the dropdown.  It is possible to use a cell as the background for itself, but since this results in a plot of zeros, it is not recomended.

To remove the background from specific cells, select the cells, then select the blank option from the dropdown.

###Normalization

In order to normalize the data, the software needs to know which region you intend to normalize based on.  To select this region, click in the graph area to begin the process, then click once on each side of the region you wish to use for normalization.  The software will then perform a parabolic fit of the data within the range you selected, and (if the parabola is downward opening and the vertex is at greater than zero y) finds a normalization scaler such that the maximum of the parabola in the user defined range has a y coordinate of 1.  This has two effects:

1. Even if the range you selected contains the true maximum of the data, there may be points with y coordinates greater than one.  
2. You should do your best to select a region that is approximately parabolic in shape.  The better the parabolic approximation is, the better the normalization.

Note that the software will continue to update the normalization scalers based on the selected range if you make other modifications to the data (i.e. if you changes the background).