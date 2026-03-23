local M = {}

function M:peek(job)
  local child, err = Command("glow")
    :arg("-s")
    :arg("dark")
    :arg("-w")
    :arg(tostring(job.area.w))
    :arg(tostring(job.file.url):gsub("^file://", ""))
    :stdout(Command.PIPED)
    :stderr(Command.PIPED)
    :spawn()

  if not child then
    ya.err("glow spawn failed: " .. tostring(err))
    return ya.preview_code(job)
  end

  local limit = job.area.h
  local i, lines = 0, {}
  local skip = job.skip

  while i < skip + limit do
    local line, event = child:read_line()
    if event ~= 0 then break end
    i = i + 1
    if i > skip then
      lines[#lines + 1] = ui.Line(line)
    end
  end

  child:start_kill()
  ya.preview_widget(job, { ui.Text(lines):area(job.area) })
end

function M:seek(job)
  local h = cx.active.current.hovered
  if not h or h.url ~= job.file.url then return end
  local step = job.units
  local skip = cx.active.preview.skip + step
  ya.manager_emit("peek", { math.max(0, skip), only_if = tostring(job.file.url) })
end

return M
