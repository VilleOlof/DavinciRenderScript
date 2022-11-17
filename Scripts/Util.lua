Util = {}

Util.resolve = resolve
Util.projman = Util.resolve:GetProjectManager()
Util.proj = Util.projman:GetCurrentProject()
Util.timeline = Util.proj:GetCurrentTimeline()