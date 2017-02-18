function myTest
    f=figure

    check=uicontrol('Style','checkbox')
    test=uicontrol('Style','pushbutton','Position',[100,100,100,25],'Callback',@button)

    function button(src,evnt)
        get(check,'Value')
    end
end