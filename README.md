# Davinci Render Script
A .lua Script To Davinci Resolve That Can Render Multiple Presets With Marker Durations At The Same Time.  

If you have no markers placed (markers must have a duration of more than 1 frame to count as valid),  
then it will ask if you want to render entire timeline you're currently on.

If you want to only render a specific part, you can use in/out points and convert them to marker durations.  
Or create markers with a duration directly.  

Normally a blue marker won't do anything, In `Settings.lua` there is 4 Presets it will choose from.  
Red, Yellow and Green will however render when the script is ran.  

You can choose different render presets depending on the marker color used (this is configured in `Settings.lua`).
There is also a default preset that will be enabled if you render timeline and such.  

`RenderExplorerPath` in `Settings.lua` is the directory which `SetRenderPath.lua` will default to when ran.  

`RenderCustomName` in `Settings.lua` is the file prefix when rendering using this script.  
Leave it blank to use the current project name instead.  

And finally, `FileDestination` is the path where temp storage files will be located.  
This is stuff like the RenderPath set by `SetRenderPath.lua`, so it will be saved between restarts.  

## Installation
Download the .zip  
This contains three important files alongside the actual `Render.lua` script.  

The `Settings.lua` & `Util.lua` needs to be located in  
`C:\Users\<User>\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Fusion\Modules\Lua\` 

And `Render.lua` Should be in `...\Fusion\Scripts\Edit\`  
And Lastly, `SetRenderPath.lua` Should also be in `...\Fusion\Scripts\Edit\` 

And now in Davinci Resolve, Under `Workspace > Scripts`,  
There should be both scripts. Run `SetRenderPath` once before running `Render`.  
