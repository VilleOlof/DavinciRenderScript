require "Settings"

selectedPath = tostring(fu:RequestDir(RenderExplorerPath))

file = io.open(FileDestination.."RenderPath.txt","w")
file:write(selectedPath)
file:close()