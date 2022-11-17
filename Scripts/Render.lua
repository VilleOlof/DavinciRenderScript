require "Settings"
require "Util"

selectedPath = ""

PresetDict = {
    ["Red"] = Red_RenderPreset,
    ["Yellow"] = Yellow_RenderPreset,
    ["Green"] = Green_RenderPreset
}

function Button_Popup()
    local ui = fu.UIManager
    local disp = bmd.UIDispatcher(ui)
    local width,height = 250,50
    local checked = false
    
    win = disp:AddWindow({
        ID = 'Window',
        WindowTitle = 'No Markers',
        Geometry = {650, 650, width, height},
        Spacing = 10,
    
        ui:VGroup{
            ID = 'root',
    
            ui:HGroup{
                ui:Button{
                    ID = 'Y',
                    Text = 'Render Timeline',
                    AutoDefault = true,
                },
                ui:Button{
                    ID = 'N',
                    Text = 'Do Nothing',
                },
            }
        },
    })
    
    function win.On.Window.Close(ev)
            disp:ExitLoop()
    end
    
    itm = win:GetItems()
    
    function win.On.Y.Clicked(ev)
        checked = true
        disp:ExitLoop()
    end

    function win.On.N.Clicked(ev)
        checked = false
        disp:ExitLoop()
    end
    
    win:Show()
    disp:RunLoop()
    win:Hide()
    return checked
end

function LabelWindow(labelText)
    local ui = fu.UIManager
    local disp = bmd.UIDispatcher(ui)
    local width,height = 750,60
    
    win = disp:AddWindow({
        ID = 'LabelW',
        WindowTitle = 'Render.lua',
        Geometry = {650, 650, width, height},
        Spacing = 10,
        
        ui:VGroup{
            ID = 'root',
            ui:Label{
                ID = 'L',
                Text = labelText,
                Alignment = {
                    AlignHCenter = true,
                    AlignTop = true,
                },
            },
        },
    })
    
    function win.On.LabelW.Close(ev)
        disp:ExitLoop()
    end
    itm = win:GetItems()
    
    win:Show()
    disp:RunLoop()
    win:Hide()
    
end

function RenderTimeline()
    local RenderSettings = {
        SelectAllFrames = true,
        TargetDir = selectedPath,
        CustomName = ExportName
    }
    Util.proj:SetRenderSettings(RenderSettings)

    Util.proj:AddRenderJob()
end

function GetFileCount(path)
    local count = 0

    --just removing the last / from the 'selectedPath' to make the command
    local text = path:sub(1, -2)

    local Dir_CMD = "dir \""..text.."\" /b"

    for file in io.popen(Dir_CMD):lines() do 

        local fixed_cap = file:sub(1,#ExportName)

        if (fixed_cap == ExportName) then
            count = count + 1
        end
    end

    return count
end

function AddMarker_RenderJobs()
    startFrame = Util.timeline:GetStartFrame()

    fileCountName = GetFileCount(selectedPath)

    for markerFrame, marker in pairs (markers) do

        --Skips the loop if the marker is just one frame, this needs you to modify the marker
        if (marker.duration <= 1) then goto continue end
        if (marker.color ~= "Red" and marker.color ~= "Yellow" and marker.color ~= "Green") then goto continue end

        local RenderName = ExportName .. tostring(fileCountName)
        fileCountName = fileCountName - 1

        --Takes the correct preset depending on marker color
        if (PresetDict[marker.color] ~= nil) then
            Util.proj:LoadRenderPreset(PresetDict[marker.color])
         else
            --default preset
            Util.proj:LoadRenderPreset(Default_RenderPreset)
         end

        local RenderSettings = {
            MarkIn = startFrame + markerFrame,
            MarkOut = startFrame + markerFrame + marker.duration - 1,
            TargetDir = targetDirectory,
            CustomName = RenderName
         }

         Util.proj:SetRenderSettings(RenderSettings)

         Util.proj:AddRenderJob()
         ::continue::
    end
end

function CheckIfMarker()
    render_jobs = Util.proj:GetRenderJobList()

    for markerFrame, marker in pairs (markers) do
        if (marker.duration > 1) then return true end
    end
    return false
end

function StartRender()
    --Only Starts rendering if there is any jobs
    render_jobs = Util.proj:GetRenderJobList()

    if (render_jobs) then
        Util.proj:StartRendering(); 
    end
end

function VerifyPreset()

    local list = Util.proj:GetRenderPresetList()

    red = true
    yellow = true
    green = true

    for k,presetName in pairs(list) do

        if (Red_RenderPreset == presetName) then
            red = false
        end
        
        if (Yellow_RenderPreset == presetName) then
            yellow = false
        end

        if (Green_RenderPreset == presetName) then
            green = false
        end
    end
    
    label = "("
    returnResult = true

    if (red) then label = label..Red_RenderPreset..", " end
    if (yellow) then label = label..Yellow_RenderPreset..", " end
    if (green) then label = label..Green_RenderPreset..", " end

    if (label ~= "(") then 
        label = label:sub(1, -3) --removes the last ,
        label = label..") doesn't match any Davinci Resolve presets\n(Is it spelled correctly?) - Aborting Rendering - (Close Window)"

        LabelWindow(label) 
        returnResult = false
    end
    
    return returnResult
 end

function Init()
    local _file = io.open(FileDestination.."RenderPath.txt","r")

    if _file then
        selectedPath = _file:read("*all")
        _file:close()
    end

    Util.proj:DeleteAllRenderJobs()
    Util.proj:LoadRenderPreset(Default_RenderPreset)
    
    markers = Util.timeline:GetMarkers()

    if (RenderCustomName == "") then ExportName = Util.proj:GetName() else ExportName = RenderCustomName end

    presetcheck = VerifyPreset()
end

Init()

if (presetcheck) then
    --main function of the script
    markerExists = CheckIfMarker()

    if (not markerExists) then
        --No marker, render entire timeline
        buttonChoice = Button_Popup()
        if (buttonChoice) then RenderTimeline() end
    elseif (markerExists) then
        --loop through all markers and add render jobs
        AddMarker_RenderJobs()
    end

    StartRender()
end